variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "francecentral"
}


variable "resource_group_name" {
  description = "test-ressource-group"
  type        = string
  default     = "cloud-honeypot-test"
}

variable "prefix" {
  description = "test"
  type        = string
  default     = "falco"
}

variable "vm_size" {
  description = "VM size (use B1s for smallest/cost-effective)"
  type        = string
  default     = "Standard_B1s"
}

variable "vm_username" {
  description = "azizmaram"
  type        = string
  default     = "azizmaram"
}

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

variable "auth_lib_port" {
  description = "Port for auth-lib application"
  type        = string
  default     = "9090"
}

