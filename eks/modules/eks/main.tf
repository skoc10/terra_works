resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.main.arn
  version  = var.eks_version

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    subnet_ids              = var.eks_subnets
    security_group_ids      = [aws_security_group.eks_cluster.id]
    endpoint_public_access  = var.endpoint_public_access
    endpoint_private_access = var.endpoint_private_access
  }

  depends_on = [
    aws_iam_role_policy_attachment.EKS-AmazonEKSClusterPolicy,
    aws_cloudwatch_log_group.eks_cloudwatch
  ]
}


resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids = var.eks_subnets

  capacity_type  = "ON_DEMAND"
  instance_types = var.node_instance_types
  disk_size      = var.node_disk_size


  scaling_config {
    desired_size = var.scaling_desired_size
    max_size     = var.scaling_max_size
    min_size     = var.scaling_min_size
  }

  update_config {
    max_unavailable = var.node_max_unavailable
  }

  depends_on = [
    aws_iam_role_policy_attachment.Node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.Node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.Node-AmazonEC2ContainerRegistryReadOnly,
  ]
}


resource "aws_eks_addon" "vpc-cni" {
  cluster_name      = aws_eks_cluster.main.name
  addon_name        = "vpc-cni"
  addon_version     = "v1.12.0-eksbuild.1"
  resolve_conflicts = "OVERWRITE"

  depends_on = [aws_eks_node_group.main]
}

# resource "aws_eks_addon" "kube_proxy" {
#   cluster_name      = aws_eks_cluster.main.name
#   addon_name        = "kube-proxy"
#   addon_version     = "v1.22.11-eksbuild.2"
#   resolve_conflicts = "OVERWRITE"

#   depends_on = [aws_eks_node_group.main]
# }

# resource "aws_eks_addon" "core_dns" {
#   cluster_name      = aws_eks_cluster.main.name
#   addon_name        = "coredns"
#   addon_version     = "v1.8.7-eksbuild.1"
#   resolve_conflicts = "OVERWRITE"

#   depends_on = [aws_eks_node_group.main]
# }


resource "aws_iam_role" "main" {
  name = "eks-cluster-${var.cluster_name}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "EKS-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.main.name
}


resource "aws_iam_role" "nodes" {
  name = "eks-node-group-${var.cluster_name}"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "Node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "Node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "Node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}