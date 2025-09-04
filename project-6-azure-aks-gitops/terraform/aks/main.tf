locals {
  name = "${var.name_prefix}-aks"
}

data "azurerm_client_config" "current" {}

# Existing resources (avoid imports)
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_log_analytics_workspace" "law" {
  name                = "${var.name_prefix}-law"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_container_registry" "acr" {
  name                = replace("${var.name_prefix}acr", "-", "")
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_key_vault" "kv" {
  name                = replace("${var.name_prefix}-kv", "-", "")
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_kubernetes_cluster" "aks" {
resource "azurerm_kubernetes_cluster" "aks" {
  name                = local.name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_prefix          = "${var.name_prefix}-dns"

  kubernetes_version        = var.kubernetes_version
  automatic_channel_upgrade = "stable"

  identity { type = "SystemAssigned" }

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  default_node_pool {
    name                         = "system"
    vm_size                      = var.system_vm_size
    type                         = "VirtualMachineScaleSets"
    node_count                   = 1
    only_critical_addons_enabled = true
    orchestrator_version         = var.kubernetes_version
    upgrade_settings {
      max_surge        = "0"
      max_unavailable  = "1"
    }
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }

  azure_active_directory_role_based_access_control { managed = true }

  oms_agent {
    log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  }

  key_vault_secrets_provider { secret_rotation_enabled = true }
  azure_policy_enabled = true

  tags = var.tags
}
