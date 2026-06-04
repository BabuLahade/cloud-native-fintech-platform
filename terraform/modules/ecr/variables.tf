variable "project" {
  description = "Project name used as prefix"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "services" {
  description = "List of microservice names to create ECR repos for"
  type        = list(string)
  default     = ["market-data-ingestion", "portfolio-calculator", "alert-api"]
}

variable "image_retention_count" {
  description = "Number of images to keep per repository"
  type        = number
  default     = 10
}