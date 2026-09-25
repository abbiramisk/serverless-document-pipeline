variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Prefix used for naming all resources"
  type        = string
  default     = "docpipeline"
}

variable "upload_bucket_name" {
  description = "Globally unique name for the uploads S3 bucket"
  type        = string
  default     = "docpipeline-uploads-2026"
}

variable "frontend_bucket_name" {
  description = "Globally unique name for the frontend S3 bucket"
  type        = string
  default     = "docpipeline-frontend-2026"
}

variable "alert_email" {
  description = "Email address to receive CloudWatch alarm notifications"
  type        = string
}
