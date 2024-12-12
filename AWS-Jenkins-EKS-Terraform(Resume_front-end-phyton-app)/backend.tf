terraform {
  backend "s3" {
    bucket = "jenkinseksterraform"
    key = "jenkins/terraform.tfstate"
    region = "eu-west-2"
  }
}