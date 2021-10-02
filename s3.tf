resource "aws_s3_bucket" "persistent-storage" {
  bucket = "brookline-bay-mcserver-storage"

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
