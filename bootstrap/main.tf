# Bootstrap Configuration for Azure OIDC and Remote Backend
# This configuration sets up the foundational infrastructure for Terraform state management
# and GitHub Actions OIDC authentication

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group for Terraform bootstrap resources
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

# Random suffix for unique storage account name
resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

# Storage Account for Terraform state files
resource "azurerm_storage_account" "tfstate" {
  name                     = "${var.storage_account_name_prefix}${random_integer.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  # Enable versioning for state file backup
  blob_properties {
    versioning_enabled = true
  }

  tags = var.tags
}

# Storage Container for Terraform state files
resource "azurerm_storage_container" "tfstate" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

# User Assigned Identity for GitHub Actions OIDC
resource "azurerm_user_assigned_identity" "gha_oidc" {
  name                = "github-oidc-identity"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  tags = var.tags
}

# Federated Identity Credential for GitHub Actions OIDC
resource "azurerm_federated_identity_credential" "gha" {
  name                = "gha-oidc"
  resource_group_name = azurerm_resource_group.rg.name
  parent_id           = azurerm_user_assigned_identity.gha_oidc.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  subject             = "repo:${var.github_repository}:ref:refs/heads/${var.github_branch}"
}

# Role Assignment for GitHub Actions Identity
# Using Contributor role for the resource group scope
resource "azurerm_role_assignment" "gha_access" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.gha_oidc.principal_id

  description = "GitHub Actions OIDC access for Terraform operations"
} 