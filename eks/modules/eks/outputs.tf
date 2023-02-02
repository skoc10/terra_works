output "endpoint" {
  value = aws_eks_cluster.main.endpoint
}
output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}
output "cluster_id" {
  value = aws_eks_cluster.main.id
}
output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}
output "cluster_name" {
  value = aws_eks_cluster.main.name
}