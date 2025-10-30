locals {
  agent_pool_type = "Microsoft.ContainerService/managedClusters/agentPools@${local.api_version}"
  api_version     = "2024-09-01"
  node_pool_body = {
    properties = {
      orchestratorVersion    = ""
      count                  = 1
      vmSize                 = var.bootstrap_vm_size
      osType                 = "Linux"
      mode                   = "System"
      osDiskType             = "Managed"
      vnetSubnetID           = var.subnet_id
      enableFIPS             = var.fips
      enableEncryptionAtHost = true
    }
  }
  node_pool_id = "${var.cluster_id}/agentPools/${var.bootstrap_name}"
}