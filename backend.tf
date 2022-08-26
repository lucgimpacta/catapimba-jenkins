terraform {
  backend "s3" {
    bucket = "terraform-state-luks"
    key    = "terraform-jenkins-catapimba.tfstate"
    region = "us-east-1"
  }
}
