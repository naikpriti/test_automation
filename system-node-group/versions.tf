terraform {
  required_version = ">= 1.4.6"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.36.0, < 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.7.2"
    }
    shell = {
      source = "scottwinkler/shell"
    }
    azapi = {
      source  = "Azure/azapi"
      version = ">= 2.1.0"
    }
  }
}