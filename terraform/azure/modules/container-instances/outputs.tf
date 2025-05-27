# Outputs
output "app_fqdn" {
  description = "FQDN para acessar a aplicação"
  value       = azurerm_container_group.python_app.fqdn
}

output "app_ip_address" {
  description = "IP público da aplicação"
  value       = azurerm_container_group.python_app.ip_address
}

output "app_url" {
  description = "URL completa da aplicação"
  value       = "http://${azurerm_container_group.python_app.fqdn}:8000"
}

output "container_group_id" {
  description = "ID do Container Group"
  value       = azurerm_container_group.python_app.id
}

output "container_group_name" {
  description = "Nome do Container Group (para Jenkins)"
  value       = azurerm_container_group.python_app.name
}