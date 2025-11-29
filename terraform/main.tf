provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "test" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "test"
    Project     = "cloud-honeypot"
    ManagedBy   = "terraform"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "test" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = azurerm_resource_group.test.tags
}

# Subnet
resource "azurerm_subnet" "test" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group - Allow SSH and Application Ports
resource "azurerm_network_security_group" "test" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

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

  # Auth-Lib Application
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

  tags = azurerm_resource_group.test.tags
}

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "test" {
  subnet_id                 = azurerm_subnet.test.id
  network_security_group_id = azurerm_network_security_group.test.id
}

# Public IP
resource "azurerm_public_ip" "test" {
  name                = "${var.prefix}-publicip"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = azurerm_resource_group.test.tags
}

# Network Interface
resource "azurerm_network_interface" "test" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.test.id
  }

  tags = azurerm_resource_group.test.tags
}

# SSH Key - Generate if not provided
resource "tls_private_key" "ssh" {
  count     = var.generate_ssh_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
}

# VM - Using smallest cost-effective size
resource "azurerm_linux_virtual_machine" "test" {
  name                = "${var.prefix}-vm"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  size                = var.vm_size
  admin_username      = var.vm_username

  network_interface_ids = [
    azurerm_network_interface.test.id,
  ]

  # Use generated key or provided key
  admin_ssh_key {
    username   = var.vm_username
    public_key = var.generate_ssh_key ? tls_private_key.ssh[0].public_key_openssh : file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = azurerm_resource_group.test.tags
}
