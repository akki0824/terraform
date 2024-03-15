#create EKS Cluster eks_cluster

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.eks_cluster_name
  role_arn = var.eks_cluster_role_arn
  version = var.cluster_version
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access = true
    subnet_ids = [var.private_subnet_az1_id, var.private_subnet_az2_id]
  }
}
