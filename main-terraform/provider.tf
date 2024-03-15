provider "aws" {
  profile = "akhil"
  region  = "ap-south-1"

}

provider "null" {}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}