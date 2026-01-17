variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "critical_alert_email" {
  description = "Email address for critical alerts (errors, failures)"
  type        = string
  default     = ""
}

variable "performance_alert_email" {
  description = "Email address for performance alerts (duration, memory)"
  type        = string
  default     = ""
}

variable "log_alert_email" {
  description = "Email address for log-based alerts"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "enable_sns" {
  description = "Enable creation of SNS subscriptions (set false in dev to avoid sending emails/SMS). Topics are still created by default."
  type        = bool
  default     = false
}
