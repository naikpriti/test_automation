locals {
  # Get the number of availability zones
  az_count = length(var.availability_zones)

  # Set the node group overrides
  # node_group_overrides = merge({
  #   }, var.experimental.arm64 ? {} : {
  #   node_arch = "amd64"
  #   }, var.experimental.azure_cni_max_pods ? {} : {
  #   max_pods = local.user_node_groups.max_pods
  # })
  module_version = "v1.3.17"
  # Merge the node groups with the overrides
  node_groups = merge({ for k, v in var.node_groups : k => merge(var.node_groups, v, { system = false }) })

  # Get the placement group keys and names
  placement_group_keys  = distinct(compact([for k, v in local.node_groups : v.placement_group_key if !v.single_group]))
  placement_group_names = flatten([for k in local.placement_group_keys : [for z in var.availability_zones : "${k}${z}"]])

  # Expand the node groups for each availability zone
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

  # Set the proximity placement group ID for each node group
  node_groups_expanded_1 = { for k, v in local.node_groups_expanded_0 : k => merge(v, {
    proximity_placement_group_id = v.single_group || v.placement_group_key == null || v.placement_group_key == "" ? null : azurerm_proximity_placement_group.default["${v.placement_group_key}${v.az}"].id
  }) }

  # Get the user node groups
  user_node_groups = { for k, v in local.node_groups_expanded_1 : k => v if !v.system }

  # Check if there is an ingress node group
  ingress_node_group = anytrue([for group in var.node_groups : try(group.labels["lnrs.io/tier"] == "ingress", false) && (length(group.taints) == 0 || (length(group.taints) == 1 && try(group.taints[0].key == "ingress", false)))])
}
