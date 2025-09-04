variable "prefix" {
  type    = string
  default = "p7"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "resource_tags" {
  type    = map(string)
  default = { project = "project7-azure-ha-web" }
}

variable "hub_address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "spoke_address_space" {
  type    = list(string)
  default = ["10.1.0.0/16"]
}

variable "subnets" {
  type = object({
    hub = object({
      firewall   = string
      bastion    = string
      management = string
    })
    spoke = object({
      appgw = string
      web   = string
    })
  })
  default = {
    hub = {
      firewall   = "10.0.0.0/26"
      bastion    = "10.0.0.64/26"
      management = "10.0.1.0/24"
    }
    spoke = {
      appgw = "10.1.0.0/24"
      web   = "10.1.1.0/24"
    }
  }
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key" {
  type      = string
  sensitive = true
}

variable "vmss_capacity" {
  type    = number
  default = 2
}

variable "vmss_sku" {
  type    = string
  default = "Standard_B2s"
}

variable "agw_min" {
  type    = number
  default = 2
}

variable "agw_max" {
  type    = number
  default = 5
}

variable "law_sku" {
  type    = string
  default = "PerGB2018"
}
