# Terraform with Azure 🚀

A comprehensive Terraform project for managing Azure infrastructure with enterprise-grade best practices, OIDC authentication, and automated CI/CD pipelines.

## 📋 Table of Contents
- [Overview](#overview)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Bootstrap Setup](#bootstrap-setup)
- [Environment Management](#environment-management)
- [Modules](#modules)
- [CI/CD Pipeline](#cicd-pipeline)
- [Best Practices](#best-practices)
- [Security](#security)
- [Contributing](#contributing)

## 🎯 Overview

This project provides a complete Terraform infrastructure setup for Azure with:
- **Bootstrap Configuration**: Automated setup for OIDC authentication and remote state
- **Modular Architecture**: Reusable modules for common Azure resources
- **Environment Separation**: Isolated configurations for dev, staging, and production
- **Security First**: OIDC authentication, secure state management, and compliance checks
- **Enterprise Standards**: Following industry best practices and security guidelines

## 📁 Project Structure

```
Terraform_with_Azure/
├── bootstrap/                 # Bootstrap infrastructure for OIDC and state management
│   ├── main.tf               # Bootstrap configuration
│   ├── variables.tf          # Bootstrap variables
│   ├── outputs.tf            # Bootstrap outputs
│   ├── deploy.sh             # Bootstrap deployment script
│   └── README.md             # Bootstrap documentation
├── modules/                  # Reusable Terraform modules
│   ├── resource_group/       # Resource group module
│   ├── vnet/                # Virtual network module
│   ├── container_app/        # Container app module
│   ├── key_vault/           # Key vault module
│   └── ...                  # Additional modules
├── envs/                     # Environment-specific configurations
│   ├── dev/                 # Development environment
│   ├── staging/             # Staging environment
│   └── prod/                # Production environment
├── scripts/                  # Utility scripts
│   └── terraform_code_check.sh  # Code quality checks
├── .github/                  # GitHub Actions workflows
├── best_practices.md         # Best practices documentation
├── variables.tf              # Root-level variables
├── outputs.tf                # Root-level outputs
└── README.md                 # This file
```

## 🔧 Prerequisites

### Required Tools
- **Terraform** >= 1.0
- **Azure CLI** >= 2.0
- **Git** >= 2.0

### Optional Tools (for enhanced checks)
- **TFLint** - Code linting
- **tfsec** - Security scanning
- **Checkov** - Additional security checks
- **Infracost** - Cost estimation

### Azure Requirements
- Azure subscription with appropriate permissions
- Azure CLI authenticated (`az login`)

## 🚀 Quick Start

### 1. Clone and Setup
```bash
git clone <repository-url>
cd Terraform_with_Azure
```

### 2. Run Code Quality Checks
```bash
./terraform_code_check.sh
```

### 3. Deploy Bootstrap Infrastructure
```bash
cd bootstrap
./deploy.sh
```

### 4. Configure Environment Backends
Use the bootstrap outputs to configure remote state for your environments.

## 🔐 Bootstrap Setup

The bootstrap configuration creates the foundational infrastructure:

### What it Creates
- **Resource Group**: Container for bootstrap resources
- **Storage Account**: For Terraform state files
- **User Assigned Identity**: For GitHub Actions OIDC
- **Federated Identity Credential**: OIDC trust relationship
- **Role Assignment**: Contributor access for CI/CD

### Deployment
```bash
cd bootstrap
./deploy.sh
```

### Important Outputs
- `storage_account_name`: Used for backend configuration
- `oidc_client_id`: Used in GitHub Actions workflow
- `resource_group_name`: Used for subsequent deployments

## 🌍 Environment Management

### Environment Structure
Each environment (`dev`, `staging`, `prod`) has:
- **Backend Configuration**: Remote state storage
- **Variable Files**: Environment-specific values
- **Resource Configurations**: Tailored for the environment

### Environment Deployment
```bash
cd envs/dev
terraform init -backend-config=backend-config.txt
terraform plan
terraform apply
```

## 🧩 Modules

### Available Modules
- **resource_group**: Azure resource groups with tagging
- **vnet**: Virtual networks with subnets
- **container_app**: Container apps with scaling
- **key_vault**: Key vaults with access policies
- **postgresql**: PostgreSQL databases
- **nsg**: Network security groups

### Module Usage
```hcl
module "vnet" {
  source = "../../modules/vnet"
  
  name                = "vnet-dev"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  subnets = {
    app = { address_prefix = "10.0.1.0/24" }
    db  = { address_prefix = "10.0.2.0/24" }
  }
}
```

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow
The project includes automated CI/CD with:
- **OIDC Authentication**: Secure Azure authentication
- **Code Quality Checks**: Automated validation
- **Security Scanning**: tfsec and Checkov integration
- **Cost Estimation**: Infracost integration
- **Environment Promotion**: Automated deployments

### Workflow Features
- ✅ **Security**: OIDC authentication (no secrets)
- ✅ **Quality**: Automated code checks
- ✅ **Compliance**: Security and cost scanning
- ✅ **Automation**: Environment promotion
- ✅ **Monitoring**: Deployment status and costs

## 📚 Best Practices

### Code Organization
- **Modular Structure**: Reusable modules
- **Environment Separation**: Isolated configurations
- **Documentation**: Comprehensive README files
- **Version Control**: Proper .gitignore and tagging

### Security
- **OIDC Authentication**: No secrets in code
- **Remote State**: Secure state management
- **Least Privilege**: Minimal required permissions
- **Security Scanning**: Automated vulnerability checks

### Quality Assurance
- **Code Formatting**: Automated formatting
- **Validation**: Configuration validation
- **Linting**: Code quality checks
- **Testing**: Automated testing

## 🔒 Security

### Authentication
- **OIDC**: GitHub Actions to Azure authentication
- **No Secrets**: All authentication is token-based
- **Federated Identity**: Secure trust relationships

### State Management
- **Remote Backend**: Azure Storage for state files
- **Versioning**: Blob versioning enabled
- **Encryption**: TLS 1.2+ encryption
- **Access Control**: Private storage containers

### Compliance
- **Security Scanning**: tfsec and Checkov
- **Cost Monitoring**: Infracost integration
- **Audit Trail**: Complete deployment logging
- **Tagging**: Resource tagging for governance

## 🤝 Contributing

### Development Workflow
1. **Fork** the repository
2. **Create** a feature branch
3. **Make** your changes
4. **Run** code quality checks
5. **Test** your changes
6. **Submit** a pull request

### Code Standards
- Follow the established project structure
- Include comprehensive documentation
- Run all quality checks before submitting
- Follow security best practices
- Include appropriate tests

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- **Issues**: Create a GitHub issue
- **Documentation**: Check the best_practices.md
- **Examples**: Review the module documentation

---

*This project follows enterprise-grade best practices for security, scalability, and maintainability.*
