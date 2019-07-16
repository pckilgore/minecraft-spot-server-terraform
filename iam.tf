resource "aws_iam_instance_profile" "minecraft-server" {
  name = "MinecraftServerInstanceProfile"
  role = "${aws_iam_role.access-persistent-storage.name}"
}

resource "aws_iam_role" "access-persistent-storage" {
  name               = "MinecraftServerInstanceRole"
  description        = "IAM role assumed by minecraft ec2 instance"
  assume_role_policy = "${data.aws_iam_policy_document.ec2-assume-role.json}"
}

resource "aws_iam_role" "access-lambda" {
  name               = "MinecraftServerSchedulerLambdaRole"
  description        = "IAM role assumed by scheduler lambda."
  assume_role_policy = "${data.aws_iam_policy_document.lambda-assume-role.json}"
}

resource "aws_iam_policy" "access-s3-policy" {
  name        = "MinecraftServerAccessS3Policy"
  description = "Allows access to the minecraft server S3 Bucket"
  policy      = "${data.aws_iam_policy_document.access-s3-policy-document.json}"
}

resource "aws_iam_policy" "lambda-logging" {
  name        = "MinecraftLambdaLoggerPolicy"
  description = "IAM policy for logging from a lambda"
  policy      = "${data.aws_iam_policy_document.access-all-cloudwatch-logs.json}"
}

resource "aws_iam_role_policy_attachment" "access-s3-attachment" {
  role       = "${aws_iam_role.access-persistent-storage.name}"
  policy_arn = "${aws_iam_policy.access-s3-policy.arn}"
}

resource "aws_iam_role_policy_attachment" "lambda-logs" {
  role       = "${aws_iam_role.access-lambda.name}"
  policy_arn = "${aws_iam_policy.lambda-logging.arn}"
}

data "aws_iam_policy_document" "access-all-cloudwatch-logs" {
  statement {
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
  }
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

data "aws_iam_policy_document" "lambda-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
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

data "aws_iam_policy_document" "sns_publish_server_notification" {
  statement {
    actions = ["SNS:Publish"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    resources = ["${aws_sns_topic.server-notification.arn}"]
  }
}
