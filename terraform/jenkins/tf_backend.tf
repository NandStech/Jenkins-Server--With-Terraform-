terraform {
  backend "s3" {
    bucket = "ann-terraform-state"
    key    = "global/jenkins/terraform.tfstate"
    region = "us-west-1"

    dynamodb_table = "ann-terraform-locks"
    encrypt        = true
  }
}
