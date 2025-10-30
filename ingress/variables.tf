variable "cluster_name" {
  description = "The name of the K8s cluster that this is being installed into."
  type        = string
  nullable    = false
}

variable "cluster_version" {
  description = "The Kubernetes version to use for the K8s cluster, expected in the form x.y. Only versions v1.23 and above are supported."
  type        = string
  nullable    = false

  validation {
    condition = (
      length(split(".", var.cluster_version)) == 2 && tonumber(split(".", var.cluster_version)[0]) == 1 && tonumber(split(".", var.cluster_version)[1]) >= 23
    )
    error_message = "Invalid Kubernetes version. The version must be v1.23 or above, in the format x.y."
  }
}

variable "name" {
  description = "Name for the ingress resources."
  type        = string
  nullable    = false
}

variable "namespace" {
  description = "Namespace to create and install into."
  type        = string
  nullable    = false
}

variable "namespace_labels" {
  description = "Labels to add onto namespace."
  type        = map(string)
  nullable    = false
  default     = {}
}

variable "namespace_annotations" {
  description = "Annotations to add onto namespace."
  type        = map(string)
  nullable    = false
  default     = {}
}

variable "cloud" {
  description = "Cloud that this will be run on. AWS and Azure are currently supported."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["aws", "azure"], var.cloud)
    error_message = "This module supports AWS (aws) and Azure (azure)."
  }
}

variable "lb_internal" {
  description = "Specifies if the LB should be internal or not."
  type        = bool
  nullable    = false
}

variable "lb_subnet_ids" {
  description = "IDs for the subnets to create the LB in, defaults to auto-discovery. For Azure you can only specify this as a single value for internal LBs."
  type        = list(string)
  nullable    = false
  default     = []
}

variable "lb_cidrs" {
  description = "CIDR range that the LB is in."
  type        = list(string)
  nullable    = false
  default     = ["0.0.0.0/0"]
}

variable "lb_source_cidrs" {
  description = "CIDR range for allowed LB traffic sources, defaults to the subnets CIDRs for internal LBs & 0.0.0.0/0 for public LBs."
  type        = list(string)
  nullable    = false
  default     = []
}

variable "real_ip_cidrs" {
  description = "CIDR range for the real IP."
  type        = list(string)
  nullable    = true # TODO: Set to false once lb_cidrs is removed
  default     = null # TODO: Set to ["0.0.0.0/0"] once lb_cidrs is removed
}

variable "lb_s3_logs_enabled" {
  description = "If `true` logs will be collected in S3 for the ALB."
  type        = bool
  nullable    = false
  default     = false
}

variable "lb_s3_logs_bucket" {
  description = "S3 bucket for the logs."
  type        = string
  nullable    = false
  default     = ""
}

variable "lb_s3_logs_prefix" {
  description = "S3 bucket prefix for the logs."
  type        = string
  nullable    = false
  default     = ""
}

variable "service_annotations" {
  description = "Annotations to apply to the service."
  type        = map(string)
  nullable    = false
  default     = {}
}

variable "pod_annotations" {
  description = "Annotations to be added to the controller pod"
  type        = map(string)
  default     = {}
}

variable "additional_lb_attributes" {
  description = "Additional attributes to set for the LB (AWS only)."
  type        = map(string)
  nullable    = false
  default     = {}
}

variable "additional_lb_tg_attributes" {
  description = "Additional attributes to set for the LB target group (AWS only)."
  type        = map(string)
  nullable    = false
  default     = {}
}

variable "additional_node_selector" {
  description = "Additional node selector configuration for the controller, to be merged with the default ingress selector."
  type        = map(string)
  nullable    = false
  default     = {}
}

variable "additional_tolerations" {
  description = "Additional tolerations for the controller, to add to the default ingress toleration."
  type        = list(map(string))
  nullable    = false
  default     = []
}

variable "priority_class_name" {
  description = "Priority class name to apply to the controller."
  type        = string
  nullable    = false
  default     = ""
}

variable "termination_grace_period_seconds" {
  description = "Termination grace period in seconds for the controller."
  type        = number
  nullable    = false
  default     = 300
}

variable "min_replicas" {
  description = "Minimum number of controller replicas."
  type        = number
  nullable    = false
  default     = 3
}

