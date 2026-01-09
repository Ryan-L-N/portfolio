terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "=3.0.0"
        }
    }
    # TODO: Add in remote backend (for Task 5)
     backend "azurerm" {
     resource_group_name  = "storage-resource-group"
     storage_account_name = "nevillestorageaccount"
     container_name       = "terraform"
     key                  = "terraform.tfstate"
   }
}

# Configure the provider
provider "azurerm" {
    features {}
}

# Create a new resource group
resource "azurerm_resource_group" "rg" {
    name = "terraform_project_rg"
    # Reference the variable "location" and use its value
    location = var.location
    
    tags = {
        environment = "TF sandbox"
    }
}


module "vpc" {
    source              = "./vpc"
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name
}

module "vm" {
    source               = "./vm"
    location             = var.location
    admin_username       = var.admin_username
    admin_password       = var.admin_password
    resource_group_name  = azurerm_resource_group.rg.name
    public_ip_address    = module.vpc.public_ip_address
    network_interface_id = module.vpc.network_interface_id
}

# Define the list of output that Terraform should produce
output "vm_ip" {
    value = module.vpc.public_ip_address
}