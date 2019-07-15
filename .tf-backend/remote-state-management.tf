provider "aws" {
  version = "~> 2.6"
  region  = "us-east-2"
}

resource "aws_s3_bucket" "terraform-state-s3-store" {
  bucket = "minecraft-server-tfbackend"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name    = "S3 Remote Terraform State Store"
    project = "minecraft"
  }
}

resource "aws_s3_bucket_public_access_block" "terraform-state-s3-store-access-policy" {
  bucket = "${aws_s3_bucket.terraform-state-s3-store.id}"

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_dynamodb_table" "terraform-state-dynamodb-lock" {
  name         = "minecraft-server-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name    = "DynamoDB Terraform State Lock Table"
    project = "minecraft"
  }
}
