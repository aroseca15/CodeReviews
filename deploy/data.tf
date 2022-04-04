# Pulling in existing network data for reuse

data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_subnet" "private-1" {
  id = var.private1
}

data "aws_subnet" "private-2" {
  id = var.private2
}

data "aws_subnet" "public-1" {
  id = var.public1
}

data "aws_subnet" "public-2" {
  id = var.public2
}
