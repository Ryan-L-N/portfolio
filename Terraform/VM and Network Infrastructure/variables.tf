variable "location" {
  type    = string
  default = "eastus"
}

variable "admin_username" {
  type    = string
  default = "clouduser"
}

# TODO: Your task is to add another variable named as "prefix" with type "string" and default value "task2TF"

variable "prefix" {
  type = string
  default = "task4TF"
}