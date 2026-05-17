terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false
  one_nat_gateway_per_az = true
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Environment = var.environment
  }
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = concat(module.vpc.private_subnets, module.vpc.public_subnets)

  eks_managed_node_group_defaults = {
    disk_size      = 30
    instance_types = [var.node_instance_type]
  }

  eks_managed_node_groups = {
    nodes = {
      name         = "${var.cluster_name}-nodes"
      min_size     = 1
      max_size     = 5
      desired_size = var.node_count

      disk_size       = 30
      instance_types  = [var.node_instance_type]
      capacity_type   = "ON_DEMAND"

      labels = {
        Environment = var.environment
      }

      tags = {
        Environment = var.environment
      }
    }
  }

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    ebs-csi-driver = {
      most_recent = true
    }
  }

  manage_aws_auth_configmap = true

  tags = {
    Environment = var.environment
  }
}

resource "aws_ec2_tag" "private_subnets" {
  for_each = toset(module.vpc.private_subnets)

  resource_id = each.value
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}

resource "aws_ec2_tag" "public_subnets" {
  for_each = toset(module.vpc.public_subnets)

  resource_id = each.value
  key         = "kubernetes.io/role/elb"
  value       = "1"
}
