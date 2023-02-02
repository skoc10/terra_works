##### Security Groups
resource "aws_security_group" "eks_cluster" {
  name        = "eks-test-env-additional-sg"
  description = "Security group rules for EKS-TEST-ENV Cluster"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.cluster_name}-additional-sg"
    Terraform = "yes"
  }
}