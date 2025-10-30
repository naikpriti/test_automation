locals {
  acr_registry_subscription   = var.azure_environment == "AzureUSGovernmentCloud" ? "6ac9610a-51a8-49a4-9f74-6c34301749ee" : "ed5e2254-5d87-4255-b70e-1b5eba509f73"
  acr_registry_resource_group = var.azure_environment == "AzureUSGovernmentCloud" ? "app-imagegallery-prod-usgovvirginia" : "app-imagegallery-prod-eastus"
  acr_registry_name           = var.azure_environment == "AzureUSGovernmentCloud" ? "govsharedpullthroughacr" : "sharedpullthroughacr"
  acr_registry_id             = "/subscriptions/${local.acr_registry_subscription}/resourceGroups/${local.acr_registry_resource_group}/providers/Microsoft.ContainerRegistry/registries/${local.acr_registry_name}"
  acr_registry                = var.azure_environment == "AzureUSGovernmentCloud" ? "${local.acr_registry_name}.azurecr.us" : "${local.acr_registry_name}.azurecr.io"
  cgr_registry_source         = "cgr.dev/lexisnexisrisk.com"
  cgr_registry                = "${local.acr_registry}/chainguard"

  ingress_controller_image_config = var.cgr_images ? (
    var.fips ? {
      repository = replace("cgr.dev/lexisnexisrisk.com/ingress-nginx-controller-fips", local.cgr_registry_source, local.cgr_registry)
      tag        = "1.13.3"
      digest     = "sha256:6a0e23a022b662846ef4d52dea0ed6f89ca9d0d991bc2c7624dd93c14d1aebb6"
      } : {
      repository = replace("cgr.dev/lexisnexisrisk.com/ingress-nginx-controller", local.cgr_registry_source, local.cgr_registry)
      tag        = "1.13.3"
      digest     = "sha256:b7e7d2b4674fb0d410e4f4ebef8cc882657b596c78d463c06d9b8db0008e07e4"
    }
    ) : {
    repository = "registry.k8s.io/ingress-nginx/controller"
    tag        = "v1.13.3"
    digest     = "sha256:1b044f6dcac3afbb59e05d98463f1dec6f3d3fb99940bc12ca5d80270358e3bd"
  }

  ingress_custom_error_pages_image_config = var.cgr_images ? (
    var.fips ? {
      repository = replace("cgr.dev/lexisnexisrisk.com/ingress-nginx-custom-error-pages-fips", local.cgr_registry_source, local.cgr_registry)
      tag        = "1.13.3"
      digest     = "sha256:8642863dae0047385c2b8bef09ac64ee7476cc133d2d819dc798331fb5b3da38"
      } : {
      repository = replace("cgr.dev/lexisnexisrisk.com/ingress-nginx-custom-error-pages", local.cgr_registry_source, local.cgr_registry)
      tag        = "1.13.3"
      digest     = "sha256:e07b9b84242ed3822d2d048ed71b8435cf8ba0da0fa49f3fb647cc7889e71331"
    }
    ) : {
    repository = "registry.k8s.io/ingress-nginx/custom-error-pages"
    tag        = "v1.2.3"
    digest     = "sha256:dbe7ec7c1556281fa71f4ec974693b51bfb91970477313dcc9262a4e44ecec4d"
  }
}