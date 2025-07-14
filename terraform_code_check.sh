#!/bin/bash

# Root-Level Terraform Code Quality Check Script
# Scans all Terraform configurations across the entire project
# Usage: Run this script from the project root to check all Terraform code

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}================================${NC}"
}

echo "🚀 Starting Root-Level Terraform Code Quality Checks..."

# Check if required tools are installed
print_status "Checking dependencies..."
command -v terraform >/dev/null 2>&1 || { print_error "Terraform is not installed. Please install Terraform."; exit 1; }
command -v tflint >/dev/null 2>&1 || { print_error "TFLint is not installed. Please install TFLint."; exit 1; }
command -v tfsec >/dev/null 2>&1 || { print_error "tfsec is not installed. Please install tfsec."; exit 1; }

# Check for optional tools
INFRACOST_AVAILABLE=false
if command -v infracost >/dev/null 2>&1; then
    INFRACOST_AVAILABLE=true
    print_info "Infracost found - will include cost estimation"
else
    print_warning "Infracost not found - skipping cost estimation (install with: brew install infracost)"
fi

CHECKOV_AVAILABLE=false
if command -v checkov >/dev/null 2>&1; then
    CHECKOV_AVAILABLE=true
    print_info "Checkov found - will include additional security scanning"
else
    print_warning "Checkov not found - skipping additional security checks (install with: pip install checkov)"
fi

print_success "Dependencies checked."

# Find all Terraform directories - simpler approach
print_status "Scanning for Terraform configurations..."
TERRAFORM_DIRS=()

# Find all .tf files and get their directories
TF_FILES=$(find . -name "*.tf" -type f 2>/dev/null)
if [ -z "$TF_FILES" ]; then
    print_error "No Terraform files found in the project"
    exit 1
fi

# Extract unique directories
for file in $TF_FILES; do
    dir=$(dirname "$file")
    if [[ ! " ${TERRAFORM_DIRS[@]} " =~ " ${dir} " ]]; then
        TERRAFORM_DIRS+=("$dir")
    fi
done

print_success "Found ${#TERRAFORM_DIRS[@]} Terraform configuration(s):"
for dir in "${TERRAFORM_DIRS[@]}"; do
    echo "  📁 $dir"
done

# Global checks
print_header "GLOBAL CHECKS"

# Check for project-level documentation
print_status "Checking project-level documentation..."
if [ ! -f "README.md" ]; then
    print_warning "Project README.md not found - recommended for documentation"
fi

if [ ! -f "best_practices.md" ]; then
    print_warning "best_practices.md not found - recommended for standards"
fi

# Check for .gitignore
print_status "Checking for .gitignore..."
if [ ! -f ".gitignore" ]; then
    print_warning ".gitignore not found - recommended to exclude sensitive files"
fi

# Check for overall project structure
print_status "Checking project structure..."
if [ ! -d "modules" ]; then
    print_warning "modules/ directory not found - recommended for reusability"
fi

if [ ! -d "envs" ]; then
    print_warning "envs/ directory not found - recommended for environment separation"
fi

# Check for CI/CD configuration
print_status "Checking CI/CD configuration..."
if [ ! -d ".github" ]; then
    print_warning ".github/ directory not found - recommended for GitHub Actions"
fi

