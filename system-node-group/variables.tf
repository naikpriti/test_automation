variable "subscription_id" {
  description = "ID of the subscription being used."
  type        = string
  nullable    = false
}

variable "location" {
  description = "Azure region in which to build resources."
  type        = string
  nullable    = false
}

variable "resource_group_name" {
  description = "Name of the Resource Group to deploy the AKS cluster service to, must already exist."
  type        = string
  nullable    = false
}

variable "cluster_id" {
  description = "ID of the Azure Kubernetes managed cluster."
  type        = string
  nullable    = false
}

variable "cluster_name" {
  description = "Name of the Azure Kubernetes managed cluster."
  type        = string
  nullable    = false
}

variable "cluster_version" {
  description = "The full Kubernetes version of the Azure Kubernetes managed cluster."
  type        = string
  nullable    = false
}

variable "cni" {
  description = "Kubernetes CNI, \"kubenet\" & \"azure\" are supported."
  type        = string
  nullable    = false
  default     = "kubenet"
}

variable "fips" {
  description = "If true, the cluster will be created with FIPS 140-2 mode enabled; this can't be changed once the cluster has been created."
  type        = bool
  default     = false
  nullable    = false
}

variable "subnet_id" {
  description = "ID of the subnet to use for the node groups."
  type        = string
  nullable    = false
}

variable "availability_zones" {
  description = "Availability zones to use for the node groups."
  type        = list(number)
  nullable    = false
}

variable "bootstrap_name" {
  description = "Name to use for the bootstrap node group."
  type        = string
  nullable    = false
}

variable "bootstrap_vm_size" {
  description = "VM size to use for the bootstrap node group."
  type        = string
  nullable    = false
  default     = "Standard_B2s"
}

variable "labels" {
  description = "Labels to be applied to all Kubernetes resources."
  type        = map(string)
  default     = {}
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

variable "experimental" {
  description = "Provide experimental feature flag configuration."
  type = object({
    arm64                = bool
    node_group_os_config = bool
    azure_cni_max_pods   = bool
  })
  nullable = false
  default = {
    arm64                = false
    node_group_os_config = false
    azure_cni_max_pods   = false
  }
}

variable "system_nodes" {
  description = "System node group to configure."
  type = object({
    node_arch         = optional(string, "amd64")
    node_size         = optional(string, "large")
    node_type         = optional(string, "gp")
    node_type_version = optional(string, "v1")
    min_capacity      = optional(number, 2)
  })
  nullable = false
  default  = {}

  validation {
    condition     = contains(["amd64", "arm64"], var.system_nodes.node_arch)
    error_message = "Node group architecture must be either \"amd64\" or \"arm64\"."
  }

  validation {
    condition     = (var.system_nodes.min_capacity > 0)
    error_message = "System node group min capacity must be 0 or more."
  }
}

