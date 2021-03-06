##############################################################################################################
# Reusing Our Current VPC - Using secondary CIDR block for private subnets since public was already created #
##############################################################################################################

# locals {
#   prefix  = var.prefix
#   common_tags = {
#     Project = var.project
#   }
# }

#####################################################
# Public Subnets - Inbound/Outbound Internet Access #
#####################################################

#########################
# Public Subnet-1 asign #
#########################
resource "aws_eip" "public-1" {
  vpc = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-1" })
  )
}

resource "aws_nat_gateway" "public-1" {
  allocation_id = aws_eip.public-1.id
  subnet_id     = data.aws_subnet.public-1.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-1" })
  )
}

#########################
# Public Subnet-2 asign #
#########################
resource "aws_eip" "public-2" {
  vpc = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-2" })
  )
}

resource "aws_nat_gateway" "public-2" {
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

#########################
# Private Subnet-1 asign #
#########################

resource "aws_route_table" "private-1" {
  vpc_id = data.aws_vpc.main.id


  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private-1" })
  )
}

resource "aws_route_table_association" "private-1" {
  subnet_id      = data.aws_subnet.private-1.id
  route_table_id = aws_route_table.private-1.id
}

resource "aws_route" "private_1_internet_out" {
  route_table_id         = aws_route_table.private-1.id
  nat_gateway_id         = aws_nat_gateway.public-1.id
  destination_cidr_block = "0.0.0.0/0"
}


#########################
# Purivate Subnet-2 asign #
#########################

resource "aws_route_table" "private-2" {
  vpc_id = data.aws_vpc.main.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private-2" })
  )
}

resource "aws_route_table_association" "private-2" {
  subnet_id      = data.aws_subnet.private-2.id
  route_table_id = aws_route_table.private-2.id
}

resource "aws_route" "private_2_internet_out" {
  route_table_id         = aws_route_table.private-2.id
  nat_gateway_id         = aws_nat_gateway.public-2.id
  destination_cidr_block = "0.0.0.0/0"
}
