output "resource_group" { value = azurerm_resource_group.rg.name }
output "location" { value = azurerm_resource_group.rg.location }
output "appgw_public_ip" { value = azurerm_public_ip.agw_pip.ip_address }
output "log_analytics_workspace_id" { value = azurerm_log_analytics_workspace.law.id }
output "bastion_name" { value = azurerm_bastion_host.bastion.name }
output "firewall_private_ip" { value = azurerm_firewall.fw.ip_configuration[0].private_ip_address }
