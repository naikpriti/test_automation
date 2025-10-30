# Data source to retrieve the current Azure subscription
data "azurerm_subscription" "current" {
  subscription_id = var.subscription_id
}

# Resource to create a user-assigned identity for the AKS control plane
resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "${var.cluster_name}-control-plane"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# calling Key Vault module for KMS Etcd encryption at AKS cluster end
module "key_vault" {
  source                        = "../key-vault"
  count                         = local.create_kv_related_resources ? 1 : 0
  location                      = var.location
  resource_group_name           = var.resource_group_name
  key_vault_name                = var.kms.key_vault_name != null ? var.kms.key_vault_name : "${var.cluster_name}-kv"
  rbac_bindings                 = var.kms.user_object_ids
  aks_control_plane_identity_id = azurerm_user_assigned_identity.aks_identity.principal_id
  github_workflow_sp_object_ids = var.kms.github_workflow_sp_object_ids
  vpn_network_cidr_list         = var.kms.vpn_network_cidr_list
  azure_env                     = var.kms.azure_env
  tags                          = var.tags
}


resource "azurerm_role_assignment" "network_contributor" {
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
  role_definition_name = "Network Contributor"
  scope                = var.vnet_subnet_id
}

resource "azurerm_role_assignment" "network_contributor_route_table" {
  count                = var.use_udr && length(local.route_table_list) > 1 ? 0 : 1
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
  role_definition_name = "Network Contributor"
  scope                = var.route_table_id
}

# Role assignment to grant the user-assigned identity Network Concd tributor access to the route table
resource "azurerm_role_assignment" "udr_network_contributor_route_table" {
  count                = var.use_udr && length(local.route_table_list) > 1 ? length(local.route_table_list) : 0
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
  role_definition_name = "Network Contributor"
  scope                = local.route_table_list[count.index]
}

# Role assignment to grant the user-assigned identity Network Contributor access to the VNet subnet
resource "azurerm_role_assignment" "network_contributor_vnet" {
  count                = var.use_udr ? 1 : 0
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
  role_definition_name = "Network Contributor"
  scope                = var.virtual_network_id
}

# Role assignment to grant the user-assigned identity Key Vault Crypto User access on Key Vault for etcd encryption
resource "azurerm_role_assignment" "key_vault_crypto_user" {
  count = local.create_kv_related_resources ? 1 : 0

  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
  role_definition_name = "Key Vault Crypto User"
  scope                = module.key_vault[0].id
}

resource "azurerm_monitor_diagnostic_setting" "storage_account" {
  name               = "control-plane-storage-account"
  target_resource_id = azurerm_kubernetes_cluster.aks_cluster.id

  storage_account_id = var.logging.control_plane.storage_account.id

  dynamic "enabled_log" {
    for_each = local.storage_account_log_category_types

    content {
      category = enabled_log.value
    }
  }

  lifecycle {
    ignore_changes = [
      metric
    ]
  }
}


