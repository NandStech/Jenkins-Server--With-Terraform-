terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket = "ann-terraform-state"
    key    = "global/iam/terraform.tfstate"
    region = "us-west-1"
    # Replace this with your DynamoDB table name!
    dynamodb_table = "ann-terraform-locks"
    encrypt        = true
  }
}
