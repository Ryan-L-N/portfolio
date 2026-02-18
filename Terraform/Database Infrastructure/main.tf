
#This terraform file will provision a SQL server with network based access controls, identity based access controls, and detection based access controls

resource "random_pet" "main" {
  length    = 2
  separator = ""
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_mssql_server" "main" {
  name                          = random_pet.main.id
  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  administrator_login           = var.db_admin_username
  administrator_login_password  = var.db_admin_password
  version                       = "12.0"
  public_network_access_enabled = "false"
  identity {
    type = "SystemAssigned" 
  }
}

resource "azurerm_mssql_database" "main" {
  server_id   = azurerm_mssql_server.main.id
  name        = var.db_name
  max_size_gb = 2
  sku_name    = "Basic"
}
resource "azurerm_private_dns_zone" "main" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_virtual_network" "main" {
  name                = random_pet.main.id
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  name                  = random_pet.main.id
  resource_group_name   = azurerm_resource_group.main.name
  virtual_network_id    = azurerm_virtual_network.main.id
  private_dns_zone_name = azurerm_private_dns_zone.main.name
}

resource "azurerm_subnet" "main" {
  name                 = random_pet.main.id
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_private_endpoint" "main" {
  name                             = random_pet.main.id
  location                         = azurerm_resource_group.main.location
  resource_group_name              = azurerm_resource_group.main.name
  subnet_id                        = azurerm_subnet.main.id
  custom_network_interface_name    = "${random_pet.main.id}_sql"
  private_service_connection {
    name                           = random_pet.main.id
    private_connection_resource_id = azurerm_mssql_server.main.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = random_pet.main.id
    private_dns_zone_ids = [azurerm_private_dns_zone.main.id]
  }
}

resource "azurerm_public_ip" "paw" {
  name                = random_pet.main.id
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "paw" {
  name                            = "${random_pet.main.id}_paw"
  location                        = azurerm_resource_group.main.location
  resource_group_name             = azurerm_resource_group.main.name
  ip_configuration {
    name                          = random_pet.main.id
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.paw.id
  }
}

resource "azurerm_network_security_group" "main" {
  name                         = random_pet.main.id
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "AzureCloud"
    destination_address_prefix = "*"
    destination_port_range     = "22"
  }
  security_rule {
    name                       = "DenyAll"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.paw.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_linux_virtual_machine" "paw" {
  name                            = random_pet.main.id
  resource_group_name             = azurerm_resource_group.main.name
  location                        = var.location
  size                            = var.vm_size
  network_interface_ids           = [
    azurerm_network_interface.paw.id
  ]
  disable_password_authentication = true
  admin_username                  = var.vm_admin_username
   admin_ssh_key {
    username                      = var.vm_admin_username
    public_key                    = file("~/.ssh/id_rsa.pub")
  }
  os_disk {
    caching                       = "ReadWrite"
    storage_account_type          = var.vm_os_disk_storage_type
    name                          = random_pet.main.id
  }
  source_image_reference {
    publisher                     = var.vm_image_publisher
    offer                         = var.vm_image_offer
    sku                           = var.vm_image_sku
    version                       = var.vm_image_version
  }
}

resource "azurerm_mssql_database_extended_auditing_policy" "main" {
  database_id            = azurerm_mssql_database.main.id
  log_monitoring_enabled = true
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = random_pet.main.id
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
}

resource "azurerm_monitor_diagnostic_setting" "main" {
  name                       = random_pet.main.id
  target_resource_id         = azurerm_mssql_database.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  enabled_log {
    category                 = "SQLSecurityAuditEvents"
  }
}
