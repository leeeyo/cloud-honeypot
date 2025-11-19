output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.test.ip_address
}

output "vm_private_ip" {
  description = "Private IP address of the VM"
  value       = azurerm_network_interface.test.ip_configuration[0].private_ip_address
}

output "vm_username" {
  description = "VM admin username"
  value       = var.vm_username
}

output "ssh_private_key" {
  description = "SSH private key (only if generated)"
  value       = var.generate_ssh_key ? tls_private_key.ssh[0].private_key_pem : null
  sensitive   = true
}

output "ssh_connection_command" {
  description = "Command to SSH into the VM"
  value       = var.generate_ssh_key ? "ssh -i ${path.module}/.terraform/ssh_key ${var.vm_username}@${azurerm_public_ip.test.ip_address}" : "ssh ${var.vm_username}@${azurerm_public_ip.test.ip_address}"
}

output "ansible_inventory_entry" {
  description = "Ansible inventory entry for this VM"
  value       = var.generate_ssh_key ? "vm-test:\n  ansible_host: ${azurerm_public_ip.test.ip_address}\n  ansible_user: ${var.vm_username}\n  ansible_ssh_private_key_file: ${path.module}/.terraform/ssh_key" : "vm-test:\n  ansible_host: ${azurerm_public_ip.test.ip_address}\n  ansible_user: ${var.vm_username}\n  ansible_ssh_private_key_file: ${replace(var.ssh_public_key_path, ".pub", "")}"
}

