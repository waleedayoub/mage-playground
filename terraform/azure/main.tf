provider "azurerm" {
  features {}
  subscription_id = "42d84820-6eee-4626-a4c5-2dd581b2a5b6"
}

resource "azurerm_resource_group" "rg" {
  name     = "waleed-dataeng-tf"
  location = "East US"
  tags = {
    owner  = "waleed"
    source = "terraform"
  }
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "magestorageaccount1"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  name                  = "magestoragecontainer"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}


resource "azurerm_virtual_network" "vnet" {
  name                = "mage-vnet-tf"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "mage-subnet-tf"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "mage-nsg-tf"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

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
}

resource "azurerm_public_ip" "pip" {
  name                = "mage-vm-pip-tf"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  name                = "mage-vm-nic-tf"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "mage-vm-tf"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_DS3_v2"
  admin_username      = "waleed"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  admin_ssh_key {
    username   = "waleed"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDGXnIg6U908IOdtNr4j6mN2pjt1c9/nIcNrrt2REgBAUUpEwGnSzP+4spoWYJiMm7D4ed9OO9DRv+D0xgnwOMovbcK8e07csHT0ujPE2KsHyhehwFYB8nGtlzQa979FW0od6srGYwL/6YEYMnUcSBvHDgP/yHpVnT2Gl6lnLiqA33ExtFy2qe7ZJOB+or316xjmG/yCVPHg0KCBj4DCUvv/hQGSHsu6aodtdHk6KlBMF1AtIk0YtinD+vb7Cj7ATFeETniOCbn5QLbcpFA4H6QtMwg07pJePl2/xQcK4OBoNFaSP2xckqIQmRRunLzQRSQIE6U8tglwfx7u/8C6EC7j1S7jbpQ/BPvu4ZHEI5y9xZbo5FopYGhv1xJXBlNMtJwzTU3vPV1R8ATxUjm+l398Kmy9c0mz+7Rg39kzXTalUlb3n9vzEH2HvHL0hgNi16FNEjDsA8EZ7hwGTod3CZHnHc5qPPlElxhL4xhUnB6sP1jyTbRsjQNYaEMOS1e4g++zVp0FMUv2irf6EGFIPuFsIkXxwLD9kM+tuCKqeh1ZEujs7xWGJ9tVSzPhqaJjNQLh7nFZSeFwtsQQGOYTIYdbJ6T4ozbgbx4Jm9KRwKnuJTZfljyqv+v9yOjL5uKg27NLV7wQc4dvimNs+zTMhmphr0LUW/yW0JsCy2NDKSFSw== waleed@thirteen2"
  }

  disable_password_authentication = true
}

resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
