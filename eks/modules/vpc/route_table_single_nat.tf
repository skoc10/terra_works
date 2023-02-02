resource "aws_route_table" "public" {
  count  = length(var.public-subnet-map)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${lookup(var.public-subnet-map[count.index], "name")}-RT"
    Terraform = "true"
  }
}


resource "aws_route_table" "eks" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${lookup(var.eks-subnet-map[0], "name")}-RT"
    Terraform = "true"
  }
}


resource "aws_route_table_association" "public_route_association" {
  count          = length(var.public-subnet-map)
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = aws_route_table.public[count.index].id
}

resource "aws_route_table_association" "eks_route_association" {
  count          = length(var.eks-subnet-map)
  subnet_id      = element(aws_subnet.eks_subnets.*.id, count.index)
  route_table_id = aws_route_table.eks.id
}


##########################################################################################

# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat.id
#   }

#   tags = {
#     Name = "${lookup(var.private-subnet-map[0], "name")}-RT"
#     Terraform = "true"
#   }
# }


# resource "aws_route_table" "data" {
#   count  = length(var.data-subnet-map)
#   vpc_id = aws_vpc.main.id

#   tags = {
#     Name = "${lookup(var.data-subnet-map[count.index], "name")}-RT"
#     Terraform = "true"
#   }
# }

# resource "aws_route_table_association" "private_route_association" {
#   count          = length(var.private-subnet-map)
#   subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
#   route_table_id = aws_route_table.private.id
# }

# resource "aws_route_table_association" "data_route_association" {
#   count          = length(var.data-subnet-map)
#   subnet_id      = element(aws_subnet.data_subnets.*.id, count.index)
#   route_table_id = aws_route_table.data[count.index].id
# }