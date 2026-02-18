output "paw_ip_address" {
  value = azurerm_public_ip.paw.ip_address
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.main.workspace_id
}
