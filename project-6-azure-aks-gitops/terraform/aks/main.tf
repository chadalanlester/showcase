locals {
  name = "${var.name_prefix}-aks"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.name_prefix}-law"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_log_analytics_solution" "containerinsights" {
  solution_name         = "ContainerInsights"
  location              = azurerm_log_analytics_workspace.law.location
  resource_group_name   = azurerm_resource_group.rg.name
  workspace_resource_id = azurerm_log_analytics_workspace.law.id
  workspace_name        = azurerm_log_analytics_workspace.law.name
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
  tags = var.tags
}

resource "azurerm_container_registry" "acr" {
  name                = replace("${var.name_prefix}acr", "-", "")
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = false
  tags                = var.tags
}

resource "azurerm_key_vault" "kv" {
  name                        = replace("${var.name_prefix}-kv", "-", "")
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = var.location
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enable_rbac_authorization   = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  tags                        = var.tags

  network_acls {
    default_action = "Allow" # lab. lock down later for prod.
    bypass         = "AzureServices"
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = local.name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.name_prefix}-dns"

  kubernetes_version       = var.kubernetes_version
  automatic_channel_upgrade = "stable"

  identity {
    type = "SystemAssigned"
  }

  oidc_issuer_enabled      = true
  workload_identity_enabled = true

  default_node_pool {
    name                        = "system"
    vm_size                     = var.system_vm_size
    type                        = "VirtualMachineScaleSets"
    node_count                  = 1
    only_critical_addons_enabled = true
    orchestrator_version        = var.kubernetes_version
    upgrade_settings { max_surge = "33%" }
  }

  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "standard"
    outbound_type = "loadBalancer"
  }

  azure_active_directory_role_based_access_control {
    managed = true
    admin_group_object_ids = []
  }

  addon_profile {
    oms_agent {
      log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
    }
    azure_policy {
      enabled = true
    }
    kube_dashboard { enabled = false }
    azure_keyvault_secrets_provider {
      secret_rotation_enabled = true
    }
  }

  microsoft_defender {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  }

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

# Pull from ACR
resource "azurerm_role_assignment" "acrpull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

# AKS diagnostics to Log Analytics
resource "azurerm_monitor_diagnostic_setting" "aksdiag" {
  name                       = "aks-diagnostics"
  target_resource_id         = azurerm_kubernetes_cluster.aks.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  metric { category = "AllMetrics" enabled = true }

  dynamic "log" {
    for_each = [
      "kube-apiserver","kube-audit","kube-audit-admin","kube-controller-manager",
      "kube-scheduler","cluster-autoscaler","cloud-controller-manager","guard"
    ]
    content {
      category = log.value
      enabled  = true
      retention_policy { enabled = false }
    }
  }
}

# Flux v2 extension + GitOps config
resource "azurerm_kubernetes_cluster_extension" "flux" {
  name           = "flux"
  cluster_id     = azurerm_kubernetes_cluster.aks.id
  extension_type = "flux"
  release_train  = "Stable"
  auto_upgrade_minor_version = true
  tags = var.tags
}

resource "azurerm_kubernetes_flux_configuration" "gitops" {
  name       = "cluster-gitops"
  cluster_id = azurerm_kubernetes_cluster.aks.id
  scope      = "cluster"
  namespace  = "flux-system"

  git_repository {
    url            = var.gitops_repo_url
    reference_type = "branch"
    reference_value = var.gitops_repo_branch
    sync_interval_in_seconds = 60
  }

  kustomizations {
    name                        = "apps"
    path                        = var.gitops_repo_path
    prune                       = true
    retry_interval_in_seconds   = 30
    sync_interval_in_seconds    = 60
    timeout_in_seconds          = 600
  }

  depends_on = [azurerm_kubernetes_cluster_extension.flux]
  tags       = var.tags
}

# Optional: assign a built-in AKS security initiative if provided
resource "azurerm_policy_assignment" "aks_initiative" {
  count                = var.policy_set_definition_id != "" ? 1 : 0
  name                 = "${var.name_prefix}-aks-security"
  display_name         = "AKS Security Baseline (project-6)"
  scope                = azurerm_kubernetes_cluster.aks.id
  policy_definition_id = var.policy_set_definition_id
  enforcement_mode     = "Default"
  identity { type = "SystemAssigned" }
}