# Resource to create an AKS cluster
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  tags                                = merge(var.tags, { "lnrs.io.aks.module.controlplane.version" = local.module_version })
  name                                = var.cluster_name
  location                            = var.location
  resource_group_name                 = var.resource_group_name
  custom_ca_trust_certificates_base64 = local.custom_ca_trust_certificates
  dns_prefix                          = var.cluster_name
  kubernetes_version                  = var.kubernetes_version
  automatic_upgrade_channel           = !var.manual_upgrades ? "patch" : null
  node_os_upgrade_channel             = !var.manual_upgrades ? "NodeImage" : "None"

  sku_tier                          = local.sku_tier_lookup[var.sku_tier]
  node_resource_group               = "mc_${var.cluster_name}"
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true
  local_account_disabled            = true
  role_based_access_control_enabled = true
  azure_policy_enabled              = false

  # Default node pool configuration
  default_node_pool {
    name                         = var.bootstrap_name
    type                         = "VirtualMachineScaleSets"
    vnet_subnet_id               = var.vnet_subnet_id
    zones                        = [1, 2, 3]
    orchestrator_version         = var.kubernetes_version
    node_count                   = 1
    auto_scaling_enabled         = false
    only_critical_addons_enabled = true
    vm_size                      = var.vm_size
    os_disk_type                 = "Managed"
    host_encryption_enabled      = true
    node_public_ip_enabled       = false
    tags                         = var.tags
  }

  # Auto scaler profile configuration
  auto_scaler_profile {
    balance_similar_node_groups      = true
    expander                         = "random"
    skip_nodes_with_system_pods      = false
    skip_nodes_with_local_storage    = false
    scale_down_delay_after_failure   = "1m"
    scale_down_unneeded              = var.cluster_autoscaler.scale_down_unneeded_time != null ? "${ceil(var.cluster_autoscaler.scale_down_unneeded_time / 60)}m" : null
    scale_down_utilization_threshold = var.cluster_autoscaler.scale_down_utilization_threshold
  }

  api_server_access_profile {
    authorized_ip_ranges = length(var.cluster_endpoint_access_cidrs) == 0 ? ["0.0.0.0/32"] : var.cluster_endpoint_access_cidrs
  }
  # Storage profile configuration
  storage_profile {
    disk_driver_enabled         = true
    file_driver_enabled         = true
    blob_driver_enabled         = true
    snapshot_controller_enabled = true # Default is true - We may explore allowing operators to disable this feature in future updates.
  }

  # Azure AD role-based access control configuration
  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = true
    admin_group_object_ids = var.admin_group_object_ids
  }

  # Conditionally include the key_management_service block
  dynamic "key_management_service" {
    for_each = var.kms.enable_etcd_encryption ? [1] : []
    content {
      key_vault_key_id         = module.key_vault[0].vault_key_id
      key_vault_network_access = "Public"
    }
  }

  # Ignore changes to the default node pool during updates
  lifecycle {
    ignore_changes = [
      default_node_pool,
      upgrade_override
    ]
  }

  dynamic "windows_profile" {
    for_each = var.windows_support ? ["default"] : []
    content {
      admin_username = random_password.windows_admin_username[0].result
      admin_password = random_password.windows_admin_password[0].result
      license        = var.windows_licenced ? "Windows_Server" : null
    }
  }

  # This is a dynamic block that conditionally creates an OMS agent resource based on the value of the `var.oms_agent` variable.
  dynamic "oms_agent" {
    # If `var.oms_agent` is true, create a single instance of the `oms_agent` resource with the key "default".
    # If `var.oms_agent` is false, create an empty list, which means no instances of the resource will be created.
    for_each = var.oms_agent ? ["default"] : []

    # This is the content of the dynamic block, which defines the attributes of the `oms_agent` resource.
    content {
      # This is the `log_analytics_workspace_id` attribute of the `oms_agent` resource, which specifies the ID of the Log Analytics workspace to which the agent should send data.
      log_analytics_workspace_id = var.oms_agent_log_analytics_workspace_id
    }
  }


  # Control plane maintenance window configuration
  maintenance_window_auto_upgrade {
    utc_offset   = local.maintenance_utc_offset
    frequency    = local.maintainance_frequency_lookup[var.maintenance.control_plane.frequency]
    interval     = local.maintainance_interval_lookup[var.maintenance.control_plane.frequency]
    day_of_month = var.maintenance.control_plane.frequency == "MONTHLY_ABSOLUTE" ? var.maintenance.control_plane.day_of_month : null
    day_of_week  = var.maintenance.control_plane.frequency == "WEEKLY" || var.maintenance.control_plane.frequency == "FORTNIGHTLY" ? local.maintainance_day_of_week_lookup[var.maintenance.control_plane.day_of_week] : null
    start_time   = var.maintenance.control_plane.start_time
    duration     = var.maintenance.control_plane.duration

    dynamic "not_allowed" {
      for_each = var.maintenance.not_allowed

      content {
        start = not_allowed.value.start
        end   = not_allowed.value.end
      }
    }
  }

  # Node OS maintenance window configuration
  maintenance_window_node_os {
    utc_offset   = local.maintenance_utc_offset
    frequency    = local.maintainance_frequency_lookup[var.maintenance.nodes.frequency]
    interval     = local.maintainance_interval_lookup[var.maintenance.nodes.frequency]
    day_of_month = var.maintenance.nodes.frequency == "MONTHLY_ABSOLUTE" ? var.maintenance.nodes.day_of_month : null
    day_of_week  = var.maintenance.nodes.frequency == "WEEKLY" || var.maintenance.nodes.frequency == "FORTNIGHTLY" ? local.maintainance_day_of_week_lookup[var.maintenance.nodes.day_of_week] : null
    start_time   = var.maintenance.nodes.start_time
    duration     = var.maintenance.nodes.duration

    dynamic "not_allowed" {
      for_each = var.maintenance.not_allowed

      content {
        start = not_allowed.value.start
        end   = not_allowed.value.end
      }
    }
  }

  # Network profile configuration
  network_profile {
    network_plugin      = local.cni_lookup[var.cni]
    network_plugin_mode = var.cni == "azure_overlay" ? "overlay" : null
    network_policy      = "calico"
    service_cidr        = "172.20.0.0/16"
    dns_service_ip      = "172.20.0.10"
    pod_cidr            = var.cni != "azure" ? var.podnet_cidr_block : null

    outbound_type = local.outbound_type

    dynamic "load_balancer_profile" {
      for_each = var.lb_inbound_pool_type_node_ip || local.outbound_type == "loadBalancer" ? ["default"] : []
      content {
        backend_pool_type         = var.lb_inbound_pool_type_node_ip ? "NodeIP" : "NodeIPConfiguration"
        idle_timeout_in_minutes   = local.outbound_type == "loadBalancer" ? var.managed_outbound_idle_timeout / 60 : null
        managed_outbound_ip_count = local.outbound_type == "loadBalancer" ? var.managed_outbound_ip_count : null
        outbound_ports_allocated  = local.outbound_type == "loadBalancer" ? var.managed_outbound_ports_allocated : null
      }
    }
  }

  # Identity configuration
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_identity.id]
  }

  # Dependency on the network_contributor role assignment
  depends_on = [azurerm_role_assignment.network_contributor, azurerm_role_assignment.key_vault_crypto_user, module.key_vault]
}

