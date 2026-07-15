variable "network_interfaces" {}

data "azurerm_subnet" "data_block" {
  for_each = var.network_interfaces
  name                 = each.value.subnet_name
  virtual_network_name = each.value.virtual_network_name
  resource_group_name  = each.value.resource_group_name
}

resource "azurerm_public_ip" "pip" {
  for_each = var.network_interfaces
  name                = each.value.public_ip_name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  allocation_method   = "Static"
}


resource "azurerm_network_interface" "nic" {
  for_each = var.network_interfaces

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.data_block[each.key].id
    private_ip_address_allocation = "Dynamic"
   public_ip_address_id = azurerm_public_ip.pip[each.key].id
  }
}
resource "azurerm_resource_group" "rgs" {
    for_each = var.rgs
    name     = each.value.name
    location = each.value.location
}
variable "rgs" {}

resource "azurerm_storage_account" "storage" {
  for_each = var.storage_accounts

  name                     = each.value.name
  resource_group_name      = each.value.resource_group_name
  location                 = each.value.location
  account_tier             = each.value.account_tier
  account_replication_type = each.value.account_replication_type
}

resource "azurerm_subnet" "subnet" {
  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = each.value.resource_group_name
  virtual_network_name = each.value.virtual_network_name
  address_prefixes     = each.value.address_prefixes
}
resource "azurerm_virtual_network" "virtual_network" {
  for_each = var.vnets

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  address_space       = each.value.address_space
}
