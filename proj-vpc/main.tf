provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "first-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.first-vpc.id # this way to get the host vpc id. THE SUBNET can define before the main VPC. THE order does not matter.
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "prod-subnet"
  }
}