provider "aws" {
  region     = "us-east-1"
  #access_key = "xxxxxxxxxxxxxxxxxxxxxxxxx"
  #secret_key = "xxxxxxxxxxxxxxxxxxxxxxxxx"
}

resource "aws_vpc" "app-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
    Name = "app-vpc"
  }  
}

resource "aws_subnet" "app-pub-1a" {
    vpc_id = aws_vpc.app-vpc.id
    cidr_block = "10.0.10.0/24"
    availability_zone = "us-east-1a"
    tags = {
    Name = "app-pub-1a"
  } 
}
resource "aws_subnet" "app-pub-1b" {
    vpc_id = aws_vpc.app-vpc.id
    cidr_block = "10.0.20.0/24"
    availability_zone = "us-east-1b"
    tags = {
    Name = "app-pub-1b"
  }
}
resource "aws_subnet" "app-pri-1a" {
    vpc_id = aws_vpc.app-vpc.id
    cidr_block = "10.0.11.0/24"
    availability_zone = "us-east-1a"
    tags = {
    Name = "app-pri-1a"
  }
}
resource "aws_subnet" "app-pri-1b" {
    vpc_id = aws_vpc.app-vpc.id
    cidr_block = "10.0.21.0/24"
    availability_zone = "us-east-1b"
    tags = {
    Name = "app-pri-1b"
  }
}

resource "aws_internet_gateway" "app-igv" {
    vpc_id = aws_vpc.app-vpc.id
    tags = {
    Name = "app-igv"
  }
}

resource "aws_route_table" "app-pub-rt" {
  vpc_id = aws_vpc.app-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app-igv.id
  }

  

  tags = {
    Name = "app-pub-rt"
  }
}

resource "aws_route_table_association" "a-pub" {
  subnet_id      = aws_subnet.app-pub-1a.id
  route_table_id = aws_route_table.app-pub-rt.id
}
resource "aws_route_table_association" "b-pub" {
  subnet_id      = aws_subnet.app-pub-1b.id
  route_table_id = aws_route_table.app-pub-rt.id
}