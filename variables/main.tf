# 1. create vpc
# 2. create security group 

# create VPC
resource "aws_vpc" "main" {
  cidr_block       = var.CIDR
  instance_tenancy = var.instance_tenancy
  enable_dns_support = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = var.tags
}

# create Security Group for postgres RDS, 5432
resource "aws_security_group" "allow_postgress" {
  name        = "allow_postgress"
  description = "Allow postgress inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = var.postgress_port
    to_port          = var.postgress_port
    protocol         = "tcp"
    cidr_blocks      = var.cidr_list
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge (
    var.tags, {
      Name = "timing_RDS_SG"
    }
  )
}

# EC2 instance creation with count and count index
resource "aws_instance" "web_server" {
  count = 3
  ami           = "ami-00b8917ae86a424c9"
  instance_type = "t2.micro"
  tags = {
    Name = var.instance_name[count.index]
  }
}

# EC2 instance with condition if prod t3.large and if not prd t2.micro
resource "aws_instance" "condition" {
  ami = "ami-00b8917ae86a424c9"
  instance_type = var.isProd ? "t3.medium" : "t2.micro"
}

resource "aws_key_pair" "terraform" {
  key_name = "terraform"
  public_key = file("/Users/sri/.ssh/id_rsa.pub")
  ##public_key = file("\\Users\\sri\\.ssh\\id_rsa.pub")
}


resource "aws_instance" "PROD" {
  key_name = aws_key_pair.terraform.key_name
  ami = "ami-00b8917ae86a424c9"
  instance_type = var.env == "prod" ? "t3.medium" : "t2.micro"
}