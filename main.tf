terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  alias  = "mumbai"
  region = "ap-south-1"
}

provider "aws" {
  alias  = "singapore"
  region = "ap-southeast-1"
}

#########################
# MUMBAI REGION
#########################
resource "aws_vpc" "vpc_mumbai" {
  provider   = aws.mumbai
  cidr_block = "10.10.0.0/16"
}

resource "aws_internet_gateway" "igw_mumbai" {
  provider = aws.mumbai
  vpc_id   = aws_vpc.vpc_mumbai.id
}

resource "aws_subnet" "subnet_mumbai" {
  provider                = aws.mumbai
  vpc_id                  = aws_vpc.vpc_mumbai.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "rt_mumbai" {
  provider = aws.mumbai
  vpc_id   = aws_vpc.vpc_mumbai.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_mumbai.id
  }
}

resource "aws_route_table_association" "rta_mumbai" {
  provider       = aws.mumbai
  subnet_id      = aws_subnet.subnet_mumbai.id
  route_table_id = aws_route_table.rt_mumbai.id
}

resource "aws_security_group" "sg_mumbai" {
  provider    = aws.mumbai
  vpc_id      = aws_vpc.vpc_mumbai.id
  name        = "allow-ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "amazon_linux_mumbai" {
  provider    = aws.mumbai
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_key_pair" "kp_mumbai" {
  provider   = aws.mumbai
  key_name   = "kp-mumbai"
  public_key = file(var.public_key_path)
}

resource "aws_instance" "ec2_mumbai" {
  provider               = aws.mumbai
  ami                    = data.aws_ami.amazon_linux_mumbai.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnet_mumbai.id
  vpc_security_group_ids = [aws_security_group.sg_mumbai.id]
  key_name               = aws_key_pair.kp_mumbai.key_name

  tags = {
    Name = "ec2-mumbai"
  }
}

#########################
# SINGAPORE REGION
#########################
resource "aws_vpc" "vpc_singapore" {
  provider   = aws.singapore
  cidr_block = "10.20.0.0/16"
}

resource "aws_internet_gateway" "igw_singapore" {
  provider = aws.singapore
  vpc_id   = aws_vpc.vpc_singapore.id
}

resource "aws_subnet" "subnet_singapore" {
  provider                = aws.singapore
  vpc_id                  = aws_vpc.vpc_singapore.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "rt_singapore" {
  provider = aws.singapore
  vpc_id   = aws_vpc.vpc_singapore.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_singapore.id
  }
}

resource "aws_route_table_association" "rta_singapore" {
  provider       = aws.singapore
  subnet_id      = aws_subnet.subnet_singapore.id
  route_table_id = aws_route_table.rt_singapore.id
}

resource "aws_security_group" "sg_singapore" {
  provider    = aws.singapore
  vpc_id      = aws_vpc.vpc_singapore.id
  name        = "allow-ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "amazon_linux_singapore" {
  provider    = aws.singapore
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_key_pair" "kp_singapore" {
  provider   = aws.singapore
  key_name   = "kp-singapore"
  public_key = file(var.public_key_path)
}

resource "aws_instance" "ec2_singapore" {
  provider               = aws.singapore
  ami                    = data.aws_ami.amazon_linux_singapore.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnet_singapore.id
  vpc_security_group_ids = [aws_security_group.sg_singapore.id]
  key_name               = aws_key_pair.kp_singapore.key_name

  tags = {
    Name = "ec2-singapore"
  }
}
