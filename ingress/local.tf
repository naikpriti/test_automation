locals {
  module_name    = "terraform-kubernetes-ingress-nginx"
  module_version = "1.20.0"
  chart_version  = "4.13.3"

  chart_timeout         = 1800
  cluster_version_minor = tonumber(regex("^1\\.(\\d+)", var.cluster_version)[0])
  chart_values = {
    commonLabels = local.labels

    controller = {
      service = {
        annotations = merge(
          var.service_annotations,
          var.cloud == "aws" && length(var.lb_subnet_ids) > 0 ? { "service.beta.kubernetes.io/aws-load-balancer-subnets" = join(",", var.lb_subnet_ids) } : {},
          var.cloud == "aws" ? {
            "service.beta.kubernetes.io/aws-load-balancer-type"                     = "external"
            "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type"          = "ip"
            "service.beta.kubernetes.io/aws-load-balancer-scheme"                   = var.lb_internal ? "internal" : "internet-facing"
            "service.beta.kubernetes.io/aws-load-balancer-backend-protocol"         = "tcp"
            "service.beta.kubernetes.io/aws-load-balancer-proxy-protocol"           = "*"
            "service.beta.kubernetes.io/aws-load-balancer-attributes"               = join(",", [for k, v in local.lb_attributes : "${k}=${v}"])
            "service.beta.kubernetes.io/aws-load-balancer-target-group-attributes"  = join(",", [for k, v in local.lb_tg_attributes : "${k}=${v}"])
            "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = join(",", [for k, v in local.tags : "${k}=${v}"])
          } : {},
          var.cloud == "azure" ? { "service.beta.kubernetes.io/azure-load-balancer-internal" = var.lb_internal ? "true" : "false" } : {},
          var.cloud == "azure" && var.lb_internal && length(var.lb_subnet_ids) == 1 ? { "service.beta.kubernetes.io/azure-load-balancer-internal-subnet" = var.lb_subnet_ids[0] } : {}
        )

        type = "LoadBalancer"

        externalTrafficPolicy = var.cloud == "aws" ? "" : "Local"

        loadBalancerSourceRanges = length(var.lb_source_cidrs) > 0 ? var.lb_source_cidrs : null

        enableHttps = true
        enableHttp  = true
      }

      metrics = {
        enabled = var.metrics_enabled

        serviceMonitor = {
          enabled = var.servicemonitor_enabled

          additionalLabels = var.servicemonitor_labels
        }
      }

      nodeSelector = merge(var.additional_node_selector, {
        "lnrs.io/tier"     = var.use_udr ? (var.lb_internal ? "ingress" : "ingress_public") : "ingress"
        "kubernetes.io/os" = "linux"
      })

      tolerations = var.use_udr ? (
        var.lb_internal ? concat([{
          key      = "ingress"
          operator = "Exists"
          effect   = "NoSchedule"
          }], var.additional_tolerations) : concat([{
          key      = "ingress_public"
          operator = "Exists"
          effect   = "NoSchedule"
        }], var.additional_tolerations)
        ) : concat([{
          key      = "ingress"
          operator = "Exists"
          effect   = "NoSchedule"
      }], var.additional_tolerations)


      podAnnotations = var.pod_annotations

      affinity = {
        podAntiAffinity = {
          preferredDuringSchedulingIgnoredDuringExecution = [
            {
              podAffinityTerm = {
                topologyKey = "kubernetes.io/hostname"
                labelSelector = {
                  matchLabels = {
                    "app.kubernetes.io/name"      = "ingress-nginx"
                    "app.kubernetes.io/instance"  = var.name
                    "app.kubernetes.io/component" = "controller"
                  }
                }
              }
              weight = 100
          }]
        }
      }

      topologySpreadConstraints = [{
        maxSkew            = 1
        topologyKey        = "topology.kubernetes.io/zone"
        whenUnsatisfiable  = "ScheduleAnyway"
        nodeAffinityPolicy = "Honor"
        nodeTaintsPolicy   = "Honor"
        labelSelector = {
          matchLabels = {
            "app.kubernetes.io/name"      = "ingress-nginx"
            "app.kubernetes.io/instance"  = var.name
            "app.kubernetes.io/component" = "controller"
          }
        }
      }]
      unhealthyPodEvictionPolicy = "AlwaysAllow"
      priorityClassName          = var.priority_class_name

      terminationGracePeriodSeconds = var.termination_grace_period_seconds

      resources = {
        requests = {
          cpu    = coalesce(var.controller_cpu_request, "200m")
          memory = coalesce(var.controller_memory_request, "256Mi")
        }

        limits = {
          cpu    = coalesce(var.controller_cpu_limit, "1000m")
          memory = coalesce(var.controller_memory_limit, "256Mi")
        }
      }

      autoscaling = {
        enabled                           = true
        minReplicas                       = var.min_replicas
        maxReplicas                       = var.max_replicas
        targetCPUUtilizationPercentage    = coalesce(var.target_cpu_utilization, "80")
        targetMemoryUtilizationPercentage = null
      }
      updateStrategy = {
        type = "RollingUpdate"
        rollingUpdate = {
          maxSurge       = "100%"
          maxUnavailable = "34%"
        }
      }

      minAvailable = var.min_replicas > 1 ? "66%" : "0"

      ingressClassResource = {
        enabled         = true
        name            = var.name
        default         = false
        controllerValue = "k8s.io/nginx-${var.name}"
        parameters      = {}
      }
      image        = merge(local.ingress_controller_image_config, { pullPolicy = "IfNotPresent" })
      ingressClass = ""

      config = merge({
        "error-log-level"              = local.log_level_lookup[var.log_level]
        "server-name-hash-bucket-size" = "256"
        "server-tokens"                = "false"
        "strict-validate-path-type"    = "true"
        "use-forwarded-headers"        = "true"
        "worker-shutdown-timeout"      = var.termination_grace_period_seconds >= 240 ? "240" : tostring(var.termination_grace_period_seconds)
        },
        var.nginx_config,
        { "proxy-real-ip-cidr" = join(",", coalesce(var.real_ip_cidrs, var.lb_cidrs)) },
        var.cloud == "aws" ? { "use-proxy-protocol" = "true" } : {},
        var.cloud == "azure" ? { "use-proxy-protocol" = var.lb_internal || var.disable_proxy_protocol ? "false" : "true" } : {},
        var.enable_otel_tracing ? {
          "enable-opentelemetry" = "true"
          "otel-sampler"         = "AlwaysOn",
          "otel-service-name"    = "nginx-ingress",
          "otlp-collector-host"  = coalesce(length(trimspace(var.otlp_collector_host)) > 0 ? var.otlp_collector_host : null, "k8s-monitoring-grafana-agent.grafana-alloy.svc.cluster.local"),
          "otlp-collector-port"  = "4317"
        } : {}
      )

      proxySetHeaders = merge({
        "Referrer-Policy" = "strict-origin-when-cross-origin"
      }, var.nginx_proxy_set_headers)

      extraArgs = merge({
        "v"                           = local.klog_level_lookup[var.log_level]
        "enable-ssl-chain-completion" = "false"
        }, length(var.default_certificate) > 0 ? {
        "default-ssl-certificate" = var.default_certificate
      } : {}, var.nginx_args)

      allowSnippetAnnotations     = var.allow_snippet_annotations
      enableAnnotationValidations = "true"

      admissionWebhooks = {
        port           = 10250
        timeoutSeconds = var.webhook_timeout_seconds

        patch = {
          nodeSelector = {
            "kubernetes.io/os" = "linux"
            "lnrs.io/tier"     = "system"
          }

          tolerations = concat([{
            key      = "system"
            operator = "Exists"
            }], var.cloud == "azure" ? [{
            key      = "CriticalAddonsOnly"
            operator = "Exists"
          }] : [])
        }
      }
    }

    defaultBackend = {
      enabled = !var.disable_default_backend

      image = merge(local.ingress_custom_error_pages_image_config, { pullPolicy = "IfNotPresent" })

      replicaCount = 3
      minAvailable = 1

      nodeSelector = merge(var.backend_node_selector, {
        "kubernetes.io/os"   = "linux"
        "kubernetes.io/arch" = var.backend_arm64 ? "arm64" : "amd64"
      })

      tolerations = var.backend_tolerations


      affinity = {
        podAntiAffinity = {
          preferredDuringSchedulingIgnoredDuringExecution = [
            {
              podAffinityTerm = {
                topologyKey = "kubernetes.io/hostname"
                labelSelector = {
                  matchLabels = {
                    "app.kubernetes.io/name"      = "ingress-nginx"
                    "app.kubernetes.io/instance"  = var.name
                    "app.kubernetes.io/component" = "default-backend"
                  }
                }
              }
              weight = 100
          }]
        }
      }

      priorityClassName : var.priority_class_name
      topologySpreadConstraints = [{
        maxSkew            = 1
        topologyKey        = "topology.kubernetes.io/zone"
        whenUnsatisfiable  = "ScheduleAnyway"
        nodeAffinityPolicy = "Honor"
        nodeTaintsPolicy   = "Honor"
        labelSelector = {
          matchLabels = {
            "app.kubernetes.io/name"      = "ingress-nginx"
            "app.kubernetes.io/instance"  = var.name
            "app.kubernetes.io/component" = "default-backend"
          }
        }
      }]
      unhealthyPodEvictionPolicy = "AlwaysAllow"
      resources = {
        requests = {
          cpu    = "100m"
          memory = "32Mi"
        }

        limits = {
          cpu    = "1000m"
          memory = "32Mi"
        }
      }
    }

    tcp = var.nginx_tcp_services
  }

  lb_identifier = "${var.cluster_name}-nginx-${var.name}"

  lb_attributes = merge(var.additional_lb_attributes, var.lb_s3_logs_enabled ? {
    "access_logs.s3.enabled" = var.lb_s3_logs_enabled
    "access_logs.s3.bucket"  = var.lb_s3_logs_bucket
    "access_logs.s3.prefix"  = var.lb_s3_logs_prefix == "" ? local.lb_identifier : "${var.lb_s3_logs_prefix}/${local.lb_identifier}"
  } : {})

  lb_tg_attributes = merge(var.additional_lb_tg_attributes, {
    "preserve_client_ip.enabled" = var.preserve_client_ip
  })

  labels = {
    "lnrs.io/k8s-platform" = "true"
  }

  tags = merge(var.tags, {
    "lnrs.io/terraform"                         = "true"
    "lnrs.io/terraform-module"                  = "terraform-lnrs-k8s-ingress-nginx"
    "lnrs.io/lb-identifier"                     = local.lb_identifier
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  })

  log_level_lookup = {
    "ERROR" = "error"
    "WARN"  = "warn"
    "INFO"  = "info"
    "DEBUG" = "debug"
  }

  klog_level_lookup = {
    "ERROR" = 1
    "WARN"  = 2
    "INFO"  = 3
    "DEBUG" = 4
  }
}
