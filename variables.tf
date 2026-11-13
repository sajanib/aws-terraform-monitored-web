variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "ap-southeast-2"
}

variable "project_name" {
  description = "Name prefix for all resources."
  type        = string
  default     = "monitored-web"
}

variable "owner" {
  description = "Owner tag applied to every resource."
  type        = string
  default     = "sajanib"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets (one per availability zone)."
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type. Keep it small to stay within free tier / credits."
  type        = string
  default     = "t3.micro"
}

variable "allowed_http_cidrs" {
  description = "CIDR blocks allowed to reach the web server on port 80."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "alert_email" {
  description = "Email address that receives CloudWatch alarm and budget notifications."
  type        = string
}

variable "cpu_alarm_threshold" {
  description = "CPU utilisation (%) that triggers an alarm."
  type        = number
  default     = 80
}

variable "memory_alarm_threshold" {
  description = "Memory used (%) that triggers an alarm."
  type        = number
  default     = 80
}

variable "disk_alarm_threshold" {
  description = "Root disk used (%) that triggers an alarm."
  type        = number
  default     = 80
}

variable "monthly_budget_usd" {
  description = "Monthly cost budget in USD. An email is sent at 80% of actual spend."
  type        = string
  default     = "5"
}
