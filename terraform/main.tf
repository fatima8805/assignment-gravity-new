resource "aws_vpc" "terraform-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "terraform-vpc"
  }
}

resource "aws_subnet" "public-subnet" {
    vpc_id = aws_vpc.terraform-vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = var.availability_zone
    map_public_ip_on_launch = true
    tags = {
      Name = "public-subnet"
    }
}

resource "aws_subnet" "private-subnet" {
    vpc_id = aws_vpc.terraform-vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = var.availability_zone
    tags = {
      Name = "private-subnet"
    }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.terraform-vpc.id
  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.terraform-vpc.id
  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public-subnet-association" {
  subnet_id = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_security_group" "terraform-sg" {
  vpc_id = aws_vpc.terraform-vpc.id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  tags = {
    Name = "terraform-sg"
  }
}

resource "aws_instance" "terraform-instance" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  subnet_id = aws_subnet.public-subnet.id
  security_groups = [aws_security_group.terraform-sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y nginx
              systemctl start nginx
              systemctl enable nginx
              EOF
  tags = {
    Name = "terraform-instance"
  }
}