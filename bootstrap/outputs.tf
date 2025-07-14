# Outputs for Bootstrap Configuration
# These outputs provide essential information for configuring remote backends and OIDC

output "storage_account_name" {
  description = "Name of the storage account used for Terraform state"
  value       = azurerm_storage_account.tfstate.name
}

output "container_name" {
  description = "Name of the storage container for Terraform state files"
  value       = azurerm_storage_container.tfstate.name
}

output "resource_group_name" {
  description = "Name of the resource group containing bootstrap resources"
  value       = azurerm_resource_group.rg.name
}

output "oidc_client_id" {
  description = "Client ID of the user assigned identity for GitHub Actions OIDC"
  value       = azurerm_user_assigned_identity.gha_oidc.client_id
}

output "oidc_principal_id" {
  description = "Principal ID of the user assigned identity for GitHub Actions OIDC"
  value       = azurerm_user_assigned_identity.gha_oidc.principal_id
}

output "storage_account_id" {
  description = "ID of the storage account for Terraform state"
  value       = azurerm_storage_account.tfstate.id
}

output "federated_identity_credential_id" {
  description = "ID of the federated identity credential for GitHub Actions OIDC"
  value       = azurerm_federated_identity_credential.gha.id
} 