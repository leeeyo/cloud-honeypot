# =========================================
# AZURE HONEYPOT INFRASTRUCTURE
# Deploys multiple VMs with security monitoring
# =========================================

provider "azurerm" {
  features {}
}

# =========================================
# RESOURCE GROUP
# =========================================
resource "azurerm_resource_group" "honeypot" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = var.environment
    Project     = "cloud-honeypot"
    ManagedBy   = "terraform"
  }
}

# =========================================
# NETWORKING
# =========================================

# Virtual Network
resource "azurerm_virtual_network" "honeypot" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.honeypot.location
  resource_group_name = azurerm_resource_group.honeypot.name

  tags = azurerm_resource_group.honeypot.tags
}

# Subnet
resource "azurerm_subnet" "honeypot" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.honeypot.name
  virtual_network_name = azurerm_virtual_network.honeypot.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group - Allow SSH and Application Ports
resource "azurerm_network_security_group" "honeypot" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.honeypot.location
  resource_group_name = azurerm_resource_group.honeypot.name

  # SSH Access
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Auth-Lib Application (HTTP on custom port)
  security_rule {
    name                       = "AuthLib"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.auth_lib_port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # HTTP
  security_rule {
    name                       = "HTTP"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # HTTPS
  security_rule {
    name                       = "HTTPS"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # MySQL (internal access for honeypot)
  security_rule {
    name                       = "MySQL"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # LDAP (internal access for honeypot)
  security_rule {
    name                       = "LDAP"
    priority                   = 1006
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = azurerm_resource_group.honeypot.tags
}

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "honeypot" {
  subnet_id                 = azurerm_subnet.honeypot.id
  network_security_group_id = azurerm_network_security_group.honeypot.id
}

# =========================================
# PUBLIC IPs - One per VM
# =========================================
resource "azurerm_public_ip" "honeypot" {
  count               = var.vm_count
  name                = "${var.prefix}-vm-${count.index + 1}-publicip"
  location            = azurerm_resource_group.honeypot.location
  resource_group_name = azurerm_resource_group.honeypot.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge(azurerm_resource_group.honeypot.tags, {
    VM = "${var.prefix}-vm-${count.index + 1}"
  })
}

# =========================================
# NETWORK INTERFACES - One per VM
# =========================================
resource "azurerm_network_interface" "honeypot" {
  count               = var.vm_count
  name                = "${var.prefix}-vm-${count.index + 1}-nic"
  location            = azurerm_resource_group.honeypot.location
  resource_group_name = azurerm_resource_group.honeypot.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.honeypot.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.honeypot[count.index].id
  }

  tags = merge(azurerm_resource_group.honeypot.tags, {
    VM = "${var.prefix}-vm-${count.index + 1}"
  })
}

# =========================================
# SSH KEY - Generate if not provided
# =========================================
resource "tls_private_key" "ssh" {
  count     = var.generate_ssh_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private key locally for Ansible access
resource "local_file" "ssh_private_key" {
  count           = var.generate_ssh_key ? 1 : 0
  content         = tls_private_key.ssh[0].private_key_pem
  filename        = "${path.module}/.terraform/ssh_key"
  file_permission = "0600"
}

# =========================================
# VIRTUAL MACHINES - Honeypot VMs
# =========================================
resource "azurerm_linux_virtual_machine" "honeypot" {
  count               = var.vm_count
  name                = "${var.prefix}-vm-${count.index + 1}"
  location            = azurerm_resource_group.honeypot.location
  resource_group_name = azurerm_resource_group.honeypot.name
  size                = var.vm_size
  admin_username      = var.vm_username

  network_interface_ids = [
    azurerm_network_interface.honeypot[count.index].id,
  ]

  # Use generated key or provided key
  admin_ssh_key {
    username   = var.vm_username
    public_key = var.generate_ssh_key ? tls_private_key.ssh[0].public_key_openssh : file(var.ssh_public_key_path)
  }

  os_disk {
    name                 = "${var.prefix}-vm-${count.index + 1}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = merge(azurerm_resource_group.honeypot.tags, {
    Name = "${var.prefix}-vm-${count.index + 1}"
    Role = "honeypot"
  })
}
