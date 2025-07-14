# Variables for Bootstrap Configuration
# Define input variables with proper type constraints and descriptions

variable "location" {
  description = "Azure region for bootstrap resources"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the resource group for bootstrap resources"
  type        = string
  default     = "rg-terraform-bootstrap"
}

variable "storage_account_name_prefix" {
  description = "Prefix for the storage account name (will be appended with random suffix)"
  type        = string
  default     = "tfstate"
}

variable "container_name" {
  description = "Name of the storage container for Terraform state files"
  type        = string
  default     = "tfstate"
}

variable "github_repository" {
  description = "GitHub repository in format 'owner/repository'"
  type        = string
  default     = "sandeep-1010-cool/Terraform_with_Azure"
}

variable "github_branch" {
  description = "GitHub branch for OIDC subject"
  type        = string
  default     = "main"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "bootstrap"
    Purpose     = "terraform-state-management"
    ManagedBy   = "terraform"
  }
} 