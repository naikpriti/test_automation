<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.6 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >= 2.1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.36.0, < 5.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.3.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.7.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.36.0, < 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bootstrap_node_group_hack"></a> [bootstrap\_node\_group\_hack](#module\_bootstrap\_node\_group\_hack) | ./modules/bootstrap-node-group-hack | n/a |
| <a name="module_system_node_groups"></a> [system\_node\_groups](#module\_system\_node\_groups) | ./modules/node-group | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_proximity_placement_group.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/proximity_placement_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | Availability zones to use for the node groups. | `list(number)` | n/a | yes |
| <a name="input_bootstrap_name"></a> [bootstrap\_name](#input\_bootstrap\_name) | Name to use for the bootstrap node group. | `string` | n/a | yes |
| <a name="input_bootstrap_vm_size"></a> [bootstrap\_vm\_size](#input\_bootstrap\_vm\_size) | VM size to use for the bootstrap node group. | `string` | `"Standard_B2s"` | no |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | ID of the Azure Kubernetes managed cluster. | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the Azure Kubernetes managed cluster. | `string` | n/a | yes |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | The full Kubernetes version of the Azure Kubernetes managed cluster. | `string` | n/a | yes |
| <a name="input_cni"></a> [cni](#input\_cni) | Kubernetes CNI, "kubenet" & "azure" are supported. | `string` | `"kubenet"` | no |
| <a name="input_experimental"></a> [experimental](#input\_experimental) | Provide experimental feature flag configuration. | <pre>object({<br>    arm64                = bool<br>    node_group_os_config = bool<br>    azure_cni_max_pods   = bool<br>  })</pre> | <pre>{<br>  "arm64": false,<br>  "azure_cni_max_pods": false,<br>  "node_group_os_config": false<br>}</pre> | no |
| <a name="input_fips"></a> [fips](#input\_fips) | If true, the cluster will be created with FIPS 140-2 mode enabled; this can't be changed once the cluster has been created. | `bool` | `false` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to be applied to all Kubernetes resources. | `map(string)` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region in which to build resources. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Resource Group to deploy the AKS cluster service to, must already exist. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | ID of the subnet to use for the node groups. | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | ID of the subscription being used. | `string` | n/a | yes |
| <a name="input_system_nodes"></a> [system\_nodes](#input\_system\_nodes) | System node group to configure. | <pre>object({<br>    node_arch         = optional(string, "amd64")<br>    node_size         = optional(string, "large")<br>    node_type         = optional(string, "gp")<br>    node_type_version = optional(string, "v1")<br>    min_capacity      = optional(number, 2)<br>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. | `map(string)` | n/a | yes |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Timeout configuration. | <pre>object({<br>    node_group_create = number<br>    node_group_update = number<br>    node_group_read   = number<br>    node_group_delete = number<br>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->