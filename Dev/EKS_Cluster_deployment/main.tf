########################################################
# VPC MODULE
########################################################
module "vpc" {
  source = "git::https://github.com/Kasadra-Digidense/aws_services_modules.git//Modules/VPC?ref=main"

  vpc_cidr        = var.vpc_cidr
  vpc_tag         = var.vpc_tag
  ak_pub_subnet   = var.ak_pub_subnet
  ak_pri_subnet   = var.ak_pri_subnet
  az              = var.az
  nat_gateway_tag = var.nat_gateway_tag
}

module "pub_sg" {
  source = "git::https://github.com/Kasadra-Digidense/aws_services_modules.git//Modules/Security_Group?ref=main"

  name        = "pub-sg"
  description = "Public Security Group"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      description     = "Allow SSH"
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      cidr_blocks     = ["203.0.113.25/32"]
      security_groups = []
    },
    {
      description     = "Allow HTTP"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    },
    {
      description     = "Allow HTTPS"
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]

  tags = {
    Name        = "ak_pub_sg"
    Environment = "dev"
  }
}

########################################################
# KMS MODULE
########################################################
module "kms" {
  source = "git::https://github.com/Kasadra-Digidense/aws_services_modules.git//Modules/KMS/modules/kms?ref=main"

  description             = "EKS encryption key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  aliases_name            = "alias/eks-secret-tf"
  role_name               = "eks-kms-user-role"
  key_policy_name         = "eks-kms-policy"
  Policy_description      = "Allows EKS to use KMS key"
  Policy_attachment       = "eks-kms-policy-attachment"
  allow                   = "Allow"
}

########################################################
# IAM MODULES
########################################################
module "eks_iam" {
  source       = "git::https://github.com/Kasadra-Digidense/aws_services_modules.git//Modules/IAM/modules/iam-roles?ref=main"
  project_name = "eks"

}

########################################################
# WAF
########################################################
module "waf" {
  source              = "git::https://github.com/Kasadra-Digidense/aws_services_modules.git//Modules/waf?ref=main"
  aws_region          = var.aws_region
  scope               = var.scope
  web_acl_name        = var.web_acl_name
  web_acl_description = var.web_acl_description
  web_acl_metric_name = var.web_acl_metric_name

}

########################################################
# EKS CLUSTER
########################################################
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = module.eks_iam.eks_cluster_role_arn

  vpc_config {
    subnet_ids = module.vpc.private_subnets
  }

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = module.kms.kms_key_arn
    }
  }

  lifecycle {
    ignore_changes = [
      vpc_config
    ]
  }

  tags = var.tags
}



########################################################
# EKS NODE GROUP
########################################################
resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = var.node_group_name
  node_role_arn   = module.eks_iam.eks_node_role_arn
  subnet_ids      = module.vpc.private_subnets
  instance_types  = ["t3.micro"] # you can also use t3.medium
  ami_type        = "AL2023_x86_64_STANDARD"
  capacity_type   = "ON_DEMAND"
  disk_size       = 20

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 2
  }

  tags = var.tags

  depends_on = [
    aws_eks_cluster.main
  ]
}

# ###########################################
# # ACM CERTIFICATE (EMAIL VALIDATION)
# ###########################################
# data "aws_eks_cluster" "eks" {
#   name = aws_eks_cluster.main.name
# }

# data "aws_eks_cluster_auth" "eks" {
#   name = aws_eks_cluster.main.name
# }
#
# resource "aws_acm_certificate" "ssl" {
#   domain_name       = var.domain_name
#   validation_method = "EMAIL"
#
#   lifecycle {
#     create_before_destroy = true
#   }
# }
#
#