variable "max_replicas" {
  description = "Maximum number of controller replicas."
  type        = number
  nullable    = false
  default     = 6
}

variable "controller_memory_request" {
  description = "Optional memory override for the Nginx controller. If not provided, the default value will be used."
  type        = string
  default     = null
}

variable "controller_cpu_request" {
  description = "Optional CPU override for the Nginx controller. If not provided, the default value will be used."
  type        = string
  default     = null
}

variable "controller_memory_limit" {
  description = "Optional memory override for the Nginx controller. If not provided, the default value will be used."
  type        = string
  default     = null
}

variable "controller_cpu_limit" {
  description = "Optional CPU override for the Nginx controller. If not provided, the default value will be used."
  type        = string
  default     = null
}

variable "target_cpu_utilization" {
  description = "Optional CPU utilization for the Nginx controller. If not provided, the default value will be used."
  type        = string
  default     = null
}

variable "default_certificate" {
  description = "Default certificate for ingresses."
  type        = string
  nullable    = false
  default     = ""
}

variable "nginx_config" {
  description = "Additional Nginx config options."
  type        = map(string)
  nullable    = false
  default     = {}
}

variable "nginx_proxy_set_headers" {
  description = "Additional Nginx proxy set headers."
  type        = map(string)
  nullable    = false
  default     = {}
}

variable "nginx_args" {
  description = "Additional Nginx command arguments."
  type        = map(string)
  nullable    = false
  default     = {}
}

variable "nginx_tcp_services" {
  description = "Additional Nginx TCP services configuration."
  type        = map(string)
  nullable    = false
  default     = {}
}

variable "preserve_client_ip" {
  description = "Preserve the client IP (AWS only)."
  type        = bool
  nullable    = false
  default     = false
}

variable "disable_default_backend" {
  description = "Disable the default backend and rely on the controller behaviour for un-mapped requests."
  type        = bool
  nullable    = false
  default     = false
}

variable "backend_arm64" {
  description = "If the backend should run on ARM64 or AMD64 nodes."
  type        = bool
  nullable    = false
  default     = false
}

variable "backend_node_selector" {
  description = "Node selector for the default backend."
  type        = map(string)
  nullable    = false
  default     = {}
}

variable "backend_tolerations" {
  description = "Tolerations for the default backend."
  type        = list(map(string))
  nullable    = false
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  nullable    = false
  default     = {}
}

variable "log_level" {
  description = "Log level."
  type        = string
  nullable    = false
  default     = "WARN"
}

variable "metrics_enabled" {
  description = "Enable metrics"
  type        = bool
  default     = true
}

variable "servicemonitor_enabled" {
  description = "Enable ServiceMonitor"
  type        = bool
  default     = true
}

variable "servicemonitor_labels" {
  description = "Labels to be applied to all Kubernetes resources."
  type        = map(string)
  default = {
    "lnrs.io/grafana-cloud" : "true"
  }
}

variable "disable_proxy_protocol" {
  description = "Disable proxy protocol."
  type        = bool
  default     = true
}

variable "allow_snippet_annotations" {
  description = "Allow annotations to be added to the ingress resources."
  type        = bool
  default     = false
}

variable "webhook_timeout_seconds" {
  description = "Timeout in seconds for the admission webhook."
  type        = number
  default     = 10
}

variable "enable_otel_tracing" {
  description = "Enable Open Telemetry Tracing for Nginx Ingress Controller."
  type        = bool
  default     = false
}

variable "otlp_collector_host" {
  description = "Host of the OTLP collector."
  type        = string
  default     = ""
}

variable "azure_environment" {
  description = "Azure Cloud Environment."
  type        = string
  nullable    = false
}

variable "cgr_images" {
  description = "cgr image type"
  type        = bool
  default     = false
}

variable "fips" {
  description = "If true, the cluster will be created with FIPS 140-2 mode enabled; this can't be changed once the cluster has been created."
  type        = bool
  default     = false
  nullable    = false
}

variable "use_udr" {
  type        = bool
  description = "specifies if UDR is enabled of not."
  nullable    = false
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "specifies resource_group_name."
  default     = null
}

variable "route_table_name" {
  type        = string
  description = "specifies route_table_name."
  default     = null
}