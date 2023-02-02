resource "aws_eip" "eip" {
  vpc      = true

  tags = {
    Name = "${var.project}-NATGW-eip"
    Terraform = "true"
  }
}


resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = {
    Name = "${var.project}-NATGW"
  }
}