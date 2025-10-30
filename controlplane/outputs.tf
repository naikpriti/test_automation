output "cluster_id" {
  value = azurerm_kubernetes_cluster.aks_cluster.id
}
output "cluster_endpoint" {
  value     = azurerm_kubernetes_cluster.aks_cluster.kube_config[0].host
  sensitive = true
}
output "cluster_certificate_authority_data" {
  value     = azurerm_kubernetes_cluster.aks_cluster.kube_config[0].cluster_ca_certificate
  sensitive = true
}
output "oidc_issuer_url" {
  description = "URL for the cluster OpenID Connect identity provider."
  value       = azurerm_kubernetes_cluster.aks_cluster.oidc_issuer_url
}
output "cluster_identity" {
  description = "User assigned identity used by the cluster."
  value       = azurerm_user_assigned_identity.aks_identity
}

output "cluster_name" {
  description = "Name of cluster"
  value       = azurerm_kubernetes_cluster.aks_cluster.name
}

output "kubelet_identity" {
  description = "User assigned identity used by the Kubelet."
  value       = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0]
}
output "kubelet_object_id" {
  description = "User assigned identity used by the Kubelet."
  value       = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
}

output "node_resource_group_name" {
  description = "Auto-generated resource group which contains the resources for this managed Kubernetes cluster."
  value       = azurerm_kubernetes_cluster.aks_cluster.node_resource_group
}
output "cluster_version_full" {
  description = "Full Kubernetes version of the cluster."
  value       = startswith(data.azurerm_kubernetes_cluster.aks_cluster.current_kubernetes_version, var.kubernetes_version) ? data.azurerm_kubernetes_cluster.aks_cluster.current_kubernetes_version : data.azurerm_kubernetes_service_versions.aks_cluster.latest_version
}

output "latest_version_full" {
  description = "Latest full Kubernetes version the cluster could be on."
  value       = data.azurerm_kubernetes_service_versions.aks_cluster.latest_version
}
output "oms_agent_identity" {
  description = "Identity that the OMS agent uses."
  value       = var.oms_agent ? azurerm_kubernetes_cluster.aks_cluster.oms_agent[0].oms_agent_identity : null
}

output "effective_outbound_ips" {
  description = "Outbound IPs from the Azure Kubernetes Service cluster managed load balancer (this will be an empty array if the cluster is uisng a user-assigned NAT Gateway)."
  value       = [for ip in data.azurerm_public_ips.outbound.public_ips : ip.ip_address]
}
