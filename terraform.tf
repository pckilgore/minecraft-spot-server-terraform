
provider "aws" {
  version = "~> 2.6"
  region  = "us-east-2"
}

terraform {
  backend "s3" {
    encrypt        = true
    region         = "us-east-2"
    bucket         = "minecraft-server-tfbackend"
    key            = "tfstate"
    dynamodb_table = "minecraft-server-state-lock"
  }
}


