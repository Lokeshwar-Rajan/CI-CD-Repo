resource "aws_sns_topic" "user_updates" {
  name = var.sns_topic_name
  tags = {
    Environment = var.environment
    Application = var.application_name
    Owner       = var.owner
  }
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.user_updates.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
