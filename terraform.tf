terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.54.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "A4L-DEV"
}