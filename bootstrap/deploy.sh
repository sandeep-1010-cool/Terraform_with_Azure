#!/bin/bash

# Terraform Bootstrap Deployment Script
# This script automates the deployment of the bootstrap infrastructure

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the bootstrap directory
if [ ! -f "main.tf" ]; then
    print_error "This script must be run from the bootstrap directory"
    exit 1
fi

print_status "Starting Terraform bootstrap deployment..."

# Check if Azure CLI is installed and authenticated
if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed. Please install it first."
    exit 1
fi

# Check if user is logged in to Azure
if ! az account show &> /dev/null; then
    print_warning "You are not logged in to Azure. Please run 'az login' first."
    exit 1
fi

print_status "Azure CLI is available and authenticated"

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install it first."
    exit 1
fi

print_status "Terraform is available"

# Initialize Terraform
print_status "Initializing Terraform..."
terraform init

if [ $? -eq 0 ]; then
    print_success "Terraform initialized successfully"
else
    print_error "Failed to initialize Terraform"
    exit 1
fi

# Validate Terraform configuration
print_status "Validating Terraform configuration..."
terraform validate

if [ $? -eq 0 ]; then
    print_success "Terraform configuration is valid"
else
    print_error "Terraform configuration validation failed"
    exit 1
fi

# Show the plan
print_status "Showing Terraform plan..."
terraform plan

# Ask for confirmation
echo
read -p "Do you want to apply this configuration? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Applying Terraform configuration..."
    terraform apply -auto-approve
    
    if [ $? -eq 0 ]; then
        print_success "Bootstrap deployment completed successfully!"
        
        # Show outputs
        echo
        print_status "Deployment outputs:"
        echo "=================="
        terraform output
        
        echo
        print_status "Next steps:"
        echo "1. Copy the storage_account_name and oidc_client_id values"
        echo "2. Update backend-config.txt with the storage account name"
        echo "3. Configure your environment-specific Terraform configurations"
        echo "4. Set up GitHub Actions workflows with the OIDC client ID"
        
    else
        print_error "Bootstrap deployment failed"
        exit 1
    fi
else
    print_warning "Deployment cancelled by user"
    exit 0
fi 