variable "location" {
  type    = string
  default = "eastus2"
}

variable "resource_group_name" {
  type    = string
  default = "cloud-security-task-04"
}

variable "db_name" {
  type    = string
  default = "vulnerable-db"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "vm_image_publisher" {
  type    = string
  default = "Canonical" 
}

variable "vm_image_offer" {
  type    = string
  default = "0001-com-ubuntu-server-jammy" 
}

variable "vm_image_sku" {
  type    = string
  default = "22_04-lts" 
}

variable "vm_image_version" {
  type    = string
  default = "latest" 
}

variable "vm_os_disk_storage_type" {
  type    = string
  default = "StandardSSD_LRS"
}

variable "vm_admin_username" {
  type    = string
  default = "andy"
}

variable "vm_admin_password" {
  type   = string
}

variable "db_admin_username" {
  type    = string
  default = "bonnie"
}

variable "db_admin_password" {
  type   = string
}
