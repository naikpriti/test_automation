data "azurerm_monitor_diagnostic_categories" "default" {
  resource_id = azurerm_kubernetes_cluster.aks_cluster.id
}

data "azurerm_public_ips" "outbound" {
  resource_group_name = azurerm_kubernetes_cluster.aks_cluster.node_resource_group
}

locals {
  cni_lookup = {
    "kubenet"       = "kubenet"
    "azure_overlay" = "azure"
    "azure"         = "azure"
  }
  sku_tier_lookup = {
    free     = "Free"
    standard = "Standard"
  }
  module_version = "v1.4.17"
  maintenance_utc_offset_lookup = {
    westeurope = "+00:00"
    uksouth    = "+00:00"
    eastus     = "-05:00"
    eastus2    = "-05:00"
    centralus  = "-06:00"
    westus     = "-08:00"
  }

  maintainance_frequency_lookup = {
    "DAILY"            = "Daily"
    "WEEKLY"           = "Weekly"
    "FORTNIGHTLY"      = "Weekly"
    "MONTHLY_ABSOLUTE" = "AbsoluteMonthly"
    "MONTHLY_RELATIVE" = "RelativeMonthly"
  }

  maintainance_interval_lookup = {
    "DAILY"            = 1
    "WEEKLY"           = 1
    "FORTNIGHTLY"      = 2
    "MONTHLY_ABSOLUTE" = 1
    "MONTHLY_RELATIVE" = 1
  }

  maintainance_day_of_week_lookup = {
    "MONDAY"    = "Monday"
    "TUESDAY"   = "Tuesday"
    "WEDNESDAY" = "Wednesday"
    "THURSDAY"  = "Thursday"
    "FRIDAY"    = "Friday"
    "SATURDAY"  = "Saturday"
    "SUNDAY"    = "Sunday"
  }

  maintenance_utc_offset = var.maintenance.utc_offset != null ? var.maintenance.utc_offset : lookup(local.maintenance_utc_offset_lookup, var.location, "+00:00")

  outbound_type = var.use_udr ? "userDefinedRouting" : (var.nat_gateway_id != null ? "userAssignedNATGateway" : "loadBalancer")

  nat_gateway = var.nat_gateway_id != null

  custom_ca_trust_certificates = flatten([for k, v in var.custom_ca_trust_certificates : v])

  log_category_types_audit     = ["kube-audit", "kube-audit-admin"]
  log_category_types_audit_fix = ["kube-audit-admin"]

  available_log_category_types = tolist(data.azurerm_monitor_diagnostic_categories.default.log_category_types)

  log_category_types_lookup = {
    "all" = tolist(setintersection(["kube-apiserver", "kube-audit", "kube-controller-manager", "kube-scheduler", "cluster-autoscaler", "cloud-controller-manager", "guard", "csi-azuredisk-controller", "csi-azurefile-controller", "csi-snapshot-controller"], local.available_log_category_types))

    "audit-write-only" = tolist(setintersection(["kube-apiserver", "kube-audit-admin", "kube-controller-manager", "kube-scheduler", "cluster-autoscaler", "cloud-controller-manager", "guard", "csi-azuredisk-controller", "csi-azurefile-controller", "csi-snapshot-controller"], local.available_log_category_types))

    "minimal" = tolist(setintersection(["kube-apiserver", "kube-audit-admin", "kube-controller-manager", "cloud-controller-manager", "guard"], local.available_log_category_types))

    "empty" = []
  }

  storage_account_log_category_types_input = distinct(concat(local.log_category_types_lookup[var.logging.control_plane.storage_account.profile], var.logging.control_plane.storage_account.additional_log_category_types))
  storage_account_log_category_types       = length(setintersection(local.storage_account_log_category_types_input, local.log_category_types_audit)) > 1 ? setsubtract(local.storage_account_log_category_types_input, local.log_category_types_audit_fix) : local.storage_account_log_category_types_input
  create_kv_related_resources              = var.kms.use_vault_secret_operator ? true : false
  chosen_key_vault_name                    = var.kms.key_vault_name != "" ? var.kms.key_vault_name : "${var.cluster_name}-kv"
  route_table_list                         = var.use_udr ? var.route_table_ids : [var.route_table_id]
}


locals {
  acr_registry_subscription   = var.azure_environment == "usgovernment" ? "6ac9610a-51a8-49a4-9f74-6c34301749ee" : "ed5e2254-5d87-4255-b70e-1b5eba509f73"
  acr_registry_resource_group = var.azure_environment == "usgovernment" ? "app-imagegallery-prod-usgovvirginia" : "app-imagegallery-prod-eastus"
  acr_registry_name           = var.azure_environment == "usgovernment" ? "govsharedpullthroughacr" : "sharedpullthroughacr"
  acr_registry_id             = "/subscriptions/${local.acr_registry_subscription}/resourceGroups/${local.acr_registry_resource_group}/providers/Microsoft.ContainerRegistry/registries/${local.acr_registry_name}"
}