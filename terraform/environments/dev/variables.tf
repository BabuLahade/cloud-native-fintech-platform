# variable "aws_region" {
#   description = "AWS region for all resources"
#   type        = string
#   default     = "ap-south-1"
# }

# variable "environment" {
#   description = "Environment name"
#   type        = string
#   default     = "dev"
# }

# variable "project" {
#   description = "Project name prefix for all resources"
#   type        = string
#   default     = "fintech"
# }

# variable "cluster_version" {
#   description = "Kubernetes version for EKS"
#   type        = string
#   default     = "1.30"
# }
variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name prefix for all resources"
  type        = string
  default     = "fintech"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.30"
}

variable "services" {
  description = "Microservice names for ECR repositories"
  type        = list(string)
  default     = ["market-data-ingestion", "portfolio-calculator", "alert-api"]
}