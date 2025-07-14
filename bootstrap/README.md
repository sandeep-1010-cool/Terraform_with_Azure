# Terraform Bootstrap Configuration 🚀

This directory contains the bootstrap configuration for setting up Azure infrastructure required for Terraform state management and GitHub Actions OIDC authentication.

## 📋 Overview

The bootstrap configuration creates the foundational infrastructure needed to:
- Store Terraform state files securely in Azure Storage
- Enable GitHub Actions OIDC authentication for secure CI/CD
- Establish proper resource organization and tagging

## 🏗️ Resources Created

### Core Infrastructure
- **Resource Group**: `rg-terraform-bootstrap` - Container for all bootstrap resources
- **Storage Account**: Randomly named storage account for Terraform state files
- **Storage Container**: `tfstate` container for organizing state files

### OIDC Authentication
- **User Assigned Identity**: `github-oidc-identity` for GitHub Actions authentication
- **Federated Identity Credential**: OIDC trust relationship with GitHub
- **Role Assignment**: Contributor access for the resource group

## 📁 File Structure

```
bootstrap/
├── main.tf              # Main Terraform configuration
├── variables.tf          # Input variables definition
├── outputs.tf           # Output values
├── backend-config.txt   # Backend configuration template
└── README.md           # This file
```

## 🚀 Usage

### Prerequisites
- Azure CLI installed and authenticated
- Terraform >= 1.0 installed
- Appropriate Azure permissions to create resources

### Deployment Steps

1. **Navigate to bootstrap directory**:
   ```bash
   cd bootstrap
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Review the plan**:
   ```bash
   terraform plan
   ```

4. **Apply the configuration**:
   ```bash
   terraform apply -auto-approve
   ```

### Important Outputs

After successful deployment, note these outputs:

- `storage_account_name`: Used for backend configuration
- `oidc_client_id`: Used in GitHub Actions workflow
- `resource_group_name`: Used for subsequent deployments

## 🔧 Configuration

### Variables

The configuration uses the following variables (with defaults):

| Variable | Description | Default |
|----------|-------------|---------|
| `location` | Azure region | `East US` |
| `resource_group_name` | Resource group name | `rg-terraform-bootstrap` |
| `storage_account_name_prefix` | Storage account prefix | `tfstate` |
| `container_name` | Storage container name | `tfstate` |
| `github_repository` | GitHub repository | `sandeep-1010-cool/Terraform_with_Azure` |
| `github_branch` | GitHub branch | `main` |

### Customization

To customize the deployment, create a `terraform.tfvars` file:

```hcl
location = "West US 2"
github_repository = "your-org/your-repo"
github_branch = "develop"
```

## 🔒 Security Features

- **Private Storage**: Storage account and container are private
- **Versioning**: Blob versioning enabled for state file backup
- **OIDC Authentication**: Secure GitHub Actions authentication without secrets
- **Least Privilege**: Contributor role scoped to resource group only

## 📊 Outputs

| Output | Description | Usage |
|--------|-------------|-------|
| `storage_account_name` | Storage account name | Backend configuration |
| `container_name` | Storage container name | Backend configuration |
| `resource_group_name` | Resource group name | Subsequent deployments |
| `oidc_client_id` | OIDC client ID | GitHub Actions workflow |
| `oidc_principal_id` | OIDC principal ID | Role assignments |
| `storage_account_id` | Storage account ID | Resource references |
| `federated_identity_credential_id` | OIDC credential ID | Management |

## 🔄 Next Steps

After successful bootstrap deployment:

1. **Configure Environment Backends**: Use the outputs to configure remote backends for `envs/dev/`, `envs/prod/`, etc.
2. **Setup GitHub Actions**: Use the OIDC client ID in your CI/CD workflows
3. **Deploy Environments**: Use the established infrastructure for environment deployments

## 🧹 Cleanup

To destroy the bootstrap infrastructure:

```bash
terraform destroy
```

⚠️ **Warning**: This will remove the storage account containing Terraform state files. Ensure you have backups or have migrated state files before destruction.

## 📚 Related Documentation

- [Azure Storage Backend](https://www.terraform.io/language/settings/backends/azurerm)
- [GitHub Actions OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [Azure User Assigned Identities](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview)

---

*This bootstrap configuration follows enterprise best practices for security, scalability, and maintainability.* 