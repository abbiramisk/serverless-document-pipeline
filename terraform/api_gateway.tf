resource "aws_apigatewayv2_api" "api" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

# ---------- /results -> get_results Lambda ----------

resource "aws_apigatewayv2_integration" "get_results" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.get_results.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_results" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /results"
  target    = "integrations/${aws_apigatewayv2_integration.get_results.id}"
}

resource "aws_lambda_permission" "api_invoke_get_results" {
  statement_id  = "AllowAPIGatewayInvokeGetResults"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_results.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

# ---------- /upload-url -> generate_upload_url Lambda ----------

resource "aws_apigatewayv2_integration" "generate_upload_url" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.generate_upload_url.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "generate_upload_url" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /upload-url"
  target    = "integrations/${aws_apigatewayv2_integration.generate_upload_url.id}"
}

resource "aws_lambda_permission" "api_invoke_generate_upload_url" {
  statement_id  = "AllowAPIGatewayInvokeUploadUrl"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.generate_upload_url.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}
