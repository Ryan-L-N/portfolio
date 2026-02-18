# This prepared Terraform module declares an Azure resource group, an Azure virtual machine
# and other supportive resources for networking.
#
# Configure the provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.22.0"
    }
  }
}
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Create a new resource group
resource "azurerm_resource_group" "myterraformgroup" {
  name     = "${var.prefix}-resources"
  location = var.location
  tags     = local.common_tags
}


# Create a virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  tags                = local.common_tags
}

# Create a subnet
resource "azurerm_subnet" "myterraformsubnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.myterraformgroup.name
  virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a static public IP
resource "azurerm_public_ip" "myterraformpublicip" {
  name                = "${var.prefix}-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"
  tags                = local.common_tags
}

# Create a network security group
resource "azurerm_network_security_group" "myterraformnsg" {
  name                = "${var.prefix}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  tags                = local.common_tags
}

# Create a network security group rule
# This rule opens the port 80 to the public
resource "azurerm_network_security_rule" "http" {
  name                        = "http"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.myterraformgroup.name
  network_security_group_name = azurerm_network_security_group.myterraformnsg.name
}

# Create a network security group rule
# This rule opens the port 22 to the public
resource "azurerm_network_security_rule" "ssh" {
  name                        = "ssh"
  priority                    = 320
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.myterraformgroup.name
  network_security_group_name = azurerm_network_security_group.myterraformnsg.name
}

# Create a network interface
resource "azurerm_network_interface" "myterraformnic" {
  name                = "${var.prefix}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  ip_configuration {
    name                          = "${var.prefix}-nic-conf"
    subnet_id                     = azurerm_subnet.myterraformsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
  }
  tags = local.common_tags
}

resource "azurerm_network_interface_security_group_association" "myterraformNISG" {
  network_interface_id      = azurerm_network_interface.myterraformnic.id
  network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

# Use a cryptographic random number to generate a password.
# Reference: https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
resource "random_password" "password" {
  length           = 16
  special          = true
  lower            = true
  upper            = true
  numeric          = true
  override_special = "_%@"
}

# Create a virtual machine
# Reference: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine
resource "azurerm_virtual_machine" "myterraformvm" {
  name                  = "${var.prefix}-vm"
  location              = var.location
  resource_group_name   = azurerm_resource_group.myterraformgroup.name
  network_interface_ids = [azurerm_network_interface.myterraformnic.id]
  vm_size               = "Standard_B1ms"
  storage_os_disk {
    name              = "myOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }
  # Select Ubuntu 18.04 as the OS Image
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  # SSH username and password
  os_profile {
    computer_name  = "myvm"
    admin_username = var.admin_username
    admin_password = random_password.password.result
  }
  os_profile_linux_config {
    # Enable SSH password authentication.
    disable_password_authentication = false
  }
  tags = local.common_tags

  # The remote-exec provisioner invokes a script on a remote resource after it is created.
  # This can be used to run a configuration management tool, bootstrap into a cluster, etc.
  provisioner "remote-exec" {
    # The remote-exec provisioner supports both different type connections and we are using SSH here.
    # This is similar to the Linux command `ssh var.admin_username@azurerm_public_ip.myterraformpublicip.ip_address`
    connection {
      type     = "ssh"
      user     = var.admin_username
      password = random_password.password.result
      host     = azurerm_public_ip.myterraformpublicip.ip_address
    }
    # The commands to execute
    inline = [
      # install Apache2 and start the web server
      "sudo apt-get -y update",
      "sudo apt-get -y install apache2",
      # modify the index.html page
      "echo Welcome! | sudo tee /var/www/html/index.html"
    ]
  }
}

locals {
  # Common tags to be assigned to all resources
  # Referred to as "local.common_tags"
  #
  # A local value is used here, instead of an input variable.
  #
  # (Optional Reading) Local Values
  #
  # Comparing modules to functions in a traditional programming language:
  # if input variables are analogous to function arguments,
  # and outputs values are analogous to function return values,
  # then local values are comparable to a function's local temporary symbols.
  #
  # "local.common_tags" depends on "var.prefix", therefore "local.common_tags" cannot
  # be directly defined as an input variable, instead, the value of "local.common_tags" is
  # constructed with the reference of "var.prefix", similar to how a function's local
  # values get computed from function input arguments.
  #
  # Reference:
  # https://www.terraform.io/docs/configuration/locals.html
  common_tags = {
    environment = var.prefix
  }
}
