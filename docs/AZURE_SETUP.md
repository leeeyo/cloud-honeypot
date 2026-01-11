# Azure Setup Guide

This guide explains how to configure Azure credentials and GitHub secrets for the Cloud Honeypot project.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Create Azure Service Principal](#create-azure-service-principal)
3. [Configure Terraform Backend Storage](#configure-terraform-backend-storage)
4. [Set Up GitHub Secrets](#set-up-github-secrets)
5. [Local Development Setup](#local-development-setup)
6. [Verification](#verification)

---

## Prerequisites

Before you begin, ensure you have:

- An active Azure subscription
- Azure CLI installed ([Installation Guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli))
- GitHub repository with admin access
- Git installed locally

---

## Create Azure Service Principal

The CI/CD pipeline needs an Azure Service Principal to authenticate and manage resources.

### Step 1: Login to Azure

```bash
az login
```

### Step 2: Get Your Subscription ID

```bash
az account show --query id -o tsv
```

Save this value - you'll need it as `AZURE_SUBSCRIPTION_ID`.

### Step 3: Create the Service Principal

```bash
# Replace <subscription-id> with your actual subscription ID
az ad sp create-for-rbac \
  --name "cloud-honeypot-cicd" \
  --role Contributor \
  --scopes /subscriptions/<subscription-id> \
  --sdk-auth
```

This command outputs JSON with your credentials:

```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  ...
}
```

Save these values:
- `clientId` → `AZURE_CLIENT_ID`
- `clientSecret` → `AZURE_CLIENT_SECRET`
- `subscriptionId` → `AZURE_SUBSCRIPTION_ID`
- `tenantId` → `AZURE_TENANT_ID`

---

## Configure Terraform Backend Storage

To enable remote state storage for Terraform:

### Step 1: Create Resource Group for State

```bash
az group create \
  --name terraform-state-rg \
  --location francecentral
```

### Step 2: Create Storage Account

```bash
# Storage account name must be globally unique (3-24 chars, lowercase + numbers only)
az storage account create \
  --name yourstorageaccount \
  --resource-group terraform-state-rg \
  --location francecentral \
  --sku Standard_LRS \
  --encryption-services blob
```

### Step 3: Create Blob Container

```bash
az storage container create \
  --name tfstate \
  --account-name yourstorageaccount
```

### Step 4: Get Storage Account Key

```bash
az storage account keys list \
  --resource-group terraform-state-rg \
  --account-name yourstorageaccount \
  --query '[0].value' -o tsv
```

### Step 5: Update backend.tf

Uncomment and update the backend configuration in `terraform/backend.tf`:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "yourstorageaccount"
    container_name       = "tfstate"
    key                  = "honeypot.tfstate"
  }
}
```

---

## Set Up GitHub Secrets

Navigate to your GitHub repository → Settings → Secrets and variables → Actions.

### Required Secrets

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `AZURE_CLIENT_ID` | Service Principal Client ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_CLIENT_SECRET` | Service Principal Secret | `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` |
| `AZURE_SUBSCRIPTION_ID` | Azure Subscription ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_TENANT_ID` | Azure Tenant ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `SSH_PRIVATE_KEY` | SSH private key for VM access | `-----BEGIN RSA PRIVATE KEY-----...` |
| `VM_HOST` | VM public IP (after terraform apply) | `52.143.xx.xx` |
| `VM_USER` | VM admin username | `azizmaram` |

### Optional Secrets

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `SONAR_TOKEN` | SonarQube authentication token | `squ_xxxxxxxxxxxx` |
| `SONAR_HOST_URL` | SonarQube server URL | `https://sonarcloud.io` |

### Adding a Secret

1. Click "New repository secret"
2. Enter the secret name (e.g., `AZURE_CLIENT_ID`)
3. Enter the secret value
4. Click "Add secret"

---

## Local Development Setup

For local testing and development:

### Option 1: Environment Variables

```bash
# Add to ~/.bashrc or ~/.zshrc
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"
```

### Option 2: Azure CLI Authentication

```bash
# Login to Azure
az login

# Set subscription
az account set --subscription "your-subscription-id"

# Terraform will automatically use Azure CLI credentials
```

### Option 3: terraform.tfvars (Not Recommended for Secrets)

Create `terraform/terraform.tfvars`:

```hcl
location            = "francecentral"
resource_group_name = "cloud-honeypot-rg"
vm_count            = 2
vm_size             = "Standard_B1s"
vm_username         = "azizmaram"
```

> **Warning**: Never commit sensitive values to terraform.tfvars. Use environment variables or Azure Key Vault instead.

---

## Verification

### Verify Azure CLI Login

```bash
az account show
```

### Verify Service Principal

```bash
az login --service-principal \
  -u $ARM_CLIENT_ID \
  -p $ARM_CLIENT_SECRET \
  --tenant $ARM_TENANT_ID

az account show
```

### Verify Terraform Access

```bash
cd terraform
terraform init
terraform plan
```

### Verify GitHub Actions

1. Push a change to the repository
2. Go to Actions tab
3. Check that the workflow runs successfully

---

## Troubleshooting

### "AuthorizationFailed" Error

The service principal doesn't have sufficient permissions. Assign the Contributor role:

```bash
az role assignment create \
  --assignee $ARM_CLIENT_ID \
  --role Contributor \
  --scope /subscriptions/$ARM_SUBSCRIPTION_ID
```

### "SubscriptionNotFound" Error

Ensure you're using the correct subscription ID:

```bash
az account list --output table
```

### "InvalidClientSecret" Error

The service principal secret may have expired. Create a new one:

```bash
az ad sp credential reset --name "cloud-honeypot-cicd"
```

Update the `AZURE_CLIENT_SECRET` GitHub secret with the new value.

### SSH Connection Issues

1. Ensure the VM is running
2. Check NSG rules allow SSH (port 22)
3. Verify the SSH key matches:
   ```bash
   ssh -i path/to/key -v azizmaram@<vm-ip>
   ```

---

## Security Best Practices

1. **Rotate Secrets Regularly**: Update service principal credentials every 90 days
2. **Use Least Privilege**: Only grant necessary permissions
3. **Enable MFA**: Require multi-factor authentication for Azure accounts
4. **Monitor Activity**: Enable Azure Activity Log alerts
5. **Secure State File**: Use Azure backend with encryption for Terraform state
6. **Never Commit Secrets**: Use `.gitignore` to exclude sensitive files

---

## Quick Reference

### Azure CLI Commands

```bash
# Login
az login

# List subscriptions
az account list --output table

# Set subscription
az account set --subscription "subscription-id"

# List resource groups
az group list --output table

# List VMs
az vm list --output table

# Get VM public IP
az vm list-ip-addresses --output table
```

### Terraform Commands

```bash
# Initialize
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy resources
terraform destroy

# Show outputs
terraform output
```

