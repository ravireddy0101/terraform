#create vpc
resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "project-vpc"
  }
}

#create-subnet
resource "aws_subnet" "sub" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-web-AZ1"
  }
}
resource "aws_subnet" "sub2" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-web-AZ2"
  }
}
resource "aws_subnet" "sub3" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "private-app-AZ1"
  }
}
resource "aws_subnet" "sub4" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "private-app-AZ2"
  }
}
resource "aws_subnet" "sub5" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "public-web-AZ1"
  }
}
resource "aws_subnet" "sub6" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.6.0/24"
  availability_zone = "us-east-1b"
   map_public_ip_on_launch = false
  tags = {
    Name = "public-web-AZ2"
  }
}

#create-internet-gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "project-igw"
  }
}

# Elastic IP allocation
resource "aws_eip" "eip-1" {
  domain   = "vpc"
  tags = {
    Name = "Elastic-ip-1"
  }
}
resource "aws_eip" "eip-2" {
  domain   = "vpc"
  tags = {
    Name = "Elastic-ip-2"
  }
}


#create NAT-gateway
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.eip-1.id
  subnet_id     = aws_subnet.sub.id
  connectivity_type = "public"
  tags = {
    Name = "NAT gw AZ1"
  }
}

resource "aws_nat_gateway" "nat-gw2" {
  allocation_id = aws_eip.eip-2.id
  subnet_id     = aws_subnet.sub2.id
  connectivity_type = "public"
  tags = {
    Name = "NAT gw AZ2"
  }
}

#Creating Route-table for public-web
resource "aws_route_table" "Route-table" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Public-web-rt"
  }
}

#subnet-association
resource "aws_route_table_association" "rt-1" {
  subnet_id      = aws_subnet.sub.id
  route_table_id = aws_route_table.Route-table.id
}
resource "aws_route_table_association" "rt-2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.Route-table.id
}

#Creating Route-table for private-app
resource "aws_route_table" "Route-table-2" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }
  tags = {
    Name = "Private-app-rt"
  }
}
#subnet-association-app-rt
resource "aws_route_table_association" "rt-3" {
  subnet_id      = aws_subnet.sub3.id
  route_table_id = aws_route_table.Route-table-2.id
}
resource "aws_route_table_association" "rt-4" {
  subnet_id      = aws_subnet.sub4.id
  route_table_id = aws_route_table.Route-table-2.id
}

#Creating Route-table for private-web
resource "aws_route_table" "Route-table-3" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw2.id
  }
  tags = {
    Name = "Private-db-rt"
  }
}
#subnet-association-db-rt
resource "aws_route_table_association" "rt-5" {
  subnet_id      = aws_subnet.sub5.id
  route_table_id = aws_route_table.Route-table-3.id
}
resource "aws_route_table_association" "rt-6" {
  subnet_id      = aws_subnet.sub6.id
  route_table_id = aws_route_table.Route-table-3.id
}

#create security group for web
resource "aws_security_group" "web-sg" {
  vpc_id      = aws_vpc.myvpc.id
    ingress {
    description = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
}
ingress {
    description = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
}
egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-sg"
  }
}

#create security group for app
resource "aws_security_group" "app-sg" {
  vpc_id      = aws_vpc.myvpc.id
    ingress {
    description = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
}
ingress {
    description = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
}
egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "App-SG"
  }
}

#create security group for db
resource "aws_security_group" "db-sg" {
  vpc_id      = aws_vpc.myvpc.id
    ingress {
    description = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
}
ingress {
    description = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
}
egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "DB-SG"
  }
}

#create instance
resource "aws_instance" "app-1" {
  ami           = "ami-0cf10cdf9fcd62d37"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.sub3.id
  availability_zone = "us-east-1a"
  key_name = "Devops"
  vpc_security_group_ids = [aws_security_group.app-sg.id]
  associate_public_ip_address = false
  tags = {
    Name = "app-instance-AZ1"
  }
}

resource "aws_instance" "app-2" {
  ami           = "ami-0cf10cdf9fcd62d37"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.sub4.id
  availability_zone = "us-east-1b"
  key_name = "Devops"
  vpc_security_group_ids = [aws_security_group.app-sg.id]
  associate_public_ip_address = false
  tags = {
    Name = "app-instance-AZ2"
  }
}