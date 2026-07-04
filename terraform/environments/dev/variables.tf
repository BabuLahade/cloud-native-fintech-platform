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
variable "sqs_queue_arn" {
  description = "SQS market data queue ARN"
  type        = string
  default     = "arn:aws:sqs:ap-south-1:882083662991:fintech-market-data"
}

variable "market_data_table_arn" {
  description = "DynamoDB market data table ARN"
  type        = string
  default     = "arn:aws:dynamodb:ap-south-1:882083662991:table/fintech-market-data"
}

variable "portfolios_table_arn" {
  description = "DynamoDB portfolios table ARN"
  type        = string
  default     = "arn:aws:dynamodb:ap-south-1:882083662991:table/fintech-portfolios"
}

variable "alerts_table_arn" {
  description = "DynamoDB alerts table ARN"
  type        = string
  default     = "arn:aws:dynamodb:ap-south-1:882083662991:table/fintech-alerts"
}