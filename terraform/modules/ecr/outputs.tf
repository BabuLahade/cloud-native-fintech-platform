output "repository_urls" {
  description = "ECR repository URLs — used in Docker push commands and K8s manifests"
  value       = { for k, v in aws_ecr_repository.services : k => v.repository_url }
}

output "repository_arns" {
  description = "ECR repository ARNs — used in IAM policies"
  value       = { for k, v in aws_ecr_repository.services : k => v.arn }
}

output "registry_id" {
  description = "ECR registry ID — same as AWS account ID"
  value       = values(aws_ecr_repository.services)[0].registry_id
}