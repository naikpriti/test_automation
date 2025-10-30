variable "create_script_path" {
  type        = string
  description = "Path to the create script to run."
  nullable    = false
}

variable "delete_script_path" {
  type        = string
  description = "Path to the delete script to run."
  default     = null
  nullable    = true
}

variable "environment" {
  type        = map(string)
  description = "Environment for the script run."
  nullable    = false
}

variable "read_script_path" {
  type        = string
  description = "Path to the read script to run."
  default     = null
  nullable    = true
}

variable "triggers" {
  type        = map(any)
  description = "Triggers for resource."
  nullable    = false
}

variable "update_script_path" {
  type        = string
  description = "Path to the update script to run."
  default     = null
  nullable    = true
}