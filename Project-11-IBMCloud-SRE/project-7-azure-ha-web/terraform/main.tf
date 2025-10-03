# ======================================================================
# FILE: terraform/main.tf
# ======================================================================
resource "random_string" "suffix" {
  length  = 5
  upper   = false
  special = false
}

locals {
  name = "${var.prefix}-${random_string.suffix.result}"
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${local.name}-rg"
  location = var.location
  tags     = var.resource_tags
}

# Log Analytics
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${local.name}-law"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = var.law_sku
  retention_in_days   = 30
  tags                = var.resource_tags
}

# Hub VNet
resource "azurerm_virtual_network" "hub" {
  name                = "${local.name}-hub-vnet"
  address_space       = var.hub_address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.resource_tags
}

resource "azurerm_subnet" "hub_firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.subnets.hub.firewall]
}

resource "azurerm_subnet" "hub_bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.subnets.hub.bastion]
}

resource "azurerm_subnet" "hub_mgmt" {
  name                 = "management"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.subnets.hub.management]
}

# Spoke VNet
resource "azurerm_virtual_network" "spoke" {
  name                = "${local.name}-spoke-vnet"
  address_space       = var.spoke_address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.resource_tags
}

resource "azurerm_subnet" "spoke_appgw" {
  name                 = "appgw-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.subnets.spoke.appgw]
}

resource "azurerm_subnet" "spoke_web" {
  name                 = "web-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.subnets.spoke.web]
}

# Peerings
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = "hub-to-spoke"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "spoke-to-hub"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.spoke.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
}

# Azure Firewall + IP
resource "azurerm_public_ip" "fw_pip" {
  name                = "${local.name}-fw-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.resource_tags
}

resource "azurerm_firewall" "fw" {
  name                = "${local.name}-fw"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hub_firewall.id
    public_ip_address_id = azurerm_public_ip.fw_pip.id
  }
  tags = var.resource_tags
}

# Egress rules (HTTP/HTTPS)
resource "azurerm_firewall_application_rule_collection" "egress" {
  name                = "egress-web"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 100
  action              = "Allow"

  rule {
    name             = "allow-http-https"
    source_addresses = [var.subnets.spoke.web, var.subnets.spoke.appgw]
    target_fqdns     = ["*"]

    protocol {
      type = "Http"
      port = 80
    }
    protocol {
      type = "Https"
      port = 443
    }
  }
}

# Route table (only web subnet; NOT appgw subnet)
resource "azurerm_route_table" "spoke_rt" {
  name                          = "${local.name}-spoke-rt"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  bgp_route_propagation_enabled = true
  tags                          = var.resource_tags
}

resource "azurerm_route" "default_to_fw" {
  name                   = "default-to-fw"
  resource_group_name    = azurerm_resource_group.rg.name
  route_table_name       = azurerm_route_table.spoke_rt.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration[0].private_ip_address
}

resource "azurerm_subnet_route_table_association" "rt_web" {
  subnet_id      = azurerm_subnet.spoke_web.id
  route_table_id = azurerm_route_table.spoke_rt.id
}

# Bastion
resource "azurerm_public_ip" "bastion_pip" {
  name                = "${local.name}-bastion-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.resource_tags
}

resource "azurerm_bastion_host" "bastion" {
  name                = "${local.name}-bastion"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hub_bastion.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
  tags = var.resource_tags
}

# App Gateway WAF v2 + Public IP + WAF policy
resource "azurerm_public_ip" "agw_pip" {
  name                = "${local.name}-agw-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.resource_tags
}

resource "azurerm_web_application_firewall_policy" "waf" {
  name                = "${local.name}-waf-policy"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  policy_settings {
    enabled            = true
    mode               = "Prevention"
    request_body_check = true
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }
  tags = var.resource_tags
}

