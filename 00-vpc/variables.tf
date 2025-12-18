variable "cidr_block" {
  default = "10.1.0.0/16"
}

variable "project_name" {
  default = "roboshop"
}

variable "environment" {
  default = "dev"
}

variable "vpc_tags" {
  default = {
    Purpose    = "Roboshop VPC"
    DontDelete = "true"
  }
}

variable "public_subnet_cidrs" {
  default = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "private_subnet_cidrs" {
  default = ["10.1.11.0/24", "10.1.12.0/24"]
}

variable "database_subnet_cidrs" {
  default = ["10.1.21.0/24", "10.1.22.0/24"]
}
