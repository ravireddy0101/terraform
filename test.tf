# Define provider
provider "aws" {
  access_key = "AKIATCKARKEEIEAEJ4JU"
  secret_key = "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"
  region = "us-east-1"
}

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.100.0.0/16"
}

# Create internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.100.1.0/24"
  availability_zone = "us-east-1a" # Specify availability zone
  map_public_ip_on_launch = true
}

# Create route table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

# Associate route table with subnet
resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

# Create security group
resource "aws_security_group" "my_security_group" {
  vpc_id = aws_vpc.my_vpc.id

  # Allow SSH (port 22) and all traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch EC2 instance
resource "aws_instance" "my_instance" {
  ami             = "ami-0cf10cdf9fcd62d37"
  instance_type   = "t2.micro"
  count           = 1
  user_data       = file("httpd.sh")
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.my_security_group.id]
  # Add key name if using SSH key pair
  key_name = "nvkey"
}