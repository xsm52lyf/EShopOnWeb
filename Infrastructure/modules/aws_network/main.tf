terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_region" "current" {}


resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "corecommerce-${var.environment}-vpc"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                              = "corecommerce-${var.environment}-public-${var.azs[count.index]}"
    Environment                       = var.environment
    "kubernetes.io/role/elb"          = "1"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name                              = "corecommerce-${var.environment}-private-${var.azs[count.index]}"
    Environment                       = var.environment
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "corecommerce-${var.environment}-igw"
    Environment = var.environment
  }
}

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? length(var.public_subnets) : 0
  domain = "vpc"

  tags = {
    Name        = "corecommerce-${var.environment}-nat-eip-${count.index + 1}"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "main" {
  count         = var.enable_nat_gateway ? length(var.public_subnets) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name        = "corecommerce-${var.environment}-nat-${var.azs[count.index]}"
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "corecommerce-${var.environment}-public-rt"
    Environment = var.environment
  }
}

resource "aws_route_table" "private" {
  count  = length(var.azs)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.enable_nat_gateway ? aws_nat_gateway.main[count.index].id : null
  }

  tags = {
    Name        = "corecommerce-${var.environment}-private-rt-${var.azs[count.index]}"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}