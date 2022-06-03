provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
  assume_role {
    role_arn = var.tf_role_arn
  }
  default_tags {
    tags = {
      "terraform:env"     = var.environment
      "terraform:author"  = "TurtleBuild"
      "terraform:project" = "web"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.14.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.2.0"
    }
  }
}