output "api_invoke_url" {
  description = "Base URL for the API Gateway - append /results or /upload-url"
  value       = aws_apigatewayv2_api.api.api_endpoint
}

output "frontend_website_url" {
  description = "Static website URL for the frontend bucket"
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint
}

output "uploads_bucket_name" {
  value = aws_s3_bucket.uploads.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.results.name
}

output "dlq_url" {
  value = aws_sqs_queue.dlq.url
}
