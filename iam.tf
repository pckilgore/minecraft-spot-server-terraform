resource "aws_iam_instance_profile" "minecraft-server" {
  name = "MinecraftServerInstanceProfile"
  role = "${aws_iam_role.access-persistent-storage.name}"
}

resource "aws_iam_role" "access-persistent-storage" {
  name               = "MinecraftServerInstanceRole"
  description        = "IAM role assumed by minecraft ec2 instance"
  assume_role_policy = "${data.aws_iam_policy_document.ec2-assume-role.json}"
}

resource "aws_iam_role_policy_attachment" "access-s3-attachment" {
  role       = "${aws_iam_role.access-persistent-storage.name}"
  policy_arn = "${aws_iam_policy.access-s3-policy.arn}"
}

resource "aws_iam_policy" "access-s3-policy" {
  name        = "MinecraftServerAccessS3Policy"
  description = "Allows access to the minecraft server S3 Bucket"
  policy      = "${data.aws_iam_policy_document.access-s3-policy-document.json}"
}

data "aws_iam_policy_document" "access-s3-policy-document" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucketVersions",
      "s3:RestoreObject",
      "s3:ListBucket",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.persistent-storage.arn}/*",
      "${aws_s3_bucket.persistent-storage.arn}"
    ]
  }
}

data "aws_iam_policy_document" "ec2-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
