variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

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

variable "cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
}

variable "manual_upgrades" {
  description = "If the AKS cluster should require manual upgrades."
  type        = bool
  default     = false
}

variable "node_os_channel_upgrade" {
  type        = string
  default     = null
  description = "(Optional) The upgrade channel for this Kubernetes Cluster Nodes' OS Image. Possible values are Unmanaged, SecurityPatch, NodeImage and None"

  validation {
    condition = var.node_os_channel_upgrade == null ? true : contains([
      "NodeImage", "None"
    ], var.node_os_channel_upgrade)
    error_message = "`node_os_channel_upgrade`'s possible values are `NodeImage` or `None`, node_os_channel_upgrade must be set to NodeImage if automatic_channel_upgrade has been set to node-image."
  }
}


/* variable "node_upgrade_manual" {
  description = "If the nodes should be manually upgraded."
  type        = bool
  nullable    = false
} */

variable "maintenance" {
  description = "Maintenance configuration."
  type = object({
    utc_offset = optional(string, null)
    control_plane = optional(object({
      frequency    = optional(string, "WEEKLY")
      day_of_month = optional(number, 1)
      day_of_week  = optional(string, "SUNDAY")
      start_time   = optional(string, "00:00")
      duration     = optional(number, 4)
    }), {})
    nodes = optional(object({
      frequency    = optional(string, "WEEKLY")
      day_of_month = optional(number, 1)
      day_of_week  = optional(string, "SUNDAY")
      start_time   = optional(string, "00:00")
      duration     = optional(number, 4)
    }), {})
    not_allowed = optional(list(object({
      start = string
      end   = string
    })), [])
  })
  nullable = false
  default  = {}

  validation {
    condition     = contains(["WEEKLY", "FORTNIGHTLY", "MONTHLY_ABSOLUTE", "MONTHLY_RELATIVE"], var.maintenance.control_plane.frequency)
    error_message = "Control plane maintenance frequency must be one of \"WEEKLY\", \"FORTNIGHTLY\", \"MONTHLY_ABSOLUTE\" or \"MONTHLY_RELATIVE\"."
  }

  validation {
    condition     = contains(["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"], var.maintenance.control_plane.day_of_week)
    error_message = "Control plane maintainance day of week must be one of \"MONDAY\", \"TUESDAY\", \"WEDNESDAY\", \"THURSDAY\", \"FRIDAY\", \"SATURDAY\" or \"SUNDAY\"."
  }

  validation {
    condition     = var.maintenance.control_plane.day_of_month >= 1 && var.maintenance.control_plane.day_of_month <= 28
    error_message = "Control plane maintainance day of month must be between 1 & 28."
  }

  validation {
    condition     = var.maintenance.control_plane.duration >= 4
    error_message = "Control plane maintainance duration must be 4 hours or more."
  }

  validation {
    condition     = contains(["DAILY", "WEEKLY", "FORTNIGHTLY", "MONTHLY_ABSOLUTE", "MONTHLY_RELATIVE"], var.maintenance.nodes.frequency)
    error_message = "Node maintenance frequency must be one of \"DAILY\", \"WEEKLY\", \"FORTNIGHTLY\", \"MONTHLY_ABSOLUTE\" or \"MONTHLY_RELATIVE\"."
  }

  validation {
    condition     = contains(["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"], var.maintenance.nodes.day_of_week)
    error_message = "Node maintainance day of week must be one of \"MONDAY\", \"TUESDAY\", \"WEDNESDAY\", \"THURSDAY\", \"FRIDAY\", \"SATURDAY\" or \"SUNDAY\"."
  }

  validation {
    condition     = var.maintenance.nodes.day_of_month >= 1 && var.maintenance.control_plane.day_of_month <= 28
    error_message = "Node maintainance day of month must be between 1 & 28."
  }

  validation {
    condition     = var.maintenance.nodes.duration >= 4
    error_message = "Node maintainance duration must be 4 hours or more."
  }
}


variable "sku_tier" {
  description = "Pricing tier for the Azure Kubernetes Service managed cluster; \"free\" & \"standard\" are supported."
  type        = string
  nullable    = false
}
variable "kubernetes_version" {
  description = "Version of Kubernetes to use for the AKS cluster."
  type        = string
}

variable "bootstrap_name" {
  description = "Name of the managed node pool."
  type        = string
  default     = "bootstrap"
}

variable "node_count" {
  description = "Number of nodes in the managed node pool."
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "Size of the VMs in the managed node pool."
  type        = string
  default     = "Standard_B2s"
}

variable "os_disk_size_gb" {
  description = "Size of the OS disk in GB for the managed node pool VMs."
  type        = number
  default     = 30
}

variable "vnet_subnet_id" {
  description = "ID of the subnet where the AKS cluster will be deployed."
  type        = string
}


variable "tags" {
  description = "Tags for the AKS cluster and related resources."
  type        = map(string)
  default     = {}
}

variable "admin_group_object_ids" {
  description = "AD Object IDs to be added to the cluster admin group, if not set the current user will be made a cluster administrator."
  type        = list(string)
  nullable    = false
}

variable "route_table_id" {
  description = "ID of the route table."
  type        = string
  nullable    = false
}

variable "route_table_ids" {
  description = "List of route table IDs (used when use_udr = true)."
  type        = list(string)
  default     = []
}

variable "cni" {
  description = "Kubernetes CNI; \"kubenet\", \"azure_overlay\" & \"azure\" are supported."
  type        = string
  nullable    = false
  default     = "kubenet"
}


