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

// phase 4 variales variable "oidc_provider_arn" {
variable "oidc_provider_arn" {
  description = "OIDC provider ARN from EKS module output"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC provider URL from EKS module output — without https://"
  type        = string
}

variable "sqs_queue_arn" {
  description = "ARN of the SQS market data queue"
  type        = string
}

variable "market_data_table_arn" {
  description = "ARN of fintech-market-data DynamoDB table"
  type        = string
}

variable "portfolios_table_arn" {
  description = "ARN of fintech-portfolios DynamoDB table"
  type        = string
}

variable "alerts_table_arn" {
  description = "ARN of fintech-alerts DynamoDB table"
  type        = string
}