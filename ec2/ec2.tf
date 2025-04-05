# Creating Bastion Host Security Group
resource "aws_security_group" "apci_jupiter_bastion_sg" {
  name        = "apci-jupiter-bastion-sg"
  description = "Allow SSH traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "bastion_host_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.apci_jupiter_bastion_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_ssh_outbound_traffic" {
  security_group_id = aws_security_group.apci_jupiter_bastion_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Creating a Bastion Host 
resource "aws_instance" "bastion_host" {
  ami           = var.image_id # us-west-2
  instance_type = var.instance_type
  security_groups = [aws_security_group.apci_jupiter_bastion_sg.id]
  subnet_id = var.apci_jupiter_public_subnet_az_1a_id
  associate_public_ip_address = true
  key_name = var.key_name

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-Bastion-Host"
  })

}
# ----------------------------------------------------------------------------------------------------------------------------------------------------------
# Creating Private Server Security Group
resource "aws_security_group" "apci_jupiter_private_server_sg" {
  name        = "apci-jupiter-private-server-sg"
  description = "Allow SSH traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "private_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_access" {
  security_group_id = aws_security_group.apci_jupiter_private_server_sg.id
  referenced_security_group_id = aws_security_group.apci_jupiter_bastion_sg.id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_ssh_outbound_traffic" {
  security_group_id = aws_security_group.apci_jupiter_private_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


# Creating a Private Server in AZ - 1A
resource "aws_instance" "apci_jupiter_private_server_az1a" {
  ami           = var.image_id # us-west-2
  instance_type = var.instance_type
  security_groups = [aws_security_group.apci_jupiter_private_server_sg.id]
  subnet_id = var.apci_jupiter_private_subnet_az_1a_id
  associate_public_ip_address = false
  key_name = var.key_name

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-server-az1a"
  })
}

# Creating a Private Server in AZ - 1B
resource "aws_instance" "apci_jupiter_private_server_az1b" {
  ami           = var.image_id # us-west-2
  instance_type = var.instance_type
  security_groups = [aws_security_group.apci_jupiter_private_server_sg.id]
  subnet_id = var.apci_jupiter_private_subnet_az_1b_id
  associate_public_ip_address = false
  key_name = var.key_name

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-server-az1b"
  })
}