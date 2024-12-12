terraform {
  backend "s3" {
    bucket = "eks.terraform"
    key = "eks/terraform.tfstate"
    region = "eu-west-2"
  }
}