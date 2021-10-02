resource "aws_lambda_function" "heartbeat-handler" {
  function_name = "MinecraftServerHeartbeatHandler"
  description   = "Manage EC2 state on heartbeat."
  role          = aws_iam_role.access-lambda.arn

  runtime          = "nodejs8.10"
  filename         = "${path.module}/pkg-lambda/heartbeat-handler.zip"
  handler          = "index.handler"
  source_code_hash = data.archive_file.heartbeat-handler-source.output_base64sha256
  publish          = true

  reserved_concurrent_executions = 1

  tags = {
    Project = "minecraft"
  }
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.heartbeat-handler.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.server-notification.arn
}

data "archive_file" "heartbeat-handler-source" {
  type        = "zip"
  source_dir  = "${path.module}/src-lambda/heartbeat-handler"
  output_path = "${path.module}/pkg-lambda/heartbeat-handler.zip"
}
