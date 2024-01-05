# NETWORK SETUP
# 1. Create VPC
# 2. Create internet gateway 
# 3. Attach internet gateway to VPC 
# 4. Create public subnet 
# 5. create public route table 
# 6. create private subent 
# 7. create private route table 
# 8. create data base subnet 
# 9. create database route table 
# 10. associations
# 11. NAT gateway 
# 12. attach NAT gateway

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = var.project_name
    Terraform = "true"
    Environment = "DEV"
  }
}

# create internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "timing"
    Terraform = "true"
    Environment = "DEV"
  }
}

# create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "${var.project_name}_public_subnet"
    Terraform = "true"
    Environment = "DEV"
  }
}

# create public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}_public_rt"
    Terraform = "true"
    Environment = "DEV"
  }
}

# associate public route table with public subnet 
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}


# Create private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.11.0/24"

  tags = {
    Name = "${var.project_name}-private_subnet"
    Terraform = "true"
    Environment = "DEV"
  }
}

# create private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id


  tags = {
    Name = "${var.project_name}_private_rt"
    Terraform = "true"
    Environment = "DEV"
  }
}

# associate private route table with private subnet 
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

# create database subnet
resource "aws_subnet" "database_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.21.0/24"

  tags = {
    Name = "${var.project_name}_database_subnet"
    Terraform = "true"
    Environment = "DEV"
  }
}

# create database route table
resource "aws_route_table" "database_route_table" {
  vpc_id = aws_vpc.main.id


  tags = {
    Name = "${var.project_name}_database_rt"
    Terraform = "true"
    Environment = "DEV"
  }
}

# associate database route table with database subnet 
resource "aws_route_table_association" "database" {
  subnet_id      = aws_subnet.database_subnet.id
  route_table_id = aws_route_table.database_route_table.id
}

# create Elastic IP
resource "aws_eip" "nat" {
  domain   = "vpc"
}

# Create Nateway 
resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  #depends_on = [aws_internet_gateway.main]
}

# associating private route table to Nat gateway 
resource "aws_route" "private" {
  route_table_id            = aws_route_table.private_route_table.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.gw.id
  #depends_on                = [aws_route_table.private]
}

# associating database route table to Nat gateway 
resource "aws_route" "database" {
  route_table_id            = aws_route_table.database_route_table.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id           = aws_nat_gateway.gw.id
  #depends_on                = [aws_route_table.database_route_table]
}