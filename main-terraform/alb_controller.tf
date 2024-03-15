resource "aws_iam_policy" "custom_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "Policy from json file for ALB controller"

  # Specify the policy document as a JSON string
  policy = file("./iam_policy.json")
  depends_on = [ null_resource.local_downloads ]
}

resource "aws_iam_role" "AmazonEKSLoadBalancerControllerRole" {
  name               = "AmazonEKSLoadBalancerControllerRole"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "${aws_iam_openid_connect_provider.oidc.id}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${replace(module.eks.identity, "https://", "")}:aud": "sts.amazonaws.com",
                    "${replace(module.eks.identity, "https://", "")}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
                }
            }
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy" {
  policy_arn = aws_iam_policy.custom_policy.arn
  role       = aws_iam_role.AmazonEKSLoadBalancerControllerRole.name
}


data "tls_certificate" "eks-cluster-tls-certificate" {
  url = module.eks.identity
}

data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "oidc" {
  url             = module.eks.identity
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks-cluster-tls-certificate.certificates[0].sha1_fingerprint]
}

resource "kubernetes_service_account" "aws-load-balancer-controller-service-account" {
  depends_on = [aws_iam_role.AmazonEKSLoadBalancerControllerRole, null_resource.local_downloads]
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = { "app.kubernetes.io/component" = "controller"
    "app.kubernetes.io/name" = "aws-load-balancer-controller" }
    annotations = { "eks.amazonaws.com/role-arn" = "${aws_iam_role.AmazonEKSLoadBalancerControllerRole.arn}" }
  }
  automount_service_account_token = true
}


resource "null_resource" "local_downloads" {
  depends_on = [module.eks]
  provisioner "local-exec" {
    command = <<EOF
    aws eks update-kubeconfig --name ${var.eks_cluster_name} --region ${var.region} --profile ${var.profile}
    EOF
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  depends_on = [kubernetes_service_account.aws-load-balancer-controller-service-account]
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  # timeout = 300
  set {
    name  = "clusterName"
    value = var.eks_cluster_name
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  set {
    name  = "image.repository"
    value = "public.ecr.aws/eks/aws-load-balancer-controller"
  }
  set {
    name  = "image.tag"
    value = "v2.7.1"
  }
  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }
  set {
    name  = "region"
    value = var.region

  }
}