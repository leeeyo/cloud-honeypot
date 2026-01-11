# =========================================
# TERRAFORM BACKEND CONFIGURATION
# Azure Storage Account for Remote State
# =========================================
#
# Prerequisites:
# 1. Create a Storage Account and Container in Azure (see docs/AZURE_SETUP.md)
# 2. Set environment variables or use Azure CLI authentication
#
# To initialize with backend:
#   terraform init -backend-config="storage_account_name=<your_storage_account>" \
#                  -backend-config="container_name=tfstate" \
#                  -backend-config="key=honeypot.tfstate" \
#                  -backend-config="resource_group_name=<your_rg>"
#
# =========================================

# Uncomment the block below to enable Azure remote state storage
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "terraform-state-rg"
#     storage_account_name = "yourterraformstate"
#     container_name       = "tfstate"
#     key                  = "honeypot.tfstate"
#   }
# }
