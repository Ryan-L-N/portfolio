output "public_ip" {
  description = "The public IP of the virtual machine. You can access this IP using your browser to see the hosted web page."
  value       = azurerm_public_ip.myterraformpublicip.ip_address
}

output "vm_connection_guide" {
  value     = "To connect to your virtual machine via SSH: ssh ${var.admin_username}@${azurerm_public_ip.myterraformpublicip.ip_address}\nPassword: ${random_password.password.result}"
  sensitive = true
}