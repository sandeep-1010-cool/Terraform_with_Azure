# Root-level outputs for the Terraform project
# These outputs provide information about the overall project structure

output "project_name" {
  description = "Name of the Terraform project"
  value       = "Terraform_with_Azure"
}

output "project_version" {
  description = "Version of the Terraform project"
  value       = "1.0.0"
}

output "terraform_version" {
  description = "Required Terraform version"
  value       = ">= 1.0"
}

output "supported_environments" {
  description = "List of supported environments"
  value       = ["dev", "staging", "prod"]
}

output "module_count" {
  description = "Number of modules in the project"
  value       = length(fileset(path.module, "modules/*"))
}

output "environment_count" {
  description = "Number of environment configurations"
  value       = length(fileset(path.module, "envs/*"))
} 