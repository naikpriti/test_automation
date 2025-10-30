# Define the proximity placement group resource
resource "azurerm_proximity_placement_group" "default" {
  for_each = toset(local.placement_group_names)

  # Set the name of the proximity placement group
  name = each.key

  # Set the location of the proximity placement group
  location = var.location

  # Set the resource group name of the proximity placement group
  resource_group_name = var.resource_group_name

  # Set the tags of the proximity placement group
  tags = var.tags
}

# Define the user node groups module
module "user_node_groups" {
  source   = "./modules/node-group"
  for_each = local.user_node_groups

  # Set the name of the node group
  name = each.key

  # Set the cluster ID and version
  cluster_id           = var.cluster_id
  cluster_version_full = var.cluster_version_full

  # Set the CNI plugin
  cni = var.cni

  # Set the subnet ID
  subnet_id = var.subnet_id

  # Set the availability zones
  availability_zones = each.value.availability_zones

  # Set the node group to be a user node group
  system = false

  # Set if you want to use spot instances
  spot_capacity = each.value.spot_capacity

  # Set the node architecture
  node_arch = each.value.node_arch

  # Set the node operating system
  node_os = each.value.node_os

  # Set the node type
  node_type = each.value.node_type

  # Set the node type variant
  node_type_variant = each.value.node_type_variant

  # Set the node type version
  node_type_version = each.value.node_type_version

  # Set the node size
  node_size = each.value.node_size

  # Set the minimum and maximum capacity
  min_capacity = each.value.min_capacity
  max_capacity = each.value.max_capacity

  # Set the OS configuration
  os_config = each.value.os_config

  # Set the kubelet configuration
  kubelet_config = each.value.kubelet_config

  # Set the ultra SSD flag
  ultra_ssd = each.value.ultra_ssd

  # Set the OS disk size
  os_disk_size = each.value.os_disk_size

  # Set the temporary disk mode
  temp_disk_mode = each.value.temp_disk_mode

  # Set the FIPS flag 
  fips = var.fips

  # Set the NVMe mode
  nvme_mode = each.value.nvme_mode

  # Set the proximity placement group ID
  proximity_placement_group_id = each.value.proximity_placement_group_id

  # Set the maximum number of pods
  max_pods                    = each.value.max_pods
  temporary_name_for_rotation = each.value.temporary_name_for_rotation

  # Set the maximum surge
  upgrade_settings = each.value.upgrade_settings

  # Set the labels and tags
  labels = merge(var.labels, each.value.labels)
  taints = each.value.taints
  tags   = merge(var.tags, each.value.tags, { "lnrs.io.aks.module.appnodepool.version" = local.module_version })

  # Set the timeouts
  timeouts = var.timeouts

  # capacity reservation group
  capacity_reservation_group_id = each.value.capacity_reservation_group_id
}