variable "region" {}
variable "project_name" {}
variable "vpc_cidr" {}
variable "profile" {}

variable "pub_subnet_az1_cidr" {}
variable "pub_subnet_tag_az1" {}

variable "pub_subnet_az2_cidr" {}
variable "pub_subnet_tag_az2" {}

variable "private_subnet_az1_cidr" {}
variable "private_subnet_tag_az1" {}

variable "private_subnet_az2_cidr" {}
variable "private_subnet_tag_az2" {}

////////////EKS/////
variable "cluster_version" {}
variable "eks_cluster_name" {}

//////NodeGroup/////

variable "desired_size" {}
variable "max_size" {}
variable "min_size" {}
variable "ami_type" {}
variable "capacity_type" {}
variable "disk_size" {}
variable "instance_types" {}




