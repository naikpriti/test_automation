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
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.3.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >=0.7.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_key_vault"></a> [key\_vault](#module\_key\_vault) | ../key-vault | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.aks_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_monitor_diagnostic_setting.storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_nat_gateway.nat_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway) | resource |
| [azurerm_nat_gateway_public_ip_association.ip_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway_public_ip_association) | resource |
| [azurerm_public_ip.nat_gateway_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_role_assignment.key_vault_crypto_user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.network_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.network_contributor_route_table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.network_contributor_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.shared_acr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.udr_network_contributor_route_table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.aks_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [random_password.windows_admin_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.windows_admin_username](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [time_sleep.modify](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [azurerm_kubernetes_cluster.aks_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/kubernetes_cluster) | data source |
| [azurerm_kubernetes_service_versions.aks_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/kubernetes_service_versions) | data source |
| [azurerm_monitor_diagnostic_categories.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_diagnostic_categories) | data source |
| [azurerm_public_ips.outbound](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/public_ips) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_group_object_ids"></a> [admin\_group\_object\_ids](#input\_admin\_group\_object\_ids) | AD Object IDs to be added to the cluster admin group, if not set the current user will be made a cluster administrator. | `list(string)` | n/a | yes |
| <a name="input_azure_environment"></a> [azure\_environment](#input\_azure\_environment) | Azure Cloud Environment. | `string` | n/a | yes |
| <a name="input_bootstrap_name"></a> [bootstrap\_name](#input\_bootstrap\_name) | Name of the managed node pool. | `string` | `"bootstrap"` | no |
| <a name="input_cluster_autoscaler"></a> [cluster\_autoscaler](#input\_cluster\_autoscaler) | Cluster autoscaler configuration object. | <pre>object({<br>    scale_down_unneeded_time         = number<br>    scale_down_utilization_threshold = number<br>  })</pre> | <pre>{<br>  "scale_down_unneeded_time": null,<br>  "scale_down_utilization_threshold": 0.5<br>}</pre> | no |
| <a name="input_cluster_endpoint_access_cidrs"></a> [cluster\_endpoint\_access\_cidrs](#input\_cluster\_endpoint\_access\_cidrs) | List of CIDR blocks which can access the Azure Kubernetes Service managed cluster API server endpoint, an empty list will not error but will block public access to the cluster. | `list(string)` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the AKS cluster. | `string` | n/a | yes |
| <a name="input_cni"></a> [cni](#input\_cni) | Kubernetes CNI; "kubenet", "azure\_overlay" & "azure" are supported. | `string` | `"kubenet"` | no |
| <a name="input_custom_ca_trust_certificates"></a> [custom\_ca\_trust\_certificates](#input\_custom\_ca\_trust\_certificates) | A map containing up to 10 base64 encoded CA certificates that will be added to the trust store on nodes. | `map(string)` | `{}` | no |
| <a name="input_kms"></a> [kms](#input\_kms) | kms based etcd encryption key id and network access tyoe | <pre>object({<br>    use_vault_secret_operator = optional(bool, false)<br>    enable_etcd_encryption    = optional(bool, false)<br>    key_vault_name            = optional(string, null)<br>    user_object_ids = optional(object({<br>      cluster_admin_users  = optional(map(string), {})<br>      cluster_admin_groups = optional(list(string), [])<br>      cluster_view_users   = optional(map(string), {})<br>      cluster_view_groups  = optional(list(string), [])<br>    }), null)<br>    github_workflow_sp_object_ids = optional(list(string), [])<br>    vpn_network_cidr_list         = optional(list(string), [])<br>    azure_env                     = optional(string, null)<br>  })</pre> | <pre>{<br>  "azure_env": null,<br>  "enable_etcd_encryption": false,<br>  "github_workflow_sp_object_ids": null,<br>  "key_vault_name": null,<br>  "use_vault_secret_operator": false,<br>  "user_object_ids": null,<br>  "vpn_network_cidr_list": null<br>}</pre> | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Version of Kubernetes to use for the AKS cluster. | `string` | n/a | yes |
| <a name="input_lb_inbound_pool_type_node_ip"></a> [lb\_inbound\_pool\_type\_node\_ip](#input\_lb\_inbound\_pool\_type\_node\_ip) | If the load balancer inbound pool type should be node IP. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region in which to build resources. | `string` | n/a | yes |
| <a name="input_logging"></a> [logging](#input\_logging) | Logging configuration. | <pre>object({<br>    control_plane = object({<br>      storage_account = object({<br>        enabled                       = optional(bool, false)<br>        id                            = optional(string, null)<br>        profile                       = optional(string, "all")<br>        additional_log_category_types = optional(list(string), [])<br>      })<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_maintenance"></a> [maintenance](#input\_maintenance) | Maintenance configuration. | <pre>object({<br>    utc_offset = optional(string, null)<br>    control_plane = optional(object({<br>      frequency    = optional(string, "WEEKLY")<br>      day_of_month = optional(number, 1)<br>      day_of_week  = optional(string, "SUNDAY")<br>      start_time   = optional(string, "00:00")<br>      duration     = optional(number, 4)<br>    }), {})<br>    nodes = optional(object({<br>      frequency    = optional(string, "WEEKLY")<br>      day_of_month = optional(number, 1)<br>      day_of_week  = optional(string, "SUNDAY")<br>      start_time   = optional(string, "00:00")<br>      duration     = optional(number, 4)<br>    }), {})<br>    not_allowed = optional(list(object({<br>      start = string<br>      end   = string<br>    })), [])<br>  })</pre> | `{}` | no |
| <a name="input_managed_outbound_idle_timeout"></a> [managed\_outbound\_idle\_timeout](#input\_managed\_outbound\_idle\_timeout) | Desired outbound flow idle timeout in seconds for the cluster managed load balancer. Ignored if NAT gateway is specified, must be between 240 and 7200 inclusive. | `number` | `240` | no |
| <a name="input_managed_outbound_ip_count"></a> [managed\_outbound\_ip\_count](#input\_managed\_outbound\_ip\_count) | Count of desired managed outbound IPs for the cluster managed load balancer. Ignored if NAT gateway is specified, must be between 1 and 100 inclusive. | `number` | `1` | no |
| <a name="input_managed_outbound_ports_allocated"></a> [managed\_outbound\_ports\_allocated](#input\_managed\_outbound\_ports\_allocated) | Number of desired SNAT port for each VM in the cluster managed load balancer. Ignored if NAT gateway is specified, must be between 0 & 64000 inclusive and divisible by 8. | `number` | `0` | no |
| <a name="input_manual_upgrades"></a> [manual\_upgrades](#input\_manual\_upgrades) | If the AKS cluster should require manual upgrades. | `bool` | `false` | no |
| <a name="input_nat_gateway_id"></a> [nat\_gateway\_id](#input\_nat\_gateway\_id) | ID of a user-assigned NAT Gateway to use for cluster egress traffic, if not set a cluster managed load balancer will be used. | `string` | `null` | no |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | Number of nodes in the managed node pool. | `number` | `1` | no |
| <a name="input_node_os_channel_upgrade"></a> [node\_os\_channel\_upgrade](#input\_node\_os\_channel\_upgrade) | (Optional) The upgrade channel for this Kubernetes Cluster Nodes' OS Image. Possible values are Unmanaged, SecurityPatch, NodeImage and None | `string` | `null` | no |
| <a name="input_oms_agent"></a> [oms\_agent](#input\_oms\_agent) | If the OMS agent addon should be installed. | `bool` | `false` | no |
| <a name="input_oms_agent_log_analytics_workspace_id"></a> [oms\_agent\_log\_analytics\_workspace\_id](#input\_oms\_agent\_log\_analytics\_workspace\_id) | ID of the log analytics workspace for the OMS agent. | `string` | `""` | no |
| <a name="input_os_disk_size_gb"></a> [os\_disk\_size\_gb](#input\_os\_disk\_size\_gb) | Size of the OS disk in GB for the managed node pool VMs. | `number` | `30` | no |
| <a name="input_podnet_cidr_block"></a> [podnet\_cidr\_block](#input\_podnet\_cidr\_block) | CIDR range for pod IP addresses when using the kubenet network plugin. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group. | `string` | n/a | yes |
| <a name="input_route_table_id"></a> [route\_table\_id](#input\_route\_table\_id) | ID of the route table. | `string` | n/a | yes |
| <a name="input_route_table_ids"></a> [route\_table\_ids](#input\_route\_table\_ids) | List of route table IDs (used when use\_udr = true). | `list(string)` | `[]` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | Pricing tier for the Azure Kubernetes Service managed cluster; "free" & "standard" are supported. | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | ID of the subscription being used. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the AKS cluster and related resources. | `map(string)` | `{}` | no |
| <a name="input_use_udr"></a> [use\_udr](#input\_use\_udr) | specifies if UDR is enabled of not. | `bool` | `false` | no |
| <a name="input_virtual_network_id"></a> [virtual\_network\_id](#input\_virtual\_network\_id) | ID of the virtual network. | `string` | `null` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Size of the VMs in the managed node pool. | `string` | `"Standard_B2s"` | no |
| <a name="input_vnet_subnet_id"></a> [vnet\_subnet\_id](#input\_vnet\_subnet\_id) | ID of the subnet where the AKS cluster will be deployed. | `string` | n/a | yes |
| <a name="input_windows_licenced"></a> [windows\_licenced](#input\_windows\_licenced) | Specifies if Windows nodes should be licenced. | `bool` | `false` | no |
| <a name="input_windows_support"></a> [windows\_support](#input\_windows\_support) | If the Kubernetes cluster should support Windows nodes. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | n/a |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | n/a |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | n/a |
| <a name="output_cluster_identity"></a> [cluster\_identity](#output\_cluster\_identity) | User assigned identity used by the cluster. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of cluster |
| <a name="output_cluster_version_full"></a> [cluster\_version\_full](#output\_cluster\_version\_full) | Full Kubernetes version of the cluster. |
| <a name="output_effective_outbound_ips"></a> [effective\_outbound\_ips](#output\_effective\_outbound\_ips) | Outbound IPs from the Azure Kubernetes Service cluster managed load balancer (this will be an empty array if the cluster is uisng a user-assigned NAT Gateway). |
| <a name="output_kubelet_identity"></a> [kubelet\_identity](#output\_kubelet\_identity) | User assigned identity used by the Kubelet. |
| <a name="output_kubelet_object_id"></a> [kubelet\_object\_id](#output\_kubelet\_object\_id) | User assigned identity used by the Kubelet. |
| <a name="output_latest_version_full"></a> [latest\_version\_full](#output\_latest\_version\_full) | Latest full Kubernetes version the cluster could be on. |
| <a name="output_node_resource_group_name"></a> [node\_resource\_group\_name](#output\_node\_resource\_group\_name) | Auto-generated resource group which contains the resources for this managed Kubernetes cluster. |
| <a name="output_oidc_issuer_url"></a> [oidc\_issuer\_url](#output\_oidc\_issuer\_url) | URL for the cluster OpenID Connect identity provider. |
| <a name="output_oms_agent_identity"></a> [oms\_agent\_identity](#output\_oms\_agent\_identity) | Identity that the OMS agent uses. |
<!-- END_TF_DOCS -->