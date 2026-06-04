# 1. Azure Resource Group
resource "azurerm_resource_group" "polyglot_rg" {
  name     = var.resource_group_name
  location = var.location
}

# 2. Virtual Network (VNet)
resource "azurerm_virtual_network" "polyglot_vnet" {
  name                = "polyglot-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.polyglot_rg.location
  resource_group_name = azurerm_resource_group.polyglot_rg.name
}

# 3. Subnet
resource "azurerm_subnet" "polyglot_subnet" {
  name                 = "polyglot-subnet"
  resource_group_name  = azurerm_resource_group.polyglot_rg.name
  virtual_network_name = azurerm_virtual_network.polyglot_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 4. Public IP (Fixed Standard SKU for Student Accounts)
resource "azurerm_public_ip" "polyglot_public_ip" {
  name                = "polyglot-public-ip"
  location            = azurerm_resource_group.polyglot_rg.location
  resource_group_name = azurerm_resource_group.polyglot_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 5. Network Security Group (Firewall Rules)
resource "azurerm_network_security_group" "polyglot_nsg" {
  name                = "polyglot-nsg"
  location            = azurerm_resource_group.polyglot_rg.location
  resource_group_name = azurerm_resource_group.polyglot_rg.name

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

  security_rule {
    name                       = "Frontend"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Backend"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# 6. Network Interface (NIC) - Fresh Name to Avoid State Conflicts
resource "azurerm_network_interface" "polyglot_nic_v3" {
  name                = "polyglot-nic"
  location            = azurerm_resource_group.polyglot_rg.location
  resource_group_name = azurerm_resource_group.polyglot_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.polyglot_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.polyglot_public_ip.id
  }
}

# NSG ko NIC ke sath jorhna
resource "azurerm_network_interface_security_group_association" "connect" {
  network_interface_id      = azurerm_network_interface.polyglot_nic_v3.id
  network_security_group_id = azurerm_network_security_group.polyglot_nsg.id
}

# 7. Linux Virtual Machine (VM) Provisioning
resource "azurerm_linux_virtual_machine" "devops_vm" {
  name                = "polyglot-vm"
  resource_group_name = azurerm_resource_group.polyglot_rg.name
  location            = azurerm_resource_group.polyglot_rg.location
  size                = var.vm_size
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.polyglot_nic_v3.id,
  ]

  disable_password_authentication = false
  admin_password                  = "DevOpsProject2026!" 

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
}