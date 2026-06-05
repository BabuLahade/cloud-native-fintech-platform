output "cluster_name" {
  description = "EKS cluster name — used in kubectl commands"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority" {
  description = "Base64 encoded certificate — used by kubectl"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_version" {
  description = "Kubernetes version"
  value       = aws_eks_cluster.main.version
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN — used by IRSA module in Phase 4"
  value       = aws_iam_openid_connect_provider.cluster.arn
}

output "oidc_provider_url" {
  description = "OIDC provider URL — used by IRSA trust policies"
  value       = aws_iam_openid_connect_provider.cluster.url
}

output "node_role_arn" {
  description = "Node IAM role ARN — used by Karpenter in Phase 5"
  value       = aws_iam_role.nodes.arn
}