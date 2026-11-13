output "web_url" {
  description = "Public URL of the web server."
  value       = "http://${aws_instance.web.public_dns}"
}

output "instance_id" {
  description = "EC2 instance ID."
  value       = aws_instance.web.id
}

output "ssm_session_command" {
  description = "Open a shell on the instance without SSH."
  value       = "aws ssm start-session --target ${aws_instance.web.id} --region ${var.aws_region}"
}

output "dashboard_url" {
  description = "CloudWatch dashboard."
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards/dashboard/${aws_cloudwatch_dashboard.main.dashboard_name}"
}

output "sns_topic_arn" {
  description = "SNS topic used for alerts. Confirm the subscription email before testing alarms."
  value       = aws_sns_topic.alerts.arn
}

output "aws_region" {
  description = "Region the stack is deployed in."
  value       = var.aws_region
}
