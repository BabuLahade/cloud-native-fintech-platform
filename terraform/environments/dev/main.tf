# terraform {
#   required_version = ">= 1.9"
#   required_providers {
#     aws ={
#         source = "hashicorp/aws"
#         version = "~> 5.0"
#     }
#   }
# }

# provider "aws" {
#     region = var.aws_region

#     default_tags {
#       tags = {
#         Project = "cloud-native-fintech"
#         Environment = var.environment
#         ManagedBy   = "terraform"
#         Owner       = "BabuLahade"
#       }
#     }
# }

# data "aws_caller_identity" "current" {}
# data "aws_region" "current" {}

terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "cloud-native-fintech"
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = "BabuLahade"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ── Phase 1: VPC ─────────────────────────────────────────────────────
module "vpc" {
  source      = "../../modules/vpc"
  project     = var.project
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
}

# ── Phase 1: ECR ─────────────────────────────────────────────────────
module "ecr" {
  source      = "../../modules/ecr"
  project     = var.project
  environment = var.environment
  services    = var.services
}

# ── Phase 2: EKS (uncomment when Phase 1 apply is done) ──────────────
# module "eks" {
#   source          = "../../modules/eks"
#   project         = var.project
#   environment     = var.environment
#   cluster_version = var.cluster_version
#   vpc_id          = module.vpc.vpc_id
#   private_subnets = module.vpc.private_subnet_ids
#   public_subnets  = module.vpc.public_subnet_ids
# }