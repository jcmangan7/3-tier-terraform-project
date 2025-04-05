resource "aws_db_subnet_group" "apci_jupiter_db_subnet_group" {
  name       = "apci-jupiter-db-subnet-group"
  subnet_ids = [var.apci_jupiter_db_subnet_az_1a_id, var.apci_jupiter_db_subnet_az_1b_id]

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-subnet-az-1b"
  })
}

# Creating RDS Security Group
resource "aws_security_group" "apci_jupiter_rds_sg" {
  name        = "rds-sg"
  description = "Allow DB Traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "allow_rds_traffic"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_db_traffic" {
  security_group_id = aws_security_group.apci_jupiter_rds_sg.id
  cidr_ipv4         = var.vpc_cidr_block 
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}



resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.apci_jupiter_rds_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Referencing an already created secret from AWS Secrets Manager
data "aws_secretsmanager_secret" "apci_jupiter_rdsmysql" {
  name = "rdsmysql3"
}

data "aws_secretsmanager_secret_version" "apci_jupiter_secret_version" {    # this is used to reference the password for the db and check the script
  secret_id = data.aws_secretsmanager_secret.apci_jupiter_rdsmysql.id
}

# Creating RDS Secrets Manager IAM Role
# resource "aws_iam_role" "rds_secrets_manager_role" {
#   name = "rds-secrets-manager-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Service = "rds.amazonaws.com"
#       }
#       Action = "sts:AssumeRole"
#     }]
#   })
# }

# resource "aws_iam_policy" "secrets_manager_policy" {
#   name        = "rds-secrets-manager-policy"
#   description = "Policy to allow RDS to access Secrets Manager"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "secretsmanager:GetSecretValue"
#         ]
#         Resource = "arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:rdsmysql2-*" # Make changes here
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "attach_secrets_manager_policy" {
#   role       = aws_iam_role.rds_secrets_manager_role.name
#   policy_arn = aws_iam_policy.secrets_manager_policy.arn
# }


# Creating the RDS MySQL Instance
resource "aws_db_instance" "apci_jupiter_mydb" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  username             = var.db_username 
  password             = jsondecode(data.aws_secretsmanager_secret_version.apci_jupiter_secret_version.secret_string)["password"]
  parameter_group_name = var.parameter_group_name
  db_subnet_group_name = aws_db_subnet_group.apci_jupiter_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.apci_jupiter_rds_sg.id]
  skip_final_snapshot  = true
}