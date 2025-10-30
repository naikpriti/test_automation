<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.6 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.36.0, < 5.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.3.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >=0.7.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.36.0, < 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_user_node_groups"></a> [user\_node\_groups](#module\_user\_node\_groups) | ./modules/node-group | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_proximity_placement_group.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/proximity_placement_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | Availability zones to use for the node groups. | `list(number)` | n/a | yes |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | ID of the Azure Kubernetes managed cluster. | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the Azure Kubernetes managed cluster. | `string` | n/a | yes |
| <a name="input_cluster_version_full"></a> [cluster\_version\_full](#input\_cluster\_version\_full) | The full Kubernetes version of the Azure Kubernetes managed cluster. | `string` | n/a | yes |
| <a name="input_cni"></a> [cni](#input\_cni) | Kubernetes CNI, "kubenet" & "azure" are supported. | `string` | n/a | yes |
| <a name="input_experimental"></a> [experimental](#input\_experimental) | Provide experimental feature flag configuration. | <pre>object({<br>    arm64                = bool<br>    node_group_os_config = bool<br>    azure_cni_max_pods   = bool<br>  })</pre> | <pre>{<br>  "arm64": false,<br>  "azure_cni_max_pods": false,<br>  "node_group_os_config": false<br>}</pre> | no |
| <a name="input_fips"></a> [fips](#input\_fips) | If true, the cluster will be created with FIPS 140-2 mode enabled; this can't be changed once the cluster has been created. | `bool` | `false` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to be applied to all Kubernetes resources. | `map(string)` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region in which to build resources. | `string` | n/a | yes |
| <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups) | Node groups to configure. | <pre>map(object({<br>    node_arch         = optional(string, "amd64")<br>    node_os           = optional(string, "ubuntu")<br>    node_type         = optional(string, "gp")<br>    node_type_variant = optional(string, "default")<br>    node_type_version = optional(string, "v1")<br>    node_size         = string<br>    ultra_ssd         = optional(bool, false)<br>    os_disk_size      = optional(number, 64)<br>    temp_disk_mode    = optional(string, "NONE")<br>    nvme_mode         = optional(string, "NONE")<br>    os_config = optional(object({<br>      sysctl = map(any)<br>    }), { sysctl = {} })<br>    kubelet_config = optional(object({<br>      cpu_manager_policy        = optional(string, null)<br>      container_log_max_line    = optional(number, null)<br>      container_log_max_size_mb = optional(number, null)<br>    }), null)<br>    placement_group_key = optional(string, null)<br>    spot_capacity       = optional(bool, false)<br>    single_group        = optional(bool, false)<br>    min_capacity        = optional(number, 0)<br>    max_capacity        = number<br>    max_pods            = number<br>    upgrade_settings = optional(object({<br>      max_surge          = optional(string, null) # Set to optional(string, "10%") after max_surge removed<br>      drain_timeout      = optional(number, null)<br>      node_soak_duration = optional(number, null)<br>      }), {<br>      max_surge          = "10%"<br>      drain_timeout      = 0<br>      node_soak_duration = 0<br>    })<br>    max_surge = optional(string, "10%") # Set upgrade_settings.max_surge defualt to 10% after max_surge removed<br>    labels    = optional(map(string), {})<br>    taints = optional(list(object({<br>      key    = string<br>      value  = string<br>      effect = string<br>    })), [])<br>    tags                          = optional(map(string), {})<br>    capacity_reservation_group_id = optional(string, null)<br>  }))</pre> | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Resource Group to deploy the AKS cluster service to, must already exist. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | ID of the subnet to use for the node groups. | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | ID of the subscription being used. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. | `map(string)` | n/a | yes |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Timeout configuration. | <pre>object({<br>    node_group_create = number<br>    node_group_update = number<br>    node_group_read   = number<br>    node_group_delete = number<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ingress_node_group"></a> [ingress\_node\_group](#output\_ingress\_node\_group) | Flag to denote if ingress node group is present in node\_groups. |
<!-- END_TF_DOCS -->