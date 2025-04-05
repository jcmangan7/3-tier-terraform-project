variable "apci_jupiter_db_subnet_az_1a_id" {
  type = string
}

variable "apci_jupiter_db_subnet_az_1b_id" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "instance_class" {
  type = string
}

variable "db_username" {
  type = string
}

variable "parameter_group_name" {
  type = string
}

variable "apci_jupiter_bastion_sg_id" {
  type = string
}