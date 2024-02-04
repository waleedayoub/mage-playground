variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "waleed-dataeng-rg"
}

variable "location" {
  description = "The Azure location where resources will be created"
  type        = string
  default     = "East US"
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "example-network"
}

variable "address_space" {
  description = "The address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
  default     = "mage-subnet"
}

variable "subnet_prefixes" {
  description = "The address prefixes for the subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "network_interface_name" {
  description = "The name of the network interface"
  type        = string
  default     = "mage-nic"
}

variable "vm_name" {
  description = "The name of the virtual machine"
  type        = string
  default     = "mage-vm"
}

variable "vm_size" {
  description = "The size of the virtual machine"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "admin_username" {
  description = "The admin username for the virtual machine"
  type        = string
  default     = "waleed"
}

variable "public_key_path" {
  description = "The path to the public SSH key to be used for the VM"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
  default     = "magestorageaccount"
}

variable "account_tier" {
  description = "The tier of the storage account"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "The replication type of the storage account"
  type        = string
  default     = "GRS"
}
