variable "eks_cluster_name" {}
variable "node_group_arn" {}
variable "pub_subnet_az1_id" {}
variable "pub_subnet_az2_id" {}
variable "private_subnet_az1_id" {}
variable "private_subnet_az2_id" {}

variable "desired_size" {}
variable "max_size" {}
variable "min_size" {}
variable "ami_type" {}
variable "capacity_type" {}
variable "disk_size" {}
variable "instance_types" {}
variable "cluster_version" {}
