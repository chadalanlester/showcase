variable "subscription_id" { type = string }

variable "location" {
  type    = string
  default = "eastus2"
}

variable "name_prefix" {
  type    = string
  default = "p6"
}

variable "resource_group_name" {
  type    = string
  default = "rg-aks-gitops-lab"
}

variable "tags" {
  type = map(string)
  default = {
    project = "project-6-azure-aks-gitops"
    owner   = "chad"
    env     = "lab"
  }
}

variable "kubernetes_version" {
  type    = string
  default = null
}

variable "system_vm_size" {
  type    = string
  default = "Standard_B1ms"
}

variable "user_vm_size" {
  type    = string
  default = "Standard_B1ms"
}

variable "user_min" {
  type    = number
  default = 1
}

variable "user_max" {
  type    = number
  default = 1
}

variable "gitops_repo_url" {
  type    = string
  default = "https://github.com/chadalanlester/showcase.git"
}

variable "gitops_repo_branch" {
  type    = string
  default = "main"
}

variable "gitops_repo_path" {
  type    = string
  default = "project-6-azure-aks-gitops/gitops/clusters/lab"
}

variable "policy_set_definition_id" {
  type    = string
  default = ""
}
