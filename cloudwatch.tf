resource "aws_cloudwatch_event_rule" "active-hours-heartbeat" {
  name                = "MinecraftActiveHoursHeartbeat"
  description         = "Trigger minecraft server heartbeat."
  schedule_expression = "cron(0/10 * ? * * *)"
  tags = {
    Project = "minecraft"
  }
}

resource "aws_cloudwatch_event_target" "active-hours-heartbeat" {
  rule = "${aws_cloudwatch_event_rule.active-hours-heartbeat.name}"
  arn  = "${aws_sns_topic.server-notification.arn}"
}


resource "aws_cloudwatch_log_group" "active-hours-heartbeat" {
  name              = "/aws/lambda/${aws_lambda_function.heartbeat-handler.function_name}"
  retention_in_days = 3
}
