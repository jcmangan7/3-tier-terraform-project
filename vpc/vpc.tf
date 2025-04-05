resource "aws_vpc" "apci_jupiter_main_vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

   tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-vpc"
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.apci_jupiter_main_vpc.id

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-igw"
  })
}

resource "aws_subnet" "apci_jupiter_public_subnet_az_1a" {
  vpc_id     = aws_vpc.apci_jupiter_main_vpc.id
  cidr_block = var.public_subnet_cidr_block[0]
  availability_zone = var.availability_zone[0]

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-subnet-az-1a"
  })
}

resource "aws_subnet" "apci_jupiter_public_subnet_az_1b" {
  vpc_id     = aws_vpc.apci_jupiter_main_vpc.id
  cidr_block = var.public_subnet_cidr_block[1]
  availability_zone = var.availability_zone[1]

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-subnet-az-1b"
  })
}

# Creating Private Subnets

resource "aws_subnet" "apci_jupiter_private_subnet_az_1a" {
  vpc_id     = aws_vpc.apci_jupiter_main_vpc.id
  cidr_block = var.private_subnet_cidr_block[0]
  availability_zone = var.availability_zone[0]

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-subnet-az-1a"
  })
}

resource "aws_subnet" "apci_jupiter_private_subnet_az_1b" {
  vpc_id     = aws_vpc.apci_jupiter_main_vpc.id
  cidr_block = var.private_subnet_cidr_block[1]
  availability_zone = var.availability_zone[1]

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-subnet-az-1b"
  })
}

resource "aws_subnet" "apci_jupiter_db_subnet_az_1a" {
  vpc_id     = aws_vpc.apci_jupiter_main_vpc.id
  cidr_block = var.private_subnet_cidr_block[2]
  availability_zone = var.availability_zone[0]

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-subnet-az-1a"
  })
}

resource "aws_subnet" "apci_jupiter_db_subnet_az_1b" {
  vpc_id     = aws_vpc.apci_jupiter_main_vpc.id
  cidr_block = var.private_subnet_cidr_block[3]
  availability_zone = var.availability_zone[1]

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-subnet-az-1b"
  })
}

# creating a public route table
resource "aws_route_table" "apci_jupiter_public_rt" {
  vpc_id = aws_vpc.apci_jupiter_main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-rt"
  })
}

# creating a public route table association
resource "aws_route_table_association" "apci_jupiter_public_rt_association_az_1a" {
  subnet_id      = aws_subnet.apci_jupiter_public_subnet_az_1a.id
  route_table_id = aws_route_table.apci_jupiter_public_rt.id
}

resource "aws_route_table_association" "apci_jupiter_public_rt_association_az_1b" {
  subnet_id      = aws_subnet.apci_jupiter_public_subnet_az_1b.id
  route_table_id = aws_route_table.apci_jupiter_public_rt.id
}

 # Creating an Elastic IP for NAT Gateway in AZ 1a
 resource "aws_eip" "apci_jupiter_eip_az_1a" {
  domain   = "vpc"

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip-az-1a"
  })  
}

# Creating a NAT Gateway for AZ 1a
resource "aws_nat_gateway" "apci_jupiter_nat_gw_az_1a" {
  allocation_id = aws_eip.apci_jupiter_eip_az_1a.id
  subnet_id     = aws_subnet.apci_jupiter_public_subnet_az_1a.id

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat-gw-az-1a"
  })
  
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.apci_jupiter_eip_az_1a, aws_subnet.apci_jupiter_public_subnet_az_1a]
}

# creating a private route table for AZ 1a
resource "aws_route_table" "apci_jupiter_private_rt" {
  vpc_id = aws_vpc.apci_jupiter_main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.apci_jupiter_nat_gw_az_1a.id
  }

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-rt"
  })
}

# creating a private route table association
resource "aws_route_table_association" "apci_jupiter_private_rt_association_az_1a" {
  subnet_id      = aws_subnet.apci_jupiter_private_subnet_az_1a.id
  route_table_id = aws_route_table.apci_jupiter_private_rt.id
}

# creating a private route table association
resource "aws_route_table_association" "apci_jupiter_db_rt_association_az_1a" {
  subnet_id      = aws_subnet.apci_jupiter_db_subnet_az_1a.id
  route_table_id = aws_route_table.apci_jupiter_private_rt.id
}

# Creating an Elastic IP for NAT Gateway in AZ 1b
 resource "aws_eip" "apci_jupiter_eip_az_1b" {
  domain   = "vpc"

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip-az-1b"
  })  
}

# Creating a NAT Gateway for AZ 1b
resource "aws_nat_gateway" "apci_jupiter_nat_gw_az_1b" {
  allocation_id = aws_eip.apci_jupiter_eip_az_1b.id
  subnet_id     = aws_subnet.apci_jupiter_public_subnet_az_1b.id

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat-gw-az-1b"
  })
  
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.apci_jupiter_eip_az_1b, aws_subnet.apci_jupiter_public_subnet_az_1b]
}

# creating a private route table for AZ 1b
resource "aws_route_table" "apci_jupiter_private_rt_az_1b" {
  vpc_id = aws_vpc.apci_jupiter_main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.apci_jupiter_nat_gw_az_1b.id
  }

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-rt=az-1b"
  })
}

# creating a private route table association for AZ 1b
resource "aws_route_table_association" "apci_jupiter_private_rt_association_az_1b" {
  subnet_id      = aws_subnet.apci_jupiter_private_subnet_az_1b.id
  route_table_id = aws_route_table.apci_jupiter_private_rt_az_1b.id
}

resource "aws_route_table_association" "apci_jupiter_db_rt_association_az_1b" {
  subnet_id      = aws_subnet.apci_jupiter_db_subnet_az_1b.id
  route_table_id = aws_route_table.apci_jupiter_private_rt_az_1b.id
}