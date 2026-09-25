# ---------- Package each function's source into a zip ----------

data "archive_file" "generate_upload_url_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/generate_upload_url"
  output_path = "${path.module}/build/generate_upload_url.zip"
}

data "archive_file" "process_document_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/process_document"
  output_path = "${path.module}/build/process_document.zip"
}

data "archive_file" "get_results_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/get_results"
  output_path = "${path.module}/build/get_results.zip"
}

# ---------- Function 1: generate a presigned S3 upload URL ----------

resource "aws_lambda_function" "generate_upload_url" {
  function_name    = "${var.project_name}-presigned-url"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.13"
  timeout          = 30
  filename         = data.archive_file.generate_upload_url_zip.output_path
  source_code_hash = data.archive_file.generate_upload_url_zip.output_base64sha256

  environment {
    variables = {
      UPLOAD_BUCKET = aws_s3_bucket.uploads.bucket
    }
  }
}

# ---------- Function 2: process an uploaded document ----------

resource "aws_lambda_function" "process_document" {
  function_name    = "${var.project_name}-processor"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.13"
  timeout          = 30
  filename         = data.archive_file.process_document_zip.output_path
  source_code_hash = data.archive_file.process_document_zip.output_base64sha256

  environment {
    variables = {
      RESULTS_TABLE = aws_dynamodb_table.results.name
    }
  }

  dead_letter_config {
    target_arn = aws_sqs_queue.dlq.arn
  }
}

# ---------- Function 3: fetch processing results ----------

resource "aws_lambda_function" "get_results" {
  function_name    = "${var.project_name}-fetch-results"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.13"
  timeout          = 30
  filename         = data.archive_file.get_results_zip.output_path
  source_code_hash = data.archive_file.get_results_zip.output_base64sha256

  environment {
    variables = {
      RESULTS_TABLE = aws_dynamodb_table.results.name
    }
  }
}
