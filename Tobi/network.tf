##############################################################################################################
# Reusing Our Current VPC - Using secondary CIDR block for private subnets since public was already created #
##############################################################################################################

data "aws_vpc" "main" {
  id = var.vpc_id
}



data "aws_subnet" "private-1" {
  id = var.private1
}


data "aws_subnet" "private-2" {
  id = var.private2
}

#####################################################
# Public Subnets - Inbound/Outbound Internet Access #
#####################################################

data "aws_subnet" "public-1" {
  id = var.public1
}

data "aws_route_table" "public-1" {
  subnet_id = data.aws_subnet.public-1.id
}


resource "aws_route_table_association" "public-1" {
  subnet_id      = data.aws_subnet.public-1.id
  route_table_id = data.aws_route_table.public-1.id
}

resource "aws_route" "public_internet_access_1" {
  route_table_id         = data.aws_route_table.public-1.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_id = data.aws_vpc.main.id
}

resource "aws_eip" "public-1" {
  vpc = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-1" })
  )
}

data "aws_nat_gateway" "public-1" {
  allocation_id = aws_eip.public-1.id
  subnet_id     = data.aws_subnet.public-1.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-1" })
  )
}




data "aws_subnet" "public-2" {
  id = var.public2
}

data "aws_route_table" "public-2" {
  vpc_id = data.aws_vpc.main.id


  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-2" })
  )
}

resource "aws_route_table_association" "public-2" {
  subnet_id      = data.aws_subnet.public-2.id
  route_table_id = data.aws_route_table.public-2.id
}

resource "aws_route" "public_internet_access_2" {
  route_table_id         = data.aws_route_table.public-2.id
  destination_cidr_block = "0.0.0.0/0"
  # gateway_id             = aws_internet_gateway.main.id
}

resource "aws_eip" "public-2" {
  vpc = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-2" })
  )
}

data "aws_nat_gateway" "public-2" {
  allocation_id = aws_eip.public-2.id
  subnet_id     = data.aws_subnet.public-2.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-2" })
  )
}

##################################################
# Private Subnets - Outbound internt access only #
##################################################

data "aws_route_table" "private-1" {
  vpc_id = data.aws_vpc.main.id


  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private-1" })
  )
}

resource "aws_route_table_association" "private-1" {
  subnet_id      = data.aws_subnet.private-1.id
  route_table_id = data.aws_route_table.private-1.id
}

resource "aws_route" "private_1_internet_out" {
  route_table_id         = data.aws_route_table.private-1.id
  nat_gateway_id         = data.aws_nat_gateway.public-1.id
  destination_cidr_block = "0.0.0.0/0"
}


data "aws_route_table" "private-2" {
  vpc_id = data.aws_vpc.main.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private-2" })
  )
}

resource "aws_route_table_association" "private-2" {
  subnet_id      = data.aws_subnet.private-2.id
  route_table_id = data.aws_route_table.private-2.id
}

resource "aws_route" "private_2_internet_out" {
  route_table_id         = data.aws_route_table.private-2.id
  nat_gateway_id         = data.aws_nat_gateway.public-2.id
  destination_cidr_block = "0.0.0.0/0"
}
