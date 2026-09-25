# ---------- Dead-letter queue ----------

resource "aws_sqs_queue" "dlq" {
  name = "${var.project_name}-dlq"
}

# ---------- Email notification topic ----------

resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
  # Note: AWS emails a confirmation link to this address after apply —
  # it must be clicked before alarm notifications will actually arrive.
}

# ---------- Alarm: fires when a message lands in the DLQ ----------

resource "aws_cloudwatch_metric_alarm" "dlq_alarm" {
  alarm_name          = "${var.project_name}-dlq-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods   = 1
  metric_name          = "ApproximateNumberOfMessagesVisible"
  namespace            = "AWS/SQS"
  period               = 60
  statistic            = "Maximum"
  threshold            = 0
  alarm_description    = "Fires when a failed document-processing event lands in the DLQ"
  alarm_actions        = [aws_sns_topic.alerts.arn]

  dimensions = {
    QueueName = aws_sqs_queue.dlq.name
  }
}
