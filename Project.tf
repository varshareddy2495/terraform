provider "aws" {
    region = "eu-west-1"
    access_key = "0000000000000000"
    secret_key = "00000000000"
}

resource "aws_vpc" "prod-vpc" {
    cidr_block = "10.0.0.0/16"

tags = {
    Name = "prduction"
}
  }

resource  "aws_internet_gateway" "my-ingw"{
    vpc_id = aws_vpc.prod-vpc.id

    tags = {
        Name = "my-ingw"
    }
}

resource "aws_subnet" "prod-subnet" {
    vpc_id = aws_vpc.prod-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "eu-west-1a"

    tags = {
        Name = "prod-subnet"
    }
}

resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-ingw.id
    
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id             = aws_internet_gateway.my-ingw.id
  }

  tags = {
    Name = "prod"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.prod-subnet.id 
  route_table_id = aws_route_table.prod-route-table.id
}


 resource "aws_security_group" "allow_web" {
   name        = "allow_web_traffic"
   description = "Allow Web inbound traffic"
   vpc_id      = aws_vpc.prod-vpc.id

   ingress {
     description = "HTTPS"
     from_port   = 443
     to_port     = 443
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
   ingress {
     description = "HTTP"
     from_port   = 80
     to_port     = 80
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
   ingress {
     description = "SSH"
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

   tags = {
     Name = "allow_web"
   }
 }
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.prod-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.my-ingw]
}

 resource "aws_instance" "web-server-instance" {
   ami               = "ami-07ee42ba0209b6d77"
   instance_type     = "t2.micro"
   availability_zone = "eu-west-1a"
   key_name          = "Ireland_home"

   network_interface {
     device_index         = 0
     network_interface_id = aws_network_interface.web-server-nic.id
   }

    user_data = <<-EOF
               #!/bin/bash
                 sudo apt update -y
                 sudo apt install apache2 -y
                 sudo systemctl start apache2
                 sudo bash -c 'echo your very first web server > /var/www/html/index.html'
                 EOF
   tags = {
     Name = "web-server"
   }
 }
