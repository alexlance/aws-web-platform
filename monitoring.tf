
resource "aws_sns_topic" "main" {
  name = "${var.name}-alerts"
}

resource "aws_sns_topic_subscription" "main" {
  topic_arn = aws_sns_topic.main.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "main" {
  alarm_name                = "${var.name} error"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "Errors"
  namespace                 = "AWS/Lambda"
  datapoints_to_alarm       = 1
  period                    = 180
  threshold                 = 0
  statistic                 = "Sum"
  alarm_description         = "The ${var.name} lambda just experienced an error. Check the lambda logs in cloudwatch."
  alarm_actions             = [aws_sns_topic.main.arn]
  treat_missing_data        = "notBreaching"
  dimensions = {
    FunctionName = var.name
  }
}


resource "aws_sns_topic" "billing" {
  # Must create this in us-east-1 for billing alerts
  provider = aws.virginia
  name = "billing-alerts"
}

resource "aws_sns_topic_subscription" "billing" {
  # Must create this in us-east-1 for billing alerts
  provider = aws.virginia
  topic_arn = aws_sns_topic.billing.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "daily_billing" {
  # Must create this in us-east-1
  provider            = aws.virginia
  region              = "us-east-1"
  alarm_name          = "Daily spend over $20"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  statistic           = "Maximum"
  period              = 86400  # 1 day in seconds
  threshold           = 20
  alarm_description   = "Daily AWS spend exceeded $20."
  alarm_actions       = [aws_sns_topic.billing.arn]
  dimensions = {
    Currency = "USD"
  }
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "monthly_billing" {
  # Must create this in us-east-1
  provider = aws.virginia
  region              = "us-east-1"
  alarm_name          = "Monthly spend over $50"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  statistic           = "Maximum"
  period              = 86400  # billing metrics only update daily, so period = 1 day is fine
  threshold           = 50
  alarm_description   = "Monthly AWS spend exceeded $50."
  alarm_actions       = [aws_sns_topic.billing.arn]
  dimensions = {
    Currency = "USD"
  }
  treat_missing_data = "notBreaching"
}
