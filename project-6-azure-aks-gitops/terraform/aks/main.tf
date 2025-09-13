locals {
  name = "${var.name_prefix}-aks"
}

data "azurerm_client_config" "current" {}

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
    vm_size                      = "Standard_B2ms"
    type                         = "VirtualMachineScaleSets"
    node_count                   = 1
    only_critical_addons_enabled = true
    orchestrator_version         = var.kubernetes_version
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


resource "azurerm_role_assignment" "acrpull" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}



resource "azurerm_resource_policy_assignment" "aks_initiative" {
  count                = var.policy_set_definition_id != "" ? 1 : 0
  name                 = "${var.name_prefix}-aks-security"
  policy_definition_id = var.policy_set_definition_id
  resource_id          = azurerm_kubernetes_cluster.aks.id
  location             = var.location
}

resource "azurerm_kubernetes_cluster_node_pool" "work" {
  name                  = "work"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_B2ms" # meets AKS min; small quota footprint
  node_count            = 1
  mode                  = "User"
  enable_auto_scaling   = false
  os_type               = "Linux"
  orchestrator_version  = var.kubernetes_version
  max_pods              = 60
  tags                  = var.tags
}
