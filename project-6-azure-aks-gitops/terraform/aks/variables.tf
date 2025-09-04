variable "subscription_id"      { type = string }
variable "location"             { type = string  default = "eastus2" }
variable "name_prefix"          { type = string  default = "p6" }
variable "resource_group_name"  { type = string  default = "rg-aks-gitops-lab" }
variable "tags" {
  type = map(string)
  default = { project = "project-6-azure-aks-gitops", owner = "chad", env = "lab" }
}

# AKS
variable "kubernetes_version" { type = string  default = null } # let AKS choose latest if null
variable "system_vm_size"     { type = string  default = "Standard_D4s_v5" }
variable "user_vm_size"       { type = string  default = "Standard_D4s_v5" }
variable "user_min"           { type = number  default = 1 }
variable "user_max"           { type = number  default = 3 }

# GitOps
variable "gitops_repo_url"    { type = string  default = "https://github.com/chadalanlester/showcase.git" }
variable "gitops_repo_branch" { type = string  default = "main" }
variable "gitops_repo_path"   { type = string  default = "project-6-azure-aks-gitops/gitops/clusters/lab" }

# Policy (optional initiative id). Leave empty to skip assignment.
variable "policy_set_definition_id" { type = string  default = "" }
