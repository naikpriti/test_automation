# K8s NGINX Ingress Controller Terraform Module

## Overview

This module creates a [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/) backed by a cloud load balancer and linked to an `IngressClass` via the [Helm chart](https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx) on a _Kubernetes_ cluster that has been created by either the [AWS EKS Terraform Module](https://github.com/LexisNexis-RBA/rsg-terraform-aws-eks) or the [Azure Kubernetes Service (AKS) Terraform Module](https://github.com/LexisNexis-RBA/rsg-terraform-azurerm-aks).

For _AWS_ this module makes use of the [NLB IP](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/service/nlb/) pattern in the [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/) to route traffic directly to pods using the proxy protocol v2.

For _Azure_ this module creates a [Standard Load Balancer](https://docs.microsoft.com/en-us/azure/aks/load-balancer-standard/); additional annotation can be found in the [docs](https://docs.microsoft.com/en-us/azure/aks/load-balancer-standard#additional-customizations-via-kubernetes-annotations).

---

## Support Policy

Support for this module **isn't** operational; by using this module you're agreeing that operational support will be provided to your end-users by your cluster operators and that the core engineering team will only interact with these operational teams.

For further support, you can open an issue on this project or write a post in the `Support` channel on the [OG-RBA Kubernetes Working Group](https://teams.microsoft.com/l/channel/19%3a5fd10c8b87ed4d0385657556bebfd625%40thread.skype/Support?groupId=dc4762e6-314d-4645-9919-bff7cc54b91c&tenantId=9274ee3f-9425-4109-a27f-9fb15c10675d).

### General Help

Before using this module, the whole README should be read and you should be familiar with the concepts in the [RSG Kubernetes Documentation](https://legendary-doodle-a57ed2c8.pages.github.io/).

If you have unanswered questions after reading the documentation, please visit [RSG Kubernetes Discussions](https://github.com/LexisNexis-RBA/rsg-kubernetes/discussions) where you can either join an existing discussion or start your own.

---

## Usage

### Subnet Auto-discovery

Although the module supports subnet auto-discovery for load balancer placement, this approach should be avoided if possible. For AWS list of subnet IDs should be passed into the module inputs using the `lb_subnet_ids` argument to explicitly define which subnets the cloud load balancer should be created in. For Azure a single subnet ID should be passed in when creating internal load balancers. Where possible, the selected subnets should be the same as the ones used for ingress node placement.

When auto-discovery is used in AWS, you will need to ensure the [requirements] have been satisfied before [deployment](https://aws.amazon.com/premiumsupport/knowledge-center/eks-vpc-subnet-discovery/).

### Controller Custom Memory

The `controller_memory_override` input variable enables users to optionally set a custom memory value for the Nginx controller. This value will be applied to both the memory limit and request, providing greater control over resource allocation for the Nginx controller. If a custom value is not provided, the default value will be used.

### Example AWS

```terraform
module "ingress_nginx_private" {
  source = "git::https://github.com/LexisNexis-RBA/rsg-terraform-kubernetes-ingress-nginx.git?ref=v1.6.0"

  cluster_name    = "my-cluster"
  cluster_version = "1.23"  

  name      = "ingress-private"
  namespace = "ingress-private"

  cloud = "aws"

  lb_internal     = true
  lb_subnet_ids   = data.aws_subnet_ids.public.ids
  lb_cidrs        = ["10.53.4.0/22"]
  lb_source_cidrs = ["10.0.0.0/8"]

  tags = {
    my-tag = "test"
  }
}
```

### Example Azure

```terraform
module "ingress_nginx_private" {
  source = "git::https://github.com/LexisNexis-RBA/rsg-terraform-kubernetes-ingress-nginx.git?ref=v1.6.0"

  cluster_name    = "my-cluster"
  cluster_version = "1.23"

  name      = "ingress-private"
  namespace = "ingress-private"

  cloud = "azure"

  lb_internal     = true
  lb_source_cidrs = ["10.0.0.0/8"]

  tags = {
    my-tag = "test"
  }
}
```

## Requirements

This module requires the following versions to be configured in the workspace `terraform {}` block.

### Terraform

| **Version**          |
| :------------------- |
| `>= 1.3.3, != 1.3.4` |

### Providers

| **Name**                                                                          | **Version** |
| :-------------------------------------------------------------------------------- | :---------- |
| [Helm](https://registry.terraform.io/providers/hashicorp/helm/latest)             | `>= 2.9.0`  |
| [Kubectl](https://registry.terraform.io/providers/alekc/kubectl/latest)     | `>= 1.14.0` |
| [Kubernetes](https://registry.terraform.io/providers/hashicorp/kubernetes/latest) | `>= 2.19.0` |

## Variables

This module exposes the following variables.

| **Variable**                       | **Description**                                                                                                                                                                                                                                                                                         | **Type**            | **Default**     |
| :--------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | :------------------ | :-------------- |
| `cluster_name`                     | The name of the K8s cluster that this is being installed into.                                                                                                                                                                                                                                          | `string`            | `null`          |
| `cluster_version`                  | The Kubernetes version to use for the K8s cluster, expected in the form `x.y`. Only versions `v1.23` above are supported.                                                                                                                                                                               | `string`            | `null`          |
| `name`                             | Name for the ingress resources.                                                                                                                                                                                                                                                                         | `string`            | `null`          |
| `namespace`                        | Namespace to create and install into.                                                                                                                                                                                                                                                                   | `string`            | `null`          |
| `namespace_labels`                 | Labels to add onto namespace.                                                                                                                                                                                                                                                                           | `map(string)`       | `{}`            |
| `namespace_annotations`            | Annotations to add onto namespace.                                                                                                                                                                                                                                                                      | `map(string)`       | `{}`            |
| `cloud`                            | Cloud that this will be run on. AWS and Azure are currently supported.                                                                                                                                                                                                                                  | `string`            | `null`          |
| `lb_internal`                      | Specifies if the LB should be internal or not.                                                                                                                                                                                                                                                          | `bool`              | `null`          |
| `lb_subnet_ids`                    | IDs for the subnets to create the LB in, defaults to auto-discovery. For Azure you can only specify this as a single value for internal LBs.                                                                                                                                                            | `list(string)`      | `[]`            |
| `lb_cidrs`                         | CIDR range that the LB is in.                                                                                                                                                                                                                                                                           | `list(string)`      | `["0.0.0.0/0"]` |
| `lb_source_cidrs`                  | CIDR range for allowed LB traffic sources, defaults to the subnets CIDRs for internal LBs & `0.0.0.0/0` for public LBs.                                                                                                                                                                                 | `list(string)`      | `[]`            |
| `lb_s3_logs_enabled`               | If `true` logs will be collected in S3 for the internal ingress (AWS only).                                                                                                                                                                                                                             | `bool`              | `false`         |
| `lb_s3_logs_bucket`                | S3 bucket for the logs (AWS only).                                                                                                                                                                                                                                                                      | `string`            | `""`            |
| `lb_s3_logs_prefix`                | S3 bucket prefix for the logs (AWS only).                                                                                                                                                                                                                                                               | `string`            | `""`            |
| `service_annotations`              | Annotations to apply to the service.                                                                                                                                                                                                                                                                    | `map(string)`       | `{}`            |
| `pod_annotations`                  | Annotations to be added to the controller pod.                                                                                                                                                                                                                                                          | `map(string)`       | `{}`            |
| `additional_lb_attributes`         | Additional attributes to set for the LB (AWS only).                                                                                                                                                                                                                                                     | `map(string)`       | `{}`            |
| `additional_lb_tg_attributes`      | Additional attributes to set for the LB target group (AWS only).                                                                                                                                                                                                                                        | `map(string)`       | `{}`            |
| `additional_node_selector`         | Additional node selector configuration for the controller, to be merged with the default ingress selector.                                                                                                                                                                                              | `map(string)`       | `{}`            |
| `additional_tolerations`           | Additional tolerations for the controller, to add to the default ingress toleration.                                                                                                                                                                                                                    | `list(map(string))` | `[]`            |
| `priority_class_name`              | Priority class name to apply to the controller.                                                                                                                                                                                                                                                         | `string`            | `""`            |
| `termination_grace_period_seconds` | Termination grace period in seconds for the controller, use this if deploying to spot nodes. If this value is set below `240` we will default the `worker-shutdown-timeout` config option to the same value, but in this case the `worker-shutdown-timeout` config option should be explicitly set. set | `number`            | `300`           |
| `min_replicas`                     | Minimum number of controller replicas.                                                                                                                                                                                                                                                                  | `number`            | `3`             |
| `max_replicas`                     | Maximum number of controller replicas.                                                                                                                                                                                                                                                                  | `number`            | `6`             |
| `controller_memory_override`       | Optional memory override for the Nginx controller. If not provided, the default value of will be used.                                                                                                                                                                                                  | `string`            | `null`          |
| `default_certificate`              | Default certificate for ingresses.                                                                                                                                                                                                                                                                      | `string`            | `""`            |
| `nginx_config`                     | Additional Nginx config options.                                                                                                                                                                                                                                                                        | `map(string)`       | `{}`            |
| `nginx_proxy_set_headers`          | Additional Nginx proxy set headers.                                                                                                                                                                                                                                                                     | `map(string)`       | `{}`            |
| `nginx_args`                       | Additional Nginx command arguments.                                                                                                                                                                                                                                                                     | `map(string)`       | `{}`            |
| `nginx_tcp_services`               | Additional Nginx TCP services configuration.                                                                                                                                                                                                                                                            | `map(string)`       | `{}`            |
| `preserve_client_ip`               | Preserve the client IP (AWS only).                                                                                                                                                                                                                                                                      | `bool`              | `false`         |
| `disable_default_backend`          | Disable the default backend and rely on the controller behaviour for un-mapped requests. This is required to be `true` if the chart is being installed on a Windows only K8s cluster.                                                                                                                   | `bool`              | `false`         |
| `backend_arm64`                    | If the backend should run on ARM64 or AMD64 nodes.                                                                                                                                                                                                                                                      | `bool`              | `false`         |
| `backend_node_selector`            | Node selector for the default backend.                                                                                                                                                                                                                                                                  | `map(string)`       | `{}`            |
| `backend_tolerations`              | Tolerations for the default backend.                                                                                                                                                                                                                                                                    | `list(map(string))` | `[]`            |
| `tags`                             | Tags to apply to all resources.                                                                                                                                                                                                                                                                         | `map(string)`       | `{}`            |

## Outputs

| **Variable**    | **Description**                                     | **Type** |
| :-------------- | :-------------------------------------------------- | :------- |
| `ingress_class` | `IngressClass` name to use on `Ingress` resources.. | `string` |
