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
    vm_size                      = var.system_vm_size # set in variables.tf (use Standard_B1ms/B2s)
    type                         = "VirtualMachineScaleSets"
    node_count                   = 1
    only_critical_addons_enabled = true
    orchestrator_version         = var.kubernetes_version
    upgrade_settings {
      max_surge        = "0"
      max_unavailable = "1"
    }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }

  # AAD managed RBAC (v3 warns; safe, required true)
  azure_active_directory_role_based_access_control { managed = true }

  # Use existing LAW for control-plane / daemonset agent
  oms_agent {
    log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  }

  key_vault_secrets_provider { secret_rotation_enabled = true }
  azure_policy_enabled = true

  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "workload"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.user_vm_size
  node_count            = var.user_min
  min_count             = var.user_min
  max_count             = var.user_max
  enable_auto_scaling   = true
  mode                  = "User"
  orchestrator_version  = var.kubernetes_version
  max_pods              = 60
  node_taints           = []
  tags                  = var.tags
}

# Allow AKS to pull images from existing ACR
resource "azurerm_role_assignment" "acrpull" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

# Flux extension + config from this repo
resource "azurerm_kubernetes_cluster_extension" "flux" {
  name           = "flux"
  cluster_id     = azurerm_kubernetes_cluster.aks.id
  extension_type = "flux"
  release_train  = "Stable"
}

resource "azurerm_kubernetes_flux_configuration" "gitops" {
  name       = "cluster-gitops"
  cluster_id = azurerm_kubernetes_cluster.aks.id
  scope      = "cluster"
  namespace  = "flux-system"

  git_repository {
    url                      = var.gitops_repo_url
    reference_type           = "branch"
    reference_value          = var.gitops_repo_branch
    sync_interval_in_seconds = 60
    timeout_in_seconds       = 600
  }

  kustomizations {
    name                       = "apps"
    path                       = var.gitops_repo_path
    garbage_collection_enabled = true
    retry_interval_in_seconds  = 30
    sync_interval_in_seconds   = 60
    timeout_in_seconds         = 600
  }

  depends_on = [azurerm_kubernetes_cluster_extension.flux]
}

# Optional: assign an initiative at the AKS resource if provided
resource "azurerm_resource_policy_assignment" "aks_initiative" {
  count                = var.policy_set_definition_id != "" ? 1 : 0
  name                 = "${var.name_prefix}-aks-security"
  policy_definition_id = var.policy_set_definition_id
  resource_id          = azurerm_kubernetes_cluster.aks.id
  location             = var.location
}
