###########################################################################
# VPC
###########################################################################
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.vpc_name}-${var.environment}-vpc"
  }
}

###########################################################################
# Subnet
###########################################################################

# Public Subnet
resource "aws_subnet" "public" {
  for_each = { for i in var.public_subnets : i.az => i }

  availability_zone       = each.value["az"]
  cidr_block              = each.value["cidr"]
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-${var.environment}-${each.value["name"]}${replace(each.value["az"], "ap-northeast", "")}"
  }
}
# Application Subnet
resource "aws_subnet" "private_app" {
  for_each = { for i in var.application_subnets : i.az => i }

  availability_zone       = each.value["az"]
  cidr_block              = each.value["cidr"]
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.vpc_name}-${var.environment}-${each.value["name"]}${replace(each.value["az"], "ap-northeast", "")}"
  }
}
# Database Subnet
resource "aws_subnet" "private_db" {
  for_each = { for i in var.database_subnets : i.az => i }

  availability_zone       = each.value["az"]
  cidr_block              = each.value["cidr"]
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.vpc_name}-${var.environment}-${each.value["name"]}${replace(each.value["az"], "ap-northeast", "")}"
  }
}

###########################################################################
# Internet Gateway
###########################################################################
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-${var.environment}-igw"
  }
}

###########################################################################
# NAT Gateway
###########################################################################
resource "aws_eip" "nat_gateway" {
  for_each = { for i in var.public_subnets : i.az => i }

  vpc        = true
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${var.vpc_name}-${var.environment}-nat-gateway-eip"
  }
}
resource "aws_nat_gateway" "main" {
  for_each = { for i in var.public_subnets : i.az => i }

  allocation_id = aws_eip.nat_gateway["${each.value["az"]}"].id
  subnet_id     = aws_subnet.public["${each.value["az"]}"].id
  depends_on    = [aws_internet_gateway.main]

  tags = {
    Name = "${var.vpc_name}-${var.environment}-nat-gateway"
  }
}

###########################################################################
# Route Table
###########################################################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.vpc_name}-public"
  }
}
resource "aws_route_table_association" "public" {
  for_each = { for i in var.public_subnets : i.az => i }

  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public["${each.value["az"]}"].id
}
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table" "private" {
  for_each = { for i in var.application_subnets : i.az => i }
  vpc_id   = aws_vpc.main.id
  tags = {
    Name = "${var.vpc_name}-private-${each.value["az"]}"
  }
}
resource "aws_route_table_association" "private" {
  for_each = { for i in var.application_subnets : i.az => i }

  route_table_id = aws_route_table.private["${each.value["az"]}"].id
  subnet_id      = aws_subnet.private_app["${each.value["az"]}"].id
}
resource "aws_route" "private" {
  for_each = { for i in var.application_subnets : i.az => i }

  route_table_id         = aws_route_table.private["${each.value["az"]}"].id
  nat_gateway_id         = aws_nat_gateway.main["${each.value["az"]}"].id
  destination_cidr_block = "0.0.0.0/0"
}
