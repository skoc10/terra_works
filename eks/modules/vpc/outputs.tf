output "vpc_id" {
    value = aws_vpc.main.id  
}

output "public_subnets" {
    value = aws_subnet.public_subnets.*.id
}

output "eks_subnets" {
    value = aws_subnet.eks_subnets.*.id  
}

# output "private_subnets" {
#     value = aws_subnet.private_subnets.*.id  
# }

# output "db_subnets" {
#     value = aws_subnet.data_subnets.*.id
  
# }
