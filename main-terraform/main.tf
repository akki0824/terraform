terraform {
  backend "s3" {
    profile = "akhil"
    bucket  = "valaxy-bucket-statefile"
    key     = "state-file/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true

  }
}

module "vpc" {
  source                  = "../modules/vpc"
  region                  = var.region
  project_name            = var.project_name
  vpc_cidr                = var.vpc_cidr
  pub_subnet_az1_cidr     = var.pub_subnet_az1_cidr
  pub_subnet_tag_az1      = var.pub_subnet_tag_az1
  pub_subnet_az2_cidr     = var.pub_subnet_az2_cidr
  pub_subnet_tag_az2      = var.private_subnet_tag_az2
  private_subnet_az1_cidr = var.private_subnet_az1_cidr
  private_subnet_tag_az1  = var.private_subnet_tag_az1
  private_subnet_az2_cidr = var.private_subnet_az2_cidr
  private_subnet_tag_az2  = var.private_subnet_tag_az2

}

module "nat" {
  source                = "../modules/nat"
  vpc_id                = module.vpc.vpc_id
  pub_subnet_az1_id     = module.vpc.pub_subnet_az1_id
  pub_subnet_az2_id     = module.vpc.pub_subnet_az2_id
  private_subnet_az1_id = module.vpc.private_subnet_az1_id
  private_subnet_az2_id = module.vpc.private_subnet_az2_id
  igw_id                = module.vpc.igw_id
}

module "iam" {
  source       = "../modules/iam"
  project_name = var.project_name
}

module "eks" {
  source                = "../modules/eks"
  eks_cluster_name      = var.eks_cluster_name
  cluster_version       = var.cluster_version
  eks_cluster_role_arn  = module.iam.eks_cluster_role_arn
  private_subnet_az1_id = module.vpc.private_subnet_az1_id
  private_subnet_az2_id = module.vpc.private_subnet_az2_id

}

module "nodegroup" {
  source                = "../modules/nodegroup"
  eks_cluster_name      = module.eks.eks_cluster_name
  node_group_arn        = module.iam.node_group_arn
  pub_subnet_az1_id     = module.vpc.pub_subnet_az1_id
  pub_subnet_az2_id     = module.vpc.pub_subnet_az2_id
  private_subnet_az1_id = module.vpc.private_subnet_az1_id
  private_subnet_az2_id = module.vpc.private_subnet_az2_id
  desired_size          = var.desired_size
  max_size              = var.max_size
  min_size              = var.min_size
  ami_type              = var.ami_type
  capacity_type         = var.capacity_type
  disk_size             = var.disk_size
  instance_types        = var.instance_types
  cluster_version       = var.cluster_version
  depends_on            = [module.iam]
}