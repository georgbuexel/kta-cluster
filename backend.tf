terraform {
  backend "s3" {
    bucket         = "kta-cluster-terraform-states"
    key            = "states/terraform.tfstate"        # Path for state file
    region         = "eu-central-1"
    dynamodb_table = "terraform-lock-table"         # DynamoDB table for locking
  }
}
