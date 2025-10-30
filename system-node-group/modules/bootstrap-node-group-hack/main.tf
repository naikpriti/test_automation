resource "time_sleep" "bootstrap_node_group_delete_delay" {
  create_duration = "30s"
}

resource "azapi_resource_action" "bootstrap_node_group_delete" {
  method           = "DELETE"
  query_parameters = { "ignore-pod-disruption-budget" = ["true"] }
  resource_id      = local.node_pool_id
  type             = local.agent_pool_type
  when             = "apply"

  depends_on = [time_sleep.bootstrap_node_group_delete_delay]

  lifecycle {
    ignore_changes = all
  }
}

resource "azapi_resource_action" "bootstrap_node_group_recreate" {
  body        = local.node_pool_body
  method      = "PUT"
  resource_id = local.node_pool_id
  type        = local.agent_pool_type
  when        = "destroy"

  lifecycle {
    ignore_changes = all
  }
}