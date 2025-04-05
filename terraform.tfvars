vpc_cidr_block            = "10.0.0.0/16"
public_subnet_cidr_block  = ["10.0.0.0/24", "10.0.1.0/24"]
private_subnet_cidr_block = ["10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
availability_zone         = ["eu-north-1a", "eu-north-1b"]
ssl_policy                = "ELBSecurityPolicy-2016-08"
certificate_arn           = "arn:aws:acm:eu-north-1:180294198914:certificate/cda50a43-bdf5-4877-a568-5eb83df3448d"
image_id                  = "ami-016038ae9cc8d9f51"
instance_type             = "t3.micro"
key_name                  = "Private Key Server"
zone_id                   = "Z07701862NOV34I3OT8RS"
dns_name                  = "learning1.awshub.org"
region                    = "eu-north-1"
account_id                = "180294198914"
engine_version            = "8.0"
instance_class            = "db.t3.micro"
db_username               = "admin"
parameter_group_name      = "default.mysql8.0"

