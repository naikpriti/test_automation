resource "azurerm_kubernetes_cluster_node_pool" "default" {
  name = var.name

  kubernetes_cluster_id         = var.cluster_id
  orchestrator_version          = var.cluster_version_full
  capacity_reservation_group_id = var.capacity_reservation_group_id
  vnet_subnet_id                = var.subnet_id
  zones                         = var.availability_zones
  fips_enabled                  = var.fips
  mode                          = var.system ? "System" : "User"
  scale_down_mode               = "Delete"
  priority                      = var.spot_capacity ? "Spot" : "Regular"
  eviction_policy               = var.spot_capacity ? "Delete" : null
  auto_scaling_enabled          = local.auto_scaling
  node_count                    = local.auto_scaling ? null : var.max_capacity
  min_count                     = local.auto_scaling ? var.min_capacity : null
  max_count                     = local.auto_scaling ? var.max_capacity : null

  dynamic "upgrade_settings" {
    for_each = var.spot_capacity ? [] : [true]

    content {
      max_surge                     = var.upgrade_settings.max_surge
      drain_timeout_in_minutes      = var.upgrade_settings.drain_timeout != null ? ceil(var.upgrade_settings.drain_timeout / 60) : null
      node_soak_duration_in_minutes = var.upgrade_settings.node_soak_duration != null ? ceil(var.upgrade_settings.node_soak_duration / 60) : null
    }
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

  max_pods = (var.cni == "azure" || var.cni == "kubenet") ? coalesce(var.max_pods, local.max_pods[var.cni]) : local.max_pods[var.cni]

  node_labels = merge(var.labels, local.vm_labels[var.node_type], { "lnrs.io/lifecycle" = "ondemand", "lnrs.io/size" = var.node_size })
  node_taints = [for taint in concat(local.vm_taints[var.node_type], var.taints) : "${taint.key}=${taint.value}:${local.taint_effects[taint.effect]}"]

  dynamic "linux_os_config" {
    for_each = (var.node_os == "ubuntu" || var.node_os == "azurelinux") && length(var.os_config.sysctl) > 0 ? ["default"] : []

    content {

      sysctl_config {
        net_core_rmem_max           = lookup(var.os_config.sysctl, "net_core_rmem_max", null)
        net_core_wmem_max           = lookup(var.os_config.sysctl, "net_core_wmem_max", null)
        net_ipv4_tcp_keepalive_time = lookup(var.os_config.sysctl, "net_ipv4_tcp_keepalive_time", null)
        net_core_somaxconn          = lookup(var.os_config.sysctl, "net.core.somaxconn", null)
        net_core_netdev_max_backlog = lookup(var.os_config.sysctl, "net.core.netdev_max_backlog", null)
        fs_file_max                 = lookup(var.os_config.sysctl, "fs.file-max", null)
      }
    }
  }

  dynamic "kubelet_config" {
    for_each = var.kubelet_config != null ? ["default"] : []

    content {
      cpu_cfs_quota_enabled     = ((var.node_os == "ubuntu" || var.node_os == "azurelinux") && var.kubelet_config.cpu_manager_policy == "static") ? false : null
      cpu_manager_policy        = ((var.node_os == "ubuntu" || var.node_os == "azurelinux") && var.kubelet_config.cpu_manager_policy == "static") ? "static" : null
      container_log_max_line    = var.kubelet_config.container_log_max_line
      container_log_max_size_mb = var.kubelet_config.container_log_max_size_mb
    }
  }


  tags = var.tags

  timeouts {
    create = format("%vm", var.timeouts.node_group_create / 60)
    read   = format("%vm", var.timeouts.node_group_read / 60)
    update = format("%vm", var.timeouts.node_group_update / 60)
    delete = format("%vm", var.timeouts.node_group_delete / 60)
  }

  lifecycle {
    precondition {
      condition     = (var.temp_disk_mode != "OS" && var.temp_disk_mode != "KUBELET") || contains(["gpd", "memd", "stor", "laosv4"], var.node_type)
      error_message = "Only nodes with temp disks can use them for the OS or kubelet data."
    }
  }
}
