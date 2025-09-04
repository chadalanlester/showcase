terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0, < 4.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = ">= 1.14, < 2.0"
    }
  }
}
