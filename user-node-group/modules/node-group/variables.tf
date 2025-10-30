variable "name" {
  description = "Name of the node group being created."
  type        = string
  nullable    = false
}

variable "cluster_id" {
  description = "ID of the Azure Kubernetes managed cluster."
  type        = string
  nullable    = false
}

variable "cluster_version_full" {
  description = "The full Kubernetes version of the Azure Kubernetes managed cluster."
  type        = string
  nullable    = false
}

variable "cni" {
  description = "Kubernetes CNI, \"kubenet\" & \"azure\" are supported."
  type        = string
  nullable    = false
}

/* variable "fips" {
  description = "If true, the cluster will be created with FIPS 140-2 mode enabled; this can't be changed once the cluster has been created."
  type        = bool
  nullable    = false
} */

variable "subnet_id" {
  description = "ID of the subnet to use for the node group."
  type        = string
  nullable    = false
}

variable "availability_zones" {
  description = "Availability zones to use for the node group."
  type        = list(number)
  nullable    = false
}

variable "system" {
  description = "If the node group is of the system or user mode."
  type        = bool
  nullable    = false
}

variable "node_arch" {
  description = "Architecture of the node."
  type        = string
  nullable    = false
}

variable "min_capacity" {
  description = "Minimum number of nodes in the group."
  type        = number
  nullable    = false
}

variable "max_capacity" {
  description = "Maximum number of nodes in the group."
  type        = number
  nullable    = false
}

variable "node_os" {
  description = "The OS to use for the nodes, \"ubuntu\", \"azurelinux\", \"windows2019\" or \"windows2022\" are supported."
  type        = string
  nullable    = false
}

variable "node_type" {
  description = "The type of nodes to create, \"gp\", \"gpd\", \"mem\", \"memd\" & \"stor\" are supported."
  type        = string
  nullable    = false
}

variable "node_type_variant" {
  description = "Variant of the node type."
  type        = string
  nullable    = false
}

variable "node_type_version" {
  description = "Version of the node type to use."
  type        = string
  nullable    = false
}

variable "node_size" {
  description = "The size of nodes to create."
  type        = string
  nullable    = false
}

variable "ultra_ssd" {
  description = "If the node group can use Azure ultra disks."
  type        = bool
  nullable    = false
}

variable "os_disk_size" {
  description = "Size of the OS disk to create, this will be ignored if temp_disk_mode is OS or KUBELET."
  type        = number
  nullable    = false
}

variable "temp_disk_mode" {
  description = "Temp disk mode, this is only valid for node types with a temp disk."
  type        = string
  nullable    = false
}

variable "nvme_mode" {
  description = "The NVMe mode for node group, this is only valid for stor node types."
  type        = string
  nullable    = false
}

variable "os_config" {
  description = "Operating system configuration."
  type = object({
    sysctl = map(any)
  })
  nullable = false
}

variable "kubelet_config" {
  description = "Kubelet configuration."
  type = object({
    cpu_manager_policy        = string
    container_log_max_line    = number
    container_log_max_size_mb = number
  })
  nullable = true
}

variable "proximity_placement_group_id" {
  description = "Proximity placement group ID to use if set."
  type        = string
  nullable    = true
}

variable "max_pods" {
  description = "Maximum number of pods per node, this only apples to clusters using the AzureCNI."
  type        = number
  nullable    = true
}

variable "capacity_reservation_group_id" {
  description = "Capacity placement group ID to use if set."
  type        = string
  nullable    = true
}
variable "upgrade_settings" {
  description = "Upgrade settings for the node group."
  type = object({
    max_surge          = string
    drain_timeout      = number
    node_soak_duration = number
  })
  nullable = false
  default = {
    max_surge          = "10%"
    drain_timeout      = 0
    node_soak_duration = 0
  }
}

variable "labels" {
  description = "Labels to set on the nodes."
  type        = map(string)
  nullable    = false
}

variable "taints" {
  description = "Taints to set on the nodes."
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  nullable = false
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  nullable    = false
}

variable "timeouts" {
  description = "Timeout configuration."
  type = object({
    node_group_create = number
    node_group_update = number
    node_group_read   = number
    node_group_delete = number
  })
  nullable = false
}

variable "spot_capacity" {
  description = "If the node group should use spot nodes."
  type        = bool
  nullable    = false
}

variable "temporary_name_for_rotation" {
  type        = string
  description = "Temporary name for node rotation."
  nullable    = false
}

variable "fips" {
  description = "If true, the cluster will be created with FIPS 140-2 mode enabled; this can't be changed once the cluster has been created."
  type        = bool
  nullable    = false
}