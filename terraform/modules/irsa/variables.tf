variable "project" {
  description = "Project name prefix"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

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