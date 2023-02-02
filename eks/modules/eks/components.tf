####################################
### aws-load-balancer-controller ###
####################################

resource "kubectl_manifest" "aws-load-balancer-controller" {
  yaml_body  = <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: ${aws_iam_role.aws_load_balancer_controller.arn}
YAML
}

resource "helm_release" "aws-load-balancer-controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.4.7"
  namespace  = "kube-system"
  timeout    = 10 * 60 # seconds

  values = [
    <<VALUES
    image:
      repository: 602401143452.dkr.ecr.eu-central-1.amazonaws.com/amazon/aws-load-balancer-controller
    serviceAccount:
      create: false
      name: aws-load-balancer-controller
    clusterName: "${var.cluster_name}"
VALUES
  ]

  depends_on = [
    aws_eks_node_group.main,
    aws_iam_role_policy_attachment.aws_load_balancer_controller_attach
  ]
}


#############################
### kube-prometheus-stack ###
#############################

resource "kubernetes_namespace" "prometheus-stack" {
  metadata {
    name = "prometheus-stack"
  }

  depends_on = [aws_eks_node_group.main]

}

resource "helm_release" "kube-prometheus-stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "44.3.0"
  namespace  = "prometheus-stack"
  timeout    = 10 * 60 # seconds

  depends_on = [kubernetes_namespace.prometheus-stack]
}

#############################
####### metrics-server ######
#############################

data "kubectl_file_documents" "metrics-server" {
  content = file("../modules/eks/metrics-server.yaml")
}

resource "kubectl_manifest" "metrics-server" {
  for_each  = data.kubectl_file_documents.metrics-server.manifests
  yaml_body = each.value

  depends_on = [aws_eks_node_group.main]

}

##############################
########## fluentd ###########
##############################

resource "kubernetes_namespace" "fluentd" {
  metadata {
    name = "amazon-cloudwatch"
  }

  depends_on = [aws_eks_node_group.main]
}

resource "kubectl_manifest" "fluentd-configmaps" {
  yaml_body  = <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-info
  namespace: amazon-cloudwatch
  selfLink: /api/v1/namespaces/amazon-cloudwatch/configmaps/cluster-info
data:
  cluster.name: ${var.cluster_name}
  logs.region: ${var.region}
binaryData: {}
YAML

  depends_on = [kubernetes_namespace.fluentd]
}


data "kubectl_file_documents" "fluentd" {
  content = file("../modules/eks/fluentd.yaml")
}

resource "kubectl_manifest" "fluentd" {
  for_each  = data.kubectl_file_documents.fluentd.manifests
  yaml_body = each.value

  depends_on = [kubectl_manifest.fluentd-configmaps]

}