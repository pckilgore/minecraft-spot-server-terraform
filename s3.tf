variable "BUCKET" {
  type = "string"
}

resource "aws_s3_bucket" "persistent-storage" {
  bucket = "${var.BUCKET}"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name    = "Minecraft Server Storage Bucket"
    Project = "minecraft"
  }
}
