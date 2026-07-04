# ── IRSA: Market Data Ingestion ───────────────────────────────────────
# Trust policy: only the market-data-sa ServiceAccount in production
# namespace can assume this role
resource "aws_iam_role" "market_data" {
  name = "${var.project}-${var.environment}-market-data-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          # Format: OIDC_URL:sub = system:serviceaccount:NAMESPACE:SERVICE_ACCOUNT_NAME
          "${var.oidc_provider_url}:sub" = "system:serviceaccount:production:market-data-sa"
          "${var.oidc_provider_url}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = {
    Name    = "${var.project}-${var.environment}-market-data-role"
    Service = "market-data-ingestion"
  }
}

# Market Data permissions — SQS read only + DynamoDB write
resource "aws_iam_role_policy" "market_data" {
  name = "${var.project}-${var.environment}-market-data-policy"
  role = aws_iam_role.market_data.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SQSAccess"
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        # Restrict to ONLY this specific queue — not all SQS
        Resource = var.sqs_queue_arn
      },
      {
        Sid    = "DynamoDBWrite"
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem"
        ]
        # Restrict to ONLY this specific table — not all DynamoDB
        Resource = var.market_data_table_arn
      }
    ]
  })
}

# ── IRSA: Portfolio Calculator ────────────────────────────────────────
resource "aws_iam_role" "portfolio" {
  name = "${var.project}-${var.environment}-portfolio-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${var.oidc_provider_url}:sub" = "system:serviceaccount:production:portfolio-sa"
          "${var.oidc_provider_url}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = {
    Name    = "${var.project}-${var.environment}-portfolio-role"
    Service = "portfolio-calculator"
  }
}

# Portfolio permissions — DynamoDB read+write on portfolios table only
resource "aws_iam_role_policy" "portfolio" {
  name = "${var.project}-${var.environment}-portfolio-policy"
  role = aws_iam_role.portfolio.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "DynamoDBAccess"
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:Query"
      ]
      Resource = var.portfolios_table_arn
    }]
  })
}

# ── IRSA: Alert API ───────────────────────────────────────────────────
resource "aws_iam_role" "alert_api" {
  name = "${var.project}-${var.environment}-alert-api-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${var.oidc_provider_url}:sub" = "system:serviceaccount:production:alert-sa"
          "${var.oidc_provider_url}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = {
    Name    = "${var.project}-${var.environment}-alert-api-role"
    Service = "alert-api"
  }
}

# Alert API permissions — DynamoDB read ONLY on alerts table
resource "aws_iam_role_policy" "alert_api" {
  name = "${var.project}-${var.environment}-alert-api-policy"
  role = aws_iam_role.alert_api.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DynamoDBReadOnly"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        # Read-only — cannot write, cannot delete, cannot access other tables
        Resource = var.alerts_table_arn
      },
      {
        Sid    = "DynamoDBWrite"
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem"
        ]
        Resource = var.alerts_table_arn
      }
    ]
  })
}