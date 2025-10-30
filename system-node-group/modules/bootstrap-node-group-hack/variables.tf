variable "bootstrap_name" {
  type        = string
  description = "Name to use for the bootstrap node group."
  nullable    = false
}

variable "bootstrap_vm_size" {
  type        = string
  description = "VM size to use for the bootstrap node group."
  nullable    = false
}

variable "cluster_id" {
  type        = string
  description = "ID of the Azure Kubernetes managed cluster."
  nullable    = false
}

variable "fips" {
  type        = bool
  description = "If true, the cluster will be created with FIPS 140-2 mode enabled; this can't be changed once the cluster has been created."
  nullable    = false
  default     = false
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet to use for the bootstrap node group."
  nullable    = false
}