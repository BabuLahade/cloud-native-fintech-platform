#!/bin/bash
# Run this ONCE before terraform init
# Creates the S3 bucket and DynamoDB table for remote state management

set -e

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="ap-south-1"
BUCKET="fintech-platform-bucket"
TABLE="fintech-tf-locks"

echo "Account ID: $ACCOUNT_ID"
echo "Region: $REGION"
echo "Bucket: $BUCKET"
echo "DynamoDB Table: $TABLE"

echo "Creating S3 bucket for terraform state ... "
aws s3api create-bucket \
    --bucket $BUCKET \
    --region $REGION \
    --create-bucket-configuration LocationConstraint=$REGION

echo "bucket versioning enabled"
aws s3api put-bucket-versioning \
    --bucket $BUCKET \
    --versioning-configuration Status=Enabled

echo "enabling bucket encryption"
aws s3api put-bucket-encryption \
    --bucket $BUCKET \
    --server-side-encryption-configuaration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

echo "block public access to the bucket"
aws s3api put-public-access-block \
    --bucket $BUCKET \
    --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

echo "Creating DynamoDB table for terraform state locking ... "
aws dynamodb create-table \
    --table-name $TABLE \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region $REGION


echo ""
echo "Done. Now run:"
echo "  cd terraform/environments/dev"
echo "  terraform init"