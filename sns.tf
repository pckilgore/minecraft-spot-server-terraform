resource "aws_sns_topic" "server-notification" {
  name         = "MinecraftServerNotificationSNSTopic"
  display_name = "Minecraft Server Notification SNS Topic"
}

resource "aws_sns_topic_policy" "server-notification" {
  arn    = aws_sns_topic.server-notification.arn
  policy = data.aws_iam_policy_document.sns_publish_server_notification.json
}

resource "aws_sns_topic_subscription" "server-notification" {
  topic_arn = aws_sns_topic.server-notification.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.heartbeat-handler.arn
}
