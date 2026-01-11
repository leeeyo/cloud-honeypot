# =========================================
# TERRAFORM OUTPUTS
# =========================================

# =========================================
# VM INFORMATION
# =========================================
output "vm_count" {
  description = "Number of VMs created"
  value       = var.vm_count
}

output "vm_names" {
  description = "Names of all honeypot VMs"
  value       = [for vm in azurerm_linux_virtual_machine.honeypot : vm.name]
}

output "vm_public_ips" {
  description = "Public IP addresses of all VMs"
  value       = [for ip in azurerm_public_ip.honeypot : ip.ip_address]
}

output "vm_private_ips" {
  description = "Private IP addresses of all VMs"
  value       = [for nic in azurerm_network_interface.honeypot : nic.ip_configuration[0].private_ip_address]
}

output "vm_username" {
  description = "VM admin username"
  value       = var.vm_username
}

# =========================================
# SSH ACCESS
# =========================================
output "ssh_private_key" {
  description = "SSH private key (only if generated)"
  value       = var.generate_ssh_key ? tls_private_key.ssh[0].private_key_pem : null
  sensitive   = true
}

output "ssh_private_key_path" {
  description = "Path to SSH private key file"
  value       = var.generate_ssh_key ? "${path.module}/.terraform/ssh_key" : replace(var.ssh_public_key_path, ".pub", "")
}

output "ssh_commands" {
  description = "SSH commands to connect to each VM"
  value = [
    for idx, ip in azurerm_public_ip.honeypot :
    var.generate_ssh_key
    ? "ssh -i ${path.module}/.terraform/ssh_key ${var.vm_username}@${ip.ip_address}"
    : "ssh ${var.vm_username}@${ip.ip_address}"
  ]
}

# =========================================
# ANSIBLE INVENTORY (YAML format)
# =========================================
output "ansible_inventory" {
  description = "Ansible inventory in YAML format"
  value       = <<-EOT
all:
  children:
    linux:
      hosts:
%{for idx, ip in azurerm_public_ip.honeypot~}
        ${var.prefix}-vm-${idx + 1}:
          ansible_host: ${ip.ip_address}
          ansible_user: ${var.vm_username}
          ansible_ssh_private_key_file: ${var.generate_ssh_key ? "${path.module}/.terraform/ssh_key" : replace(var.ssh_public_key_path, ".pub", "")}
%{endfor~}
EOT
}

# =========================================
# NETWORKING INFO
# =========================================
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.honeypot.name
}

output "virtual_network_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.honeypot.name
}

output "subnet_name" {
  description = "Name of the subnet"
  value       = azurerm_subnet.honeypot.name
}

output "nsg_name" {
  description = "Name of the network security group"
  value       = azurerm_network_security_group.honeypot.name
}

# =========================================
# APPLICATION URLS
# =========================================
output "auth_lib_urls" {
  description = "URLs to access auth-lib on each VM"
  value = [
    for ip in azurerm_public_ip.honeypot :
    "http://${ip.ip_address}:${var.auth_lib_port}"
  ]
}

output "auth_lib_login_urls" {
  description = "Login page URLs for each VM"
  value = [
    for ip in azurerm_public_ip.honeypot :
    "http://${ip.ip_address}:${var.auth_lib_port}/login"
  ]
}
