terraform {
  required_version = ">= 1.9"
  required_providers {
    aws ={
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
    region = "var.aws_region"

    default_tags {
      tags = {
        Project = "cloud-native-fintech"
        Environment = var.environment
        ManagedBy   = "terraform"
        Owner       = "BabuLahade"
      }
    }
}