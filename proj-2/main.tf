provider "aws" {
  region = "us-east-1"
}

# 1. create vpc

resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}

# 2. create internet gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id
}

# 3. create custom route table

resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0" # default routing, all ip through this gateway.  #"10.0.1.0/24"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id # pointing to the same gateway, or aws_egress_only_internet_gateway.foo.id
  }

  tags = {
    Name = "prod"
  }
}


# 4. create a subnet

resource "aws_subnet" "subnet-1" {
  vpc_id = aws_vpc.prod-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "prod-subnet"
  }
}
# 5. associate subnet with route table

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-route-table.id
}


# 6. create security group to allow port 22,80, 443

resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # all ip can access
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # all ip can access
  }

  ingress {
    description = "HTTPS from V"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # all ip can access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # any protocol
    cidr_blocks = ["0.0.0.0/0"] # all ip 
  }

  tags = {
    Name = "allow_web"
  }
}

# 7. create a network interface with an ip in the subnet that was created in step 4

resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}

# 8. assign an elastic IP to the network interface created in step 7

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.gw] # !! this one need to have internet gateway first, must be a list
}

# 9. create ubuntu server and install/enable apache2 */

resource "aws_instance" "web-server-instance" {
  ami = "ami-084568db4383264d4"
  instance_type = "t3.micro" #"t2.micro"
  availability_zone = "us-east-1a" # same as subnet
  key_name = "main-key"

  network_interface {
    device_index = 0 # attach to the first network interface of this device, i.e., ethernet:0, ethernet:1, ethernet:2, etc
    network_interface_id = aws_network_interface.web-server-nic.id
  }

  user_data =  <<-EOF
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

# then we should see 'your very first web server' if we open http://ec2-ip-address/ in a browser.