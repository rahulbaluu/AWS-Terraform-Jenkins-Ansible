terraform {
  backend "s3" {
    bucket = "rahulterraformstatefile"
    key = "server_name/statefile"
    region = "eu-west-2"
  }
} 