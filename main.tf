# Configure the AWS Provider
provider "aws" {
  region = "eu-north-1"
}

module "vpc" {
  source                    = "./vpc"
  vpc_cidr_block            = var.vpc_cidr_block
  tags                      = local.project_tags
  public_subnet_cidr_block  = var.public_subnet_cidr_block
  private_subnet_cidr_block = var.private_subnet_cidr_block
  availability_zone         = var.availability_zone
}

module "alb" {
  source                              = "./alb"
  apci_jupiter_public_subnet_az_1a_id = module.vpc.apci_jupiter_public_subnet_az_1a_id
  apci_jupiter_public_subnet_az_1b_id = module.vpc.apci_jupiter_public_subnet_az_1b_id
  vpc_id                              = module.vpc.vpc_id
  tags                                = local.project_tags
  ssl_policy                          = var.ssl_policy
  certificate_arn                     = var.certificate_arn
}

module "asg" {
  source                              = "./asg"
  tags                                = local.project_tags
  apci_jupiter_alb_sg_id              = module.alb.apci_jupiter_alb_sg_id
  vpc_id                              = module.vpc.vpc_id
  instance_type                       = var.instance_type
  key_name                            = var.key_name
  image_id                            = var.image_id
  apci_jupiter_public_subnet_az_1a_id = module.vpc.apci_jupiter_public_subnet_az_1a_id
  apci_jupiter_public_subnet_az_1b_id = module.vpc.apci_jupiter_public_subnet_az_1b_id
  apci_jupiter_target_group_arn       = module.alb.apci_jupiter_target_group_arn
}

module "route53" {
  source                    = "./route53"
  apci_jupiter_alb_dns_name = module.alb.apci_jupiter_alb_dns_name
  apci_jupiter_alb_zone_id  = module.alb.apci_jupiter_alb_zone_id
  dns_name                  = var.dns_name # from terraform
  zone_id                   = var.zone_id  #from terraform
}

module "rds" {
  source                          = "./rds"
  apci_jupiter_db_subnet_az_1a_id = module.vpc.apci_jupiter_db_subnet_az_1a_id
  apci_jupiter_db_subnet_az_1b_id = module.vpc.apci_jupiter_db_subnet_az_1b_id
  tags                            = local.project_tags
  region                          = var.region
  parameter_group_name            = var.parameter_group_name
  vpc_cidr_block                  = var.vpc_cidr_block
  engine_version                  = var.engine_version
  vpc_id                          = module.vpc.vpc_id
  account_id                      = var.account_id
  db_username                     = var.db_username
  instance_class                  = var.instance_class
  apci_jupiter_bastion_sg_id      = module.ec2.apci_jupiter_bastion_sg_id
  
}

module "ec2" {
  source                               = "./ec2"
  apci_jupiter_private_subnet_az_1a_id = module.vpc.apci_jupiter_private_subnet_az_1a_id
  apci_jupiter_private_subnet_az_1b_id = module.vpc.apci_jupiter_private_subnet_az_1b_id
  apci_jupiter_public_subnet_az_1a_id  = module.vpc.apci_jupiter_public_subnet_az_1a_id
  tags                                 = local.project_tags
  vpc_id                               = module.vpc.vpc_id
  key_name                             = var.key_name
  image_id                             = var.image_id
  instance_type                        = var.instance_type
}