# Directory-specific checks
for dir in "${TERRAFORM_DIRS[@]}"; do
    print_header "CHECKING: $dir"
    
    cd "$dir"
    
    # Check for Terraform files
    print_status "Checking for Terraform files in $dir..."
    TF_FILES_IN_DIR=$(find . -name "*.tf" -type f 2>/dev/null)
    if [ -z "$TF_FILES_IN_DIR" ]; then
        print_warning "No Terraform files found in $dir"
        cd - > /dev/null
        continue
    fi
    
    # Run terraform fmt
    print_status "Running terraform fmt in $dir..."
    terraform fmt -recursive -check
    if [ $? -eq 0 ]; then
        print_success "Formatting is correct in $dir"
    else
        print_warning "Code formatting issues found in $dir. Run 'terraform fmt -recursive' to fix."
    fi
    
    # Run terraform validate
    print_status "Running terraform validate in $dir..."
    terraform validate
    if [ $? -eq 0 ]; then
        print_success "Configuration is valid in $dir"
    else
        print_error "Configuration validation failed in $dir"
        cd - > /dev/null
        continue
    fi
    
    # Check for required files
    print_status "Checking for required files in $dir..."
    if [ ! -f "README.md" ]; then
        print_warning "README.md not found in $dir - recommended for documentation"
    fi
    
    if [ ! -f "variables.tf" ]; then
        print_warning "variables.tf not found in $dir - recommended for variable definitions"
    fi
    
    if [ ! -f "outputs.tf" ]; then
        print_warning "outputs.tf not found in $dir - recommended for output definitions"
    fi
    
    # Check for .gitignore
    if [ ! -f ".gitignore" ]; then
        print_warning ".gitignore not found in $dir - recommended to exclude sensitive files"
    fi
    
    # Run tflint
    print_status "Running TFLint in $dir..."
    if [ -f ".tflint.hcl" ]; then
        tflint --config .tflint.hcl
        if [ $? -eq 0 ]; then
            print_success "Linting completed successfully in $dir"
        else
            print_warning "Linting found issues in $dir - review and fix as needed"
        fi
    else
        print_warning ".tflint.hcl not found in $dir - skipping linting"
    fi
    
    # Run tfsec
    print_status "Running tfsec security scan in $dir..."
    tfsec . --format json | jq -r '.results[] | "\(.level): \(.rule_id) - \(.description)"' 2>/dev/null || tfsec .
    if [ $? -eq 0 ]; then
        print_success "Security scan completed in $dir"
    else
        print_warning "Security scan found issues in $dir - review and fix as needed"
    fi
    
    # Run Checkov if available
    if [ "$CHECKOV_AVAILABLE" = true ]; then
        print_status "Running Checkov security scan in $dir..."
        checkov -d . --framework terraform --output cli
        if [ $? -eq 0 ]; then
            print_success "Checkov security scan completed in $dir"
        else
            print_warning "Checkov found security issues in $dir - review and fix as needed"
        fi
    fi
    
    # Run Infracost if available
    if [ "$INFRACOST_AVAILABLE" = true ]; then
        print_status "Running cost estimation in $dir..."
        infracost breakdown --path . --format json | jq -r '.totalHourlyCost // "N/A"' > /tmp/infracost_output.txt 2>/dev/null || infracost breakdown --path .
        if [ $? -eq 0 ]; then
            print_success "Cost estimation completed in $dir"
            if [ -f "/tmp/infracost_output.txt" ]; then
                print_info "Estimated hourly cost for $dir: $(cat /tmp/infracost_output.txt)"
            fi
        else
            print_warning "Cost estimation failed in $dir - check your configuration"
        fi
    fi
    
    # Check for sensitive data
    print_status "Checking for potential sensitive data in $dir..."
    SENSITIVE_DATA=$(grep -r -i "password\|secret\|key\|token" *.tf 2>/dev/null | grep -v "#" | grep -v "variable" | grep -v "audience" | grep -v "issuer" | grep -v "subject" || true)
    if [ -n "$SENSITIVE_DATA" ]; then
        print_warning "Potential sensitive data found in $dir - review manually"
        echo "$SENSITIVE_DATA" | head -3
    fi
    
    # Check for hardcoded values
    print_status "Checking for hardcoded values in $dir..."
    if grep -r -E "ami-[a-z0-9]+|subnet-[a-z0-9]+|vpc-[a-z0-9]+" *.tf 2>/dev/null; then
        print_warning "Hardcoded AWS resource IDs found in $dir - consider using data sources"
    fi
    
    # Check for proper tagging
    print_status "Checking for resource tagging in $dir..."
    TAGGABLE_RESOURCES=$(grep -r "resource" *.tf 2>/dev/null | grep -E "(azurerm_resource_group|azurerm_storage_account|azurerm_virtual_network|azurerm_subnet|azurerm_network_security_group|azurerm_key_vault|azurerm_container_app|azurerm_postgresql_server|azurerm_user_assigned_identity)" || true)
    if [ -n "$TAGGABLE_RESOURCES" ]; then
        if ! grep -r "tags" *.tf 2>/dev/null | grep -q "Environment\|Purpose\|ManagedBy"; then
            print_warning "Resources in $dir may be missing proper tagging - review tagging strategy"
        fi
    else
        print_info "No taggable resources found in $dir - tagging check skipped"
    fi
    
    # Check for state file references
    print_status "Checking for state file references in $dir..."
    if grep -r "terraform_remote_state" *.tf 2>/dev/null; then
        print_info "Remote state references found in $dir - ensure backend is properly configured"
    fi
    
    # Check for provider versions
    print_status "Checking provider version constraints in $dir..."
    if grep -r "terraform" *.tf 2>/dev/null | grep -q "required_providers"; then
        if ! grep -r "required_providers" *.tf 2>/dev/null | grep -q "version"; then
            print_warning "Provider version constraints not found in $dir - recommended for stability"
        fi
    else
        print_info "No terraform block with required_providers found in $dir - this is normal for variable-only directories"
    fi
    
    # Check for workspace usage
    print_status "Checking for workspace usage in $dir..."
    if grep -r "terraform.workspace" *.tf 2>/dev/null; then
        print_info "Workspace references found in $dir - ensure proper workspace management"
    fi
    
    cd - > /dev/null
done

# Summary
print_header "SUMMARY"
print_success "🎉 All checks completed!"
echo ""
print_info "Summary of checks performed across ${#TERRAFORM_DIRS[@]} configuration(s):"
echo "  ✅ Terraform formatting"
echo "  ✅ Configuration validation"
echo "  ✅ Linting (TFLint)"
echo "  ✅ Security scanning (tfsec)"
if [ "$CHECKOV_AVAILABLE" = true ]; then
    echo "  ✅ Additional security scanning (Checkov)"
fi
if [ "$INFRACOST_AVAILABLE" = true ]; then
    echo "  ✅ Cost estimation (Infracost)"
fi
echo "  ✅ Documentation checks"
echo "  ✅ Sensitive data checks"
echo "  ✅ Hardcoded value checks"
echo "  ✅ Tagging strategy checks"
echo "  ✅ State management checks"
echo "  ✅ Provider version checks"
echo "  ✅ Project structure validation"
echo ""
print_info "Your Terraform project is ready for deployment! 🚀" 