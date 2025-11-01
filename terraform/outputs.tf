output "resource_group_name" {
  description = "Nom du Resource Group"
  value       = azurerm_resource_group.main.name
}

output "storage_account_name" {
  description = "Nom du Storage Account"
  value       = azurerm_storage_account.main.name
}

output "storage_account_primary_connection_string" {
  description = "Connection string du Storage Account"
  value       = azurerm_storage_account.main.primary_connection_string
  sensitive   = true
}

output "function_app_name" {
  description = "Nom de la Function App"
  value       = azurerm_linux_function_app.main.name
}

output "function_app_default_hostname" {
  description = "Hostname de la Function App"
  value       = azurerm_linux_function_app.main.default_hostname
}

output "application_insights_instrumentation_key" {
  description = "Clé d'instrumentation Application Insights"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Connection string Application Insights"
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}
