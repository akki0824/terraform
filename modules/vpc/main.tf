resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# create internet gateway and attach it to above vpc
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

# use data source to get avalablility zones in the region
data "aws_availability_zones" "availability_zones" {}

# create public subnet
resource "aws_subnet" "pub_subnet_az1" {
  vpc_id                    = aws_vpc.vpc.id
  cidr_block                = var.pub_subnet_az1_cidr
  map_public_ip_on_launch   = true
  availability_zone         = data.aws_availability_zones.availability_zones.names[0]
  tags = {
    "Name"                        = var.pub_subnet_tag_az1
    "kubernetes.io/cluster/${var.project_name}" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}

# create public subnet pub-sub2

resource "aws_subnet" "pub_subnet_az2" {
  vpc_id                    = aws_vpc.vpc.id
  cidr_block                = var.pub_subnet_az2_cidr
  map_public_ip_on_launch   = true
  availability_zone         = data.aws_availability_zones.availability_zones.names[1]
  tags = {
    "Name"                        = var.pub_subnet_tag_az2
    "kubernetes.io/cluster/${var.project_name}" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}

# create public route table

resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "Name" = "${var.project_name}-pub_rt"
  }
}

# associate public subnet pub-sub1 to "public route table"

resource "aws_route_table_association" "pub_rt_association_az1" {
  subnet_id      = aws_subnet.pub_subnet_az1.id
  route_table_id = aws_route_table.pub_rt.id
}

# associate public subnet pub-sub2 to "public route table"

resource "aws_route_table_association" "pub_rt_association_az2" {
  subnet_id      = aws_subnet.pub_subnet_az2.id
  route_table_id = aws_route_table.pub_rt.id
}

# create public subnet pri-sub3

resource "aws_subnet" "private_subnet_az1" {
  vpc_id             = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_az1_cidr
    availability_zone = data.aws_availability_zones.availability_zones.names[0]
  map_public_ip_on_launch = false
  
  tags = {
    "Name"                        = var.private_subnet_tag_az1
    "kubernetes.io/cluster/${var.project_name}" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

# create public subnet pri-sub4

resource "aws_subnet" "private_subnet_az2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_az2_cidr
  availability_zone = data.aws_availability_zones.availability_zones.names[1]
  map_public_ip_on_launch = false

  tags = {
    "Name"                        = var.private_subnet_tag_az2
    "kubernetes.io/cluster/${var.project_name}" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}