variable "windows_support" {
  description = "If the Kubernetes cluster should support Windows nodes."
  type        = bool
  nullable    = false
  default     = false
}
variable "podnet_cidr_block" {
  description = "CIDR range for pod IP addresses when using the kubenet network plugin."
  type        = string
  nullable    = false
}

variable "nat_gateway_id" {
  description = "ID of a user-assigned NAT Gateway to use for cluster egress traffic, if not set a cluster managed load balancer will be used."
  type        = string
  nullable    = true
  default     = null
}

variable "managed_outbound_ip_count" {
  description = "Count of desired managed outbound IPs for the cluster managed load balancer. Ignored if NAT gateway is specified, must be between 1 and 100 inclusive."
  type        = number
  nullable    = false
  default     = 1

  validation {
    condition     = var.managed_outbound_ip_count > 0 && var.managed_outbound_ip_count <= 100
    error_message = "Managed outbound IP count must be between 1 and 100 inclusive."
  }
}

variable "managed_outbound_ports_allocated" {
  description = "Number of desired SNAT port for each VM in the cluster managed load balancer. Ignored if NAT gateway is specified, must be between 0 & 64000 inclusive and divisible by 8."
  type        = number
  nullable    = false
  default     = 0

  validation {
    condition     = var.managed_outbound_ports_allocated >= 0 && var.managed_outbound_ports_allocated <= 64000 && (var.managed_outbound_ports_allocated % 8 == 0)
    error_message = "Number of desired SNAT port for each VM must be between 0 & 64000 inclusive and divisible by 8."
  }
}

variable "managed_outbound_idle_timeout" {
  description = "Desired outbound flow idle timeout in seconds for the cluster managed load balancer. Ignored if NAT gateway is specified, must be between 240 and 7200 inclusive."
  type        = number
  nullable    = false
  default     = 240

  validation {
    condition     = var.managed_outbound_idle_timeout >= 240 && var.managed_outbound_idle_timeout <= 7200
    error_message = "Outbound flow idle timeout must be between 240 and 7200 inclusive."
  }
}

variable "oms_agent" {
  description = "If the OMS agent addon should be installed."
  type        = bool
  default     = false
}

variable "oms_agent_log_analytics_workspace_id" {
  description = "ID of the log analytics workspace for the OMS agent."
  type        = string
  default     = ""
}

variable "logging" {
  description = "Logging configuration."
  type = object({
    control_plane = object({
      storage_account = object({
        enabled                       = optional(bool, false)
        id                            = optional(string, null)
        profile                       = optional(string, "all")
        additional_log_category_types = optional(list(string), [])
      })
    })
  })
  nullable = false
}


variable "kms" {
  description = "kms based etcd encryption key id and network access tyoe"
  type = object({
    use_vault_secret_operator = optional(bool, false)
    enable_etcd_encryption    = optional(bool, false)
    key_vault_name            = optional(string, null)
    user_object_ids = optional(object({
      cluster_admin_users  = optional(map(string), {})
      cluster_admin_groups = optional(list(string), [])
      cluster_view_users   = optional(map(string), {})
      cluster_view_groups  = optional(list(string), [])
    }), null)
    github_workflow_sp_object_ids = optional(list(string), [])
    vpn_network_cidr_list         = optional(list(string), [])
    azure_env                     = optional(string, null)
  })
  default = {
    use_vault_secret_operator     = false
    enable_etcd_encryption        = false
    key_vault_name                = null
    user_object_ids               = null
    github_workflow_sp_object_ids = null
    vpn_network_cidr_list         = null
    azure_env                     = null
  }
}

variable "cluster_endpoint_access_cidrs" {
  description = "List of CIDR blocks which can access the Azure Kubernetes Service managed cluster API server endpoint, an empty list will not error but will block public access to the cluster."
  type        = list(string)
  nullable    = false

  validation {
    condition     = length(var.cluster_endpoint_access_cidrs) > 0
    error_message = "Cluster endpoint access CIDRS need to be explicitly set."
  }

  validation {
    condition     = alltrue([for c in var.cluster_endpoint_access_cidrs : can(regex("^(\\d{1,3}).(\\d{1,3}).(\\d{1,3}).(\\d{1,3})\\/(\\d{1,2})$", c))])
    error_message = "Cluster endpoint access CIDRS can only contain valid cidr blocks."
  }
}

variable "cluster_autoscaler" {
  description = "Cluster autoscaler configuration object."
  type = object({
    scale_down_unneeded_time         = number
    scale_down_utilization_threshold = number
  })
  nullable = false
  default = {
    scale_down_unneeded_time         = null
    scale_down_utilization_threshold = 0.5
  }
}

variable "windows_licenced" {
  type        = bool
  description = "Specifies if Windows nodes should be licenced."
  nullable    = false
  default     = false
}

variable "lb_inbound_pool_type_node_ip" {
  type        = bool
  description = "If the load balancer inbound pool type should be node IP."
  nullable    = false
  default     = false
}

variable "virtual_network_id" {
  type        = string
  description = "ID of the virtual network."
  default     = null
}

variable "azure_environment" {
  description = "Azure Cloud Environment."
  type        = string
  nullable    = false
}

variable "use_udr" {
  type        = bool
  description = "specifies if UDR is enabled of not."
  default     = false
}

variable "custom_ca_trust_certificates" {
  type        = map(string)
  description = "A map containing up to 10 base64 encoded CA certificates that will be added to the trust store on nodes."
  default     = {}
}