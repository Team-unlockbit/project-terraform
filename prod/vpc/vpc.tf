provider "aws" {
	region = var.region
  default_tags {
    tags = {
      Name    = "VPC-93-dev"
      Subject = "cloud-programming"
      Chapter = "practice5"
    }
  }
}

resource "aws_vpc" "my_vpc" {
  cidr_block            = var.vpc_cidr
  instance_tenancy      = "default"
  enable_dns_hostnames  = true
  tags                  = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "pub_sub_a" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, 0)
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags                    = {
    Name = var.subnet_name[0]
  }
}

resource "aws_subnet" "pub_sub_c" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, 1)
  availability_zone       = "${var.region}c"
  map_public_ip_on_launch = true
  tags                    = {
    Name = var.subnet_name[1]
  }
}

resource "aws_subnet" "prv_sub_a" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 3, 2)
  availability_zone = "${var.region}a"
  tags              = {
    Name = var.subnet_name[2]
  }
}

resource "aws_subnet" "prv_sub_c" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 3, 3)
  availability_zone = "${var.region}c"
  tags              = {
    Name = var.subnet_name[3]
  }
}

resource "aws_subnet" "prv_sub_nat_a" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 3, 4)
  availability_zone = "${var.region}a"
  tags = {
    Name = var.subnet_name[4]
  }
}

resource "aws_subnet" "prv_sub_nat_c" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 3, 5)
  availability_zone = "${var.region}c"
  tags = {
    Name = var.subnet_name[5]
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags   = {
    Name = var.igw_name
  }
}

resource "aws_nat_gateway" "nat_gw_a" {
  allocation_id = aws_eip.nat_eip1.id
  subnet_id     = aws_subnet.pub_sub_a.id
  depends_on    = [aws_internet_gateway.my_igw]
  tags          = {
    Name = var.nat_name[0]
  }
}

resource "aws_nat_gateway" "nat_gw_c" {
  allocation_id = aws_eip.nat_eip2.id
  subnet_id     = aws_subnet.pub_sub_c.id
  depends_on    = [aws_internet_gateway.my_igw]
  tags          = {
    Name = var.nat_name[1]
  }
}

resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "rtb-93-pub"
  }
}

resource "aws_route_table" "prv_rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }
  tags = {
    Name = "rtb-93-prv"
  }
}

resource "aws_route_table" "prv_rt_nat_a" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw_a.id
  }
  tags = {
    Name = "rtb-93-prv-nat-a"
  }
}

resource "aws_route_table" "prv_rt_nat_c" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw_c.id
  }
  tags = {
    Name = "rtb-93-prv-nat-c"
  }
}

resource "aws_route_table_association" "pub_rt_asso" {
  subnet_id      = aws_subnet.pub_sub_a.id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "pub_rt_asso2" {
  subnet_id      = aws_subnet.pub_sub_c.id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "prv_rt_asso" {
  subnet_id      = aws_subnet.prv_sub_a.id
  route_table_id = aws_route_table.prv_rt.id
}

resource "aws_route_table_association" "prv_rt_asso2" {
  subnet_id      = aws_subnet.prv_sub_c.id
  route_table_id = aws_route_table.prv_rt.id
}

resource "aws_route_table_association" "prv_rt_nat_asso" {
  subnet_id      = aws_subnet.prv_sub_nat_a.id
  route_table_id = aws_route_table.prv_rt_nat_a.id
}

resource "aws_route_table_association" "prv_rt_nat_asso2" {
  subnet_id      = aws_subnet.prv_sub_nat_c.id
  route_table_id = aws_route_table.prv_rt_nat_c.id
}

resource "aws_eip" "nat_eip1" {
  domain	= "vpc"
}
resource "aws_eip" "nat_eip2" {
  domain	= "vpc"
}
