# data "azapi_resource_list" "node_groups" {
#   type                   = local.agent_pool_type
#   parent_id              = var.cluster_id
#   response_export_values = { names = "value[].name" }
# }