resource "azurerm_application_gateway" "agw" {
  name                = "${local.name}-agw"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  autoscale_configuration {
    min_capacity = var.agw_min
    max_capacity = var.agw_max
  }

  firewall_policy_id = azurerm_web_application_firewall_policy.waf.id

  gateway_ip_configuration {
    name      = "gwipcfg"
    subnet_id = azurerm_subnet.spoke_appgw.id
  }

  frontend_port {
    name = "feport-80"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "feip"
    public_ip_address_id = azurerm_public_ip.agw_pip.id
  }

  backend_address_pool {
    name = "be-pool"
  }

  backend_http_settings {
    name                                = "be-httpsettings"
    cookie_based_affinity               = "Disabled"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 30
    pick_host_name_from_backend_address = false
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "feip"
    frontend_port_name             = "feport-80"
    protocol                       = "Http"
  }

  probe {
    name                = "probe-80"
    protocol            = "Http"
    path                = "/"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    host                = "127.0.0.1"
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    name                       = "rule-80"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "be-pool"
    backend_http_settings_name = "be-httpsettings"
    priority                   = 100
  }

  tags = var.resource_tags
}

# VMSS (Ubuntu); use Automatic upgrades to avoid health probe/extension requirement
resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "${local.name}-web-vmss"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = var.vmss_sku
  instances           = var.vmss_capacity
  upgrade_mode        = "Automatic"

  admin_username = var.admin_username
  custom_data    = base64encode(file("${path.module}/cloud-init/web.yaml"))

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "vmss-nic"
    primary = true
    ip_configuration {
      name      = "vmss-ipcfg"
      primary   = true
      subnet_id = azurerm_subnet.spoke_web.id
      application_gateway_backend_address_pool_ids = [
        one(azurerm_application_gateway.agw.backend_address_pool).id
      ]
    }
  }

  boot_diagnostics {}
  tags = merge(var.resource_tags, { role = "web" })
}

# Azure Monitor Agent on VMSS + DCR
resource "azurerm_monitor_data_collection_rule" "dcr" {
  name                = "${local.name}-dcr"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  destinations {
    log_analytics {
      name                  = "law"
      workspace_resource_id = azurerm_log_analytics_workspace.law.id
    }
  }

  data_flow {
    streams      = ["Microsoft-Perf", "Microsoft-Syslog"]
    destinations = ["law"]
  }

  data_sources {
    performance_counter {
      name                          = "perf-default"
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "\\Processor(_Total)\\% Processor Time",
        "\\Memory\\Available MBytes",
        "\\LogicalDisk(_Total)\\% Free Space"
      ]
    }
    syslog {
      name           = "syslog-default"
      streams        = ["Microsoft-Syslog"]
      facility_names = ["auth", "authpriv", "daemon", "kern", "syslog", "user"]
      log_levels     = ["Info", "Notice", "Warning", "Error", "Critical", "Alert", "Emergency"]
    }
  }

  tags = var.resource_tags
}

resource "azurerm_virtual_machine_scale_set_extension" "ama" {
  name                         = "AzureMonitorLinuxAgent"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.vmss.id
  publisher                    = "Microsoft.Azure.Monitor"
  type                         = "AzureMonitorLinuxAgent"
  type_handler_version         = "1.0"
  auto_upgrade_minor_version   = true
  settings                     = jsonencode({})
}

resource "azurerm_monitor_data_collection_rule_association" "dcr_assoc" {
  name                    = "vmss-dcr-assoc"
  target_resource_id      = azurerm_linux_virtual_machine_scale_set.vmss.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr.id
}

# Diagnostic Settings (AGW, Firewall, Bastion) -> Log Analytics
data "azurerm_monitor_diagnostic_categories" "agw" {
  resource_id = azurerm_application_gateway.agw.id
}
resource "azurerm_monitor_diagnostic_setting" "agw_diag" {
  name                       = "${local.name}-agw-diag"
  target_resource_id         = azurerm_application_gateway.agw.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  dynamic "enabled_log" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.agw.logs)
    content { category = enabled_log.value }
  }
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

data "azurerm_monitor_diagnostic_categories" "fw" {
  resource_id = azurerm_firewall.fw.id
}
resource "azurerm_monitor_diagnostic_setting" "fw_diag" {
  name                       = "${local.name}-fw-diag"
  target_resource_id         = azurerm_firewall.fw.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  dynamic "enabled_log" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.fw.logs)
    content { category = enabled_log.value }
  }
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

data "azurerm_monitor_diagnostic_categories" "bastion" {
  resource_id = azurerm_bastion_host.bastion.id
}
resource "azurerm_monitor_diagnostic_setting" "bastion_diag" {
  name                       = "${local.name}-bastion-diag"
  target_resource_id         = azurerm_bastion_host.bastion.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  dynamic "enabled_log" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.bastion.logs)
    content { category = enabled_log.value }
  }
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
