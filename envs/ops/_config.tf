terraform {
  required_version = "1.14.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.37.0"
    }
  }

  backend "s3" {
    bucket       = "tfstate-seithus1"
    key          = "terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
    encrypt      = true
    profile      = "self"
  }
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "self"
}
