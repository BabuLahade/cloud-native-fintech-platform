terraform {
  backend "s3" {
    bucket = "fintech-platform-bucket"
    key = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "fintech-tf-locks"
    encrypt = true
  }
}