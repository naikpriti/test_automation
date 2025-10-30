# Define local variables
locals {
  # Count the number of availability zones
  az_count       = length(var.availability_zones)
  module_version = "v1.4.14"
  # Set node group overrides based on experimental features and defaults
  node_group_overrides = merge({
    }, var.experimental.arm64 ? {} : {
    node_arch = "amd64"
    }, var.experimental.node_group_os_config ? {} : {
    os_config = { sysctl = {} }
    }, var.experimental.azure_cni_max_pods ? {} : {
    max_pods = -1
  })
  # Define the input for system node groups
  system_node_groups_input = {
    system = {
      system              = true
      node_arch           = "amd64"
      node_os             = "ubuntu"
      node_type           = var.system_nodes.node_type
      node_type_variant   = "default"
      node_type_version   = var.system_nodes.node_type_version
      node_size           = var.system_nodes.node_size
      single_group        = true
      min_capacity        = var.system_nodes.min_capacity
      max_capacity        = var.system_nodes.min_capacity * 4
      os_config           = { sysctl = {} }
      kubelet_config      = { cpu_manager_policy = "none" }
      ultra_ssd           = false
      os_disk_size        = 128
      temp_disk_mode      = contains(["gpd", "memd", "stor"], var.system_nodes.node_type) ? "OS" : "NONE"
      nvme_mode           = "NONE"
      placement_group_key = null
      max_pods            = null
      max_surge           = "10%"
      labels = {
        "lnrs.io/tier" = "system"
      }
      taints = [{
        key    = "CriticalAddonsOnly"
        value  = "true"
        effect = "NO_SCHEDULE"
      }]
      tags = {}
    }
  }

  # Set node groups to the system node groups input
  node_groups = local.system_node_groups_input

  # Determine placement group keys and names
  placement_group_keys  = distinct(compact([for k, v in local.node_groups : v.placement_group_key if !v.single_group]))
  placement_group_names = flatten([for k in local.placement_group_keys : [for z in var.availability_zones : "${k}${z}"]])

  # Expand node groups to include availability zones
  node_groups_expanded_0 = merge(concat([for k, v in local.node_groups : { for z in var.availability_zones : format("%s%s", k, z) => merge(v, {
    availability_zones          = [z]
    az                          = z
    min_capacity                = floor(v.min_capacity / local.az_count)
    max_capacity                = floor(v.max_capacity / local.az_count)
    temporary_name_for_rotation = format("%sx%s", k, z)
    }) } if !v.single_group],
    [for k, v in local.node_groups : { format("%s0", k) = merge(v, {
      availability_zones          = var.availability_zones
      az                          = 0
      temporary_name_for_rotation = format("%sx0", k)
  }) } if v.single_group])...)

  # Set proximity placement group IDs for node groups
  node_groups_expanded_1 = { for k, v in local.node_groups_expanded_0 : k => merge(v, {
    proximity_placement_group_id = v.single_group || v.placement_group_key == null || v.placement_group_key == "" ? null : azurerm_proximity_placement_group.default["${v.placement_group_key}${v.az}"].id
  }) }

  # Set system node groups to the expanded node groups
  system_node_groups = { for k, v in local.node_groups_expanded_1 : k => v if v.system }
}
