resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    tags = { Name = "flask-vpc" }
}

resource "aws_subnet" "public_1" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "${var.region}a"
    tags = { Nmae = "flask-public-subnet" }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  tags = { Name = "flask-public-subnet-2" }
}

resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.main.id
    tags= { Name = "flask-igw" }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }
    tags = { Name = "flask-route-table" }
}

resource "aws_route_table_association" public {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
}