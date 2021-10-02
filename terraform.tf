terraform {
  required_version = "~> 1.0.8"
  required_providers {
    archive = {
      source = "hashicorp/archive"
    }
    aws = {
      source = "hashicorp/aws"
    }
    http = {
      source = "hashicorp/http"
    }
  }
  backend "s3" {
    region         = "us-east-2"
    bucket         = "email.pck.terraform-state"
    key            = "minecraft-spot-instance/terraform.tfstate"
    dynamodb_table = "email.pck.terraform-lock"
  }
}

provider "aws" {
  region  = "us-east-2"
}

