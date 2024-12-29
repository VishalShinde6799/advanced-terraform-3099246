provider "azurerm" {
  features {}
  subscription_id = var.subscriptionID
  tenant_id       = var.tenantID
}


resource "azurerm_resource_group" "resource-group" {
  name     = "${var.location}-${var.environment_name_map[var.target_environment]}-rg"
  location = "East US"

  tags = {
    environment = var.environment_name_map[var.target_environment]
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.location}-${var.environment_name_map[var.target_environment]}-vnet"
  resource_group_name = azurerm_resource_group.resource-group.name
  location            = azurerm_resource_group.resource-group.location
  address_space       = [var.environmet_vnet_cidr_map[var.target_environment]]

  tags = {
    environment = var.environment_name_map[var.target_environment]
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.location}-${var.environment_name_map[var.target_environment]}-subnet"
  resource_group_name  = azurerm_resource_group.resource-group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.environment_subnet_cidr_map[var.target_environment]]
}

resource "azurerm_network_security_group" "subnet-nsg" {
  name                = "${var.location}-${var.environment_name_map[var.target_environment]}-subnet-nsg1"
  resource_group_name = azurerm_resource_group.resource-group.name
  location            = azurerm_resource_group.resource-group.location

  tags = {
    environment = var.environment_name_map[var.target_environment]
  }
}

resource "azurerm_subnet_network_security_group_association" "subnet-nsg-association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.subnet-nsg.id
}

resource "azurerm_public_ip" "public-ip" {
  name                = "${var.location}-${var.environment_name_map[var.target_environment]}-public-ip"
  resource_group_name = azurerm_resource_group.resource-group.name
  location            = azurerm_resource_group.resource-group.location
  allocation_method   = "Dynamic"
  sku                 = "Basic"

  tags = {
    environment = var.environment_name_map[var.target_environment]
  }
}

resource "azurerm_network_interface" "net-interface-card" {
  name                = "${var.location}-${var.environment_name_map[var.target_environment]}-net-interface-card"
  location            = azurerm_resource_group.resource-group.location
  resource_group_name = azurerm_resource_group.resource-group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public-ip.id
  }

  tags = {
    environment = var.environment_name_map[var.target_environment]
  }
}

resource "azurerm_linux_virtual_machine" "linux-vm" {
  name                = "${var.location}-${var.environment_name_map[var.target_environment]}-linux-vm"
  resource_group_name = azurerm_resource_group.resource-group.name
  location            = azurerm_resource_group.resource-group.location
  size                = var.environment_vm_sku_map[var.target_environment]
  admin_username      = "vshinde"
  network_interface_ids = [
    azurerm_network_interface.net-interface-card.id
  ]

  admin_ssh_key {
    username   = "vshinde"
    public_key = file("~/.ssh/azure_key.pub")
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

  tags = {
    environment = var.environment_name_map[var.target_environment]
  }
}

data "azurerm_public_ip" "public-ip-data" {
  name                = azurerm_public_ip.public-ip.name
  resource_group_name = azurerm_resource_group.resource-group.name
}

data "azurerm_subnet" "subnet-data" {
  name                 = azurerm_subnet.subnet.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.resource-group.name
}

resource "azurerm_network_security_rule" "example" {
  name                         = "allow-${azurerm_subnet.subnet.name}-ssh"
  priority                     = 100
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "*"
  source_port_range            = "*"
  destination_port_range       = "22"
  source_address_prefix        = "*"
  destination_address_prefixes = data.azurerm_subnet.subnet-data.address_prefixes
  resource_group_name          = azurerm_resource_group.resource-group.name
  network_security_group_name  = azurerm_network_security_group.subnet-nsg.name
}