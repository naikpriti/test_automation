resource "kubernetes_namespace" "default" {
  metadata {
    name = var.namespace

    labels = merge(var.namespace_labels, var.cloud == "aws" ? {
      "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled"
      } : {}, {
      name = var.namespace
    })

    annotations = var.namespace_annotations
  }
}

/* resource "kubectl_manifest" "resource_files" {
  for_each = local.resource_files

  yaml_body = file(each.value)

  server_side_apply = true

  depends_on = [
    kubernetes_namespace.default
  ]
} */

/* resource "kubectl_manifest" "resource_objects" {
  for_each = local.resource_objects

  yaml_body = yamlencode(each.value)

  server_side_apply = true

  depends_on = [
    kubernetes_namespace.default
  ]
} */

resource "helm_release" "default" {
  name      = var.name
  namespace = var.namespace

  repository = "https://kubernetes.github.io/ingress-nginx/"
  chart      = "ingress-nginx"
  version    = local.chart_version
  skip_crds  = true

  timeout = local.chart_timeout

  values = [
    yamlencode(local.chart_values)
  ]

  depends_on = [
    kubernetes_namespace.default
  ]
}

/* resource "kubernetes_config_map_v1_data" "terraform_modules" {
  metadata {
    name      = "terraform-modules"
    namespace = "default"
  }

  data = {
    (local.module_name) = local.module_version
  }

  field_manager = local.module_name

  depends_on = [
    helm_release.default
  ]
} */

data "kubernetes_service" "ingress_service" {
  count = var.use_udr && !var.lb_internal ? 1 : 0

  metadata {
    name      = "${var.name}-ingress-nginx-controller"
    namespace = var.namespace
  }

  depends_on = [helm_release.default]
}

resource "azurerm_route" "udr_route" {
  count                  = var.use_udr && !var.lb_internal ? 1 : 0
  name                   = "route-to-internet"
  resource_group_name    = var.resource_group_name
  route_table_name       = var.route_table_name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = data.kubernetes_service.ingress_service[0].status[0].load_balancer[0].ingress[0].ip

  depends_on = [data.kubernetes_service.ingress_service]
}