resource "azurerm_proximity_placement_group" "default" {
  for_each = toset(local.placement_group_names)

  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Define the system node groups module
module "system_node_groups" {
  source   = "./modules/node-group"
  for_each = local.system_node_groups

  # Set the name of the node group
  name = each.key

  # Set the cluster ID and version
  cluster_id      = var.cluster_id
  cluster_version = var.cluster_version

  # Set the CNI plugin
  cni = var.cni

  # Set the subnet ID
  subnet_id = var.subnet_id

  # Set the availability zones
  availability_zones = each.value.availability_zones

  # Set the node group to be a system node group
  system = true

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
  max_pods = each.value.max_pods

  # Set the maximum surge
  max_surge = each.value.max_surge

  temporary_name_for_rotation = each.value.temporary_name_for_rotation

  # Set the labels and tags
  labels = merge(var.labels, each.value.labels)
  tags   = merge(var.tags, each.value.tags, { "lnrs.io.aks.module.systemnodepool.version" = local.module_version })
  taints = each.value.taints
  # Set the timeouts
  timeouts = var.timeouts
}

# Define the bootstrap node group module
module "bootstrap_node_group_hack" {
  source = "./modules/bootstrap-node-group-hack"

  bootstrap_name    = var.bootstrap_name
  bootstrap_vm_size = var.bootstrap_vm_size
  cluster_id        = var.cluster_id
  fips              = var.fips
  subnet_id         = var.subnet_id

  # Depend on the system node groups module
  depends_on = [
    module.system_node_groups
  ]
}

/* module "cluster_version_tag" {
  source = "../tags"

  subscription_id     = var.subscription_id
  resource_group_name = var.resource_group_name
  resource_id         = "/subscriptions/${var.subscription_id}/resourcegroups/${var.resource_group_name}/providers/Microsoft.ContainerService/managedClusters/${var.cluster_name}"
  resource_tags       = { "lnrs.io.aks.module.sysnodepool.version" = local.module_version }
  depends_on = [module.system_node_groups,
  module.bootstrap_node_group_hack]
} */
