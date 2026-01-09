# Create a variable called "location" of type string and default value of "eastus"
variable "location" {
  type = string
  default = "eastus"
}

# Create a variable called "admin_username" of type string and default value of "student"
variable "admin_username" {
  default = "student"
}

# Create a variable called "admin_password" of type string and default value of "p@55w0rd"
variable "admin_password" {
  default = "p@55w0rd"
}