output "market_data_role_arn" {
  description = "IAM role ARN for market-data-sa ServiceAccount annotation"
  value       = aws_iam_role.market_data.arn
}

output "portfolio_role_arn" {
  description = "IAM role ARN for portfolio-sa ServiceAccount annotation"
  value       = aws_iam_role.portfolio.arn
}

output "alert_api_role_arn" {
  description = "IAM role ARN for alert-sa ServiceAccount annotation"
  value       = aws_iam_role.alert_api.arn
}