# This is a `time_sleep` resource that waits for 30 seconds before continuing.
resource "time_sleep" "modify" {
  create_duration = "60s"

  # This trigger ensures that the resource is recreated whenever the `var.kubernetes_version` variable changes.
  triggers = {
    cluster_version = var.kubernetes_version
  }

  # This dependency ensures that the `time_sleep` resource is created after the `azurerm_kubernetes_cluster.default` resource.
  depends_on = [
    azurerm_kubernetes_cluster.aks_cluster
  ]
}

# This is a `data` resource that retrieves information about an existing AKS cluster.
data "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.cluster_name
  resource_group_name = var.resource_group_name

  # This dependency ensures that the `azurerm_kubernetes_cluster.aks_cluster` resource is created before this `data` resource.
  depends_on = [
    azurerm_kubernetes_cluster.aks_cluster,
    time_sleep.modify
  ]
}

# This is a `data` resource that retrieves information about the available Kubernetes service versions in a specific location.
data "azurerm_kubernetes_service_versions" "aks_cluster" {
  location        = var.location
  version_prefix  = var.kubernetes_version
  include_preview = false
}

resource "azurerm_role_assignment" "shared_acr" {
  principal_id                     = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = local.acr_registry_id
  skip_service_principal_aad_check = true
}
/* module "cluster_version_tag" {
  source = "../tags"

  subscription_id     = var.subscription_id
  resource_group_name = var.resource_group_name
  resource_id         = "/subscriptions/${var.subscription_id}/resourcegroups/${var.resource_group_name}/providers/Microsoft.ContainerService/managedClusters/${var.cluster_name}"
  resource_tags       = { "lnrs.io.aks.module.controlplane.version" = local.module_version }
  depends_on          = [azurerm_kubernetes_cluster.aks_cluster]
} */
resource "azurerm_public_ip" "nat_gateway_ip" {
  count               = var.use_udr ? 1 : 0
  name                = "${var.cluster_name}-nat-public-ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "nat_gateway" {
  count               = var.use_udr ? 1 : 0
  name                = "${var.cluster_name}-nat-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "ip_association" {
  count                = var.use_udr ? 1 : 0
  nat_gateway_id       = azurerm_nat_gateway.nat_gateway[count.index].id
  public_ip_address_id = azurerm_public_ip.nat_gateway_ip[count.index].id
}

moved {
  from = azurerm_role_assignment.network_contributor_route_table
  to   = azurerm_role_assignment.network_contributor_route_table[0]
}
