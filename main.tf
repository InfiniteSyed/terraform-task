provider "aws" {
  region = "us-east-2"
  access_key = "AKIAS74TMB72BKJPSIF3"
  secret_key = "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"

}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

tags = {
 Name = "Main-vpc-4"
}

}

resource "aws_subnet" "my_subnet"{ 
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.main_vpc.id
  map_public_ip_on_launch = true
  availability_zone = "us-east-2a"

tags = {
  Name = "subnet-4"
 }

}

resource "aws_internet_gateway" "main_igw" { 
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route_table" "public_rt" { 
  vpc_id = aws_vpc.main_vpc.id
 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
   }

  tags = {
    Name = "public-rt"
  }

}

resource "aws_route_table_association" "public_rt_link" {
  subnet_id = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.public_rt.id
} 


resource "aws_security_group" "main_sg" {
  name = "main-sg"
  description = "Defines the security group for the instance"
  vpc_id = aws_vpc.main_vpc.id

ingress {
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

ingress {
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
}

resource "aws_instance" "webserver-1" {
  ami = "ami-0b05d988257befbbe"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.main_sg.id]
  user_data = <<-EOF
              #!/bin/bash
              sudo su
              apt update -y
              apt-get install apache2 -y
              EOF

 
tags = {
  Name = "ec2-vpc-UserData"
}

}

output "instance_ip" { 
  value = aws_instance.webserver-1.public_ip
}

resource "local_file" "instance_ip_file" { 
  content = aws_instance.webserver-1.public_ip
  filename = "${path.module}/instance_ip.txt"
}
