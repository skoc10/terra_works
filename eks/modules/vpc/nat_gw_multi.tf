# resource "aws_eip" "eip" {
#   count    = length(var.eks-subnet-map)
#   vpc      = true

#   tags = {
#     Name = "${var.project}-NATGW-${lookup(var.eks-subnet-map[count.index], "az")}-eip"
#     Terraform = "true"
#   }
# }


# resource "aws_nat_gateway" "nat" {
#   count         = length(var.eks-subnet-map)
#   allocation_id = aws_eip.eip[count.index].id
#   subnet_id     = aws_subnet.public_subnets[count.index].id

#   tags = {
#     Name = "${var.project}-NATGW-${lookup(var.eks-subnet-map[count.index], "az")}"
#   }
# }