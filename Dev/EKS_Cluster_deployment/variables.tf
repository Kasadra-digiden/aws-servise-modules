###########################################################
# Cluster
###########################################################
variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "demo-eks-cluster"
}

variable "node_group_name" {
  description = "EKS node group name"
  type        = string
  default     = "demo-node-group"
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 2
}

###########################################################
# ACM
###########################################################
variable "domain_name" {
  type    = string
  default = "softwarestack.xyz"
}

###########################################################
# VPC Variables
###########################################################
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "192.168.0.0/24"
}

variable "vpc_tag" {
  description = "Tags for VPC"
  type = object({
    Name        = string
    Environment = string
  })
  default = {
    Name        = "ak-vpc"
    Environment = "Dev"
  }
}

###########################################################
# Subnet Variables
###########################################################
variable "ak_pub_subnet" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["192.168.0.0/26", "192.168.0.64/26"]
}

variable "ak_pri_subnet" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["192.168.0.128/26", "192.168.0.192/26"]
}

variable "az" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

###########################################################
# NAT Gateway Tags
###########################################################
variable "nat_gateway_tag" {
  description = "Tags for NAT Gateway"
  type = object({
    Name = string
  })
  default = {
    Name = "ak-nat-gateway"
  }
}

###########################################################
# Security Group
###########################################################

variable "sg_port_pub" {
  description = "Port traffic enable"
  type        = list(number)
  default     = [22, 80, 443, 5432]
}

variable "tags" {
  description = "Common tags for AWS resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "eks"
  }
}

###########################################################
# WAF
###########################################################

variable "aws_region" {
  description = "The AWS region to deploy the WAF and associated resources"
  type        = string
  default     = "us-east-1"
}

variable "scope" {
  description = "Scope of the WAF Web ACL (REGIONAL or CLOUDFRONT)"
  type        = string
  default     = "CLOUDFRONT"
}

variable "web_acl_name" {
  description = "Name of the WAF Web ACL"
  type        = string
  default     = "cloud-web-acl"
}

variable "web_acl_description" {
  description = "Description of the WAF Web ACL"
  type        = string
  default     = "Digidense Web ACL for managing WAF rules"
}

variable "web_acl_metric_name" {
  description = "Metric name for CloudWatch visibility for the Web ACL"
  type        = string
  default     = "cloudWebACL"
}


