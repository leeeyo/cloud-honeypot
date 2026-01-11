# =========================================
# AZURE HONEYPOT - TERRAFORM VARIABLES
# =========================================

# =========================================
# AZURE CONFIGURATION
# =========================================
variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "francecentral"
}

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "cloud-honeypot-rg"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "honeypot"
}

# =========================================
# VM CONFIGURATION
# =========================================
variable "vm_count" {
  description = "Number of honeypot VMs to create"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "Azure VM size (Standard_B1s is smallest/cost-effective)"
  type        = string
  default     = "Standard_B1s"
}

variable "vm_username" {
  description = "Admin username for the VMs"
  type        = string
  default     = "azizmaram"
}

# =========================================
# SSH CONFIGURATION
# =========================================
variable "generate_ssh_key" {
  description = "Generate SSH key automatically (if false, use ssh_public_key_path)"
  type        = bool
  default     = true
}

variable "ssh_public_key_path" {
  description = "Path to existing SSH public key (if generate_ssh_key is false)"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

# =========================================
# APPLICATION CONFIGURATION
# =========================================
variable "auth_lib_port" {
  description = "Port for the auth-lib application"
  type        = string
  default     = "9090"
}
