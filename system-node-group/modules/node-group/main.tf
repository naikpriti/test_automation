resource "azurerm_kubernetes_cluster_node_pool" "default" {
  name = var.name

  kubernetes_cluster_id = var.cluster_id
  orchestrator_version  = var.cluster_version

  vnet_subnet_id = var.subnet_id
  zones          = var.availability_zones

  mode            = var.system ? "System" : "User"
  scale_down_mode = "Delete"
  fips_enabled    = var.fips

  priority             = "Regular"
  auto_scaling_enabled = local.auto_scaling
  node_count           = local.auto_scaling ? null : var.max_capacity
  min_count            = local.auto_scaling ? var.min_capacity : null
  max_count            = local.auto_scaling ? var.max_capacity : null

  upgrade_settings {
    max_surge = var.max_surge
  }

  os_type = local.os_types[var.node_os]
  os_sku  = local.os_skus[var.node_os]

  vm_size                     = local.vm_size_lookup["${var.node_arch}_${var.node_type}_${var.node_type_variant}_${var.node_type_version}"][var.node_size]
  host_encryption_enabled     = true
  node_public_ip_enabled      = false
  ultra_ssd_enabled           = var.ultra_ssd
  os_disk_type                = var.temp_disk_mode == "OS" ? "Ephemeral" : "Managed"
  os_disk_size_gb             = var.temp_disk_mode == "OS" ? local.temp_disk_size_lookup[var.node_type][var.node_size] : (var.temp_disk_mode == "KUBELET" ? 30 : var.os_disk_size)
  kubelet_disk_type           = var.temp_disk_mode == "KUBELET" ? "Temporary" : "OS"
  temporary_name_for_rotation = var.temporary_name_for_rotation

  proximity_placement_group_id = var.proximity_placement_group_id

  # max_pods = var.cni == "kubenet" && var.max_pods != -1 ? var.max_pods : local.max_pods[var.cni]
  max_pods = var.cni == "azure" ? coalesce(var.max_pods, local.max_pods[var.cni]) : local.max_pods[var.cni]

  node_labels = merge(var.labels, local.vm_labels[var.node_type], { "lnrs.io/lifecycle" = "ondemand", "lnrs.io/size" = var.node_size })
  node_taints = [for taint in concat(local.vm_taints[var.node_type], var.taints) : "${taint.key}=${taint.value}:${local.taint_effects[taint.effect]}"]

  dynamic "linux_os_config" {
    for_each = (var.node_os == "ubuntu" || var.node_os == "azurelinux") && length(var.os_config.sysctl) > 0 ? ["default"] : []

    content {

      sysctl_config {
        net_core_rmem_max           = lookup(var.os_config.sysctl, "net_core_rmem_max", null)
        net_core_wmem_max           = lookup(var.os_config.sysctl, "net_core_wmem_max", null)
        net_ipv4_tcp_keepalive_time = lookup(var.os_config.sysctl, "net_ipv4_tcp_keepalive_time", null)
      }
    }
  }

  dynamic "kubelet_config" {
    for_each = var.kubelet_config.cpu_manager_policy == "static" ? ["default"] : []

    content {
      cpu_cfs_quota_enabled = ((var.node_os == "ubuntu" || var.node_os == "azurelinux") && var.kubelet_config.cpu_manager_policy == "static") ? false : null
      cpu_manager_policy    = ((var.node_os == "ubuntu" || var.node_os == "azurelinux") && var.kubelet_config.cpu_manager_policy == "static") ? "static" : null
    }
  }


  tags = merge(var.tags)

  timeouts {
    create = format("%vm", var.timeouts.node_group_create / 60)
    read   = format("%vm", var.timeouts.node_group_read / 60)
    update = format("%vm", var.timeouts.node_group_update / 60)
    delete = format("%vm", var.timeouts.node_group_delete / 60)
  }

  lifecycle {
    precondition {
      condition     = (var.temp_disk_mode != "OS" && var.temp_disk_mode != "KUBELET") || contains(["gpd", "memd", "stor"], var.node_type)
      error_message = "Only nodes with temp disks can use them for the OS or kubelet data."
    }
  }
}
