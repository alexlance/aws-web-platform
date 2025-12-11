resource "aws_api_gateway_rest_api" "main" {
  name               = var.name
  description        = ""
  minimum_compression_size = 0  # enable gzip compression
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  depends_on = [
    aws_api_gateway_method.main
  ]
}

resource "aws_api_gateway_stage" "main" {
  cache_cluster_enabled = false
  cache_cluster_size    = null
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = "prod"
}

resource "aws_api_gateway_base_path_mapping" "main" {
  api_id      = aws_api_gateway_rest_api.main.id
  domain_name = aws_api_gateway_domain_name.main.domain_name
  stage_name  = aws_api_gateway_stage.main.stage_name
}

resource "aws_api_gateway_domain_name" "main" {
  domain_name     = "api.${var.domain}"
  certificate_arn =  aws_acm_certificate.api.arn
  security_policy  = "TLS_1_2"
}

output "url_api" {
  value = aws_api_gateway_domain_name.main.cloudfront_domain_name
}


// Lambda integration
resource "aws_api_gateway_resource" "main" {
  path_part   = "{proxy+}"
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.main.id
}

resource "aws_api_gateway_method" "main" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.main.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "main" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.main.id
  http_method             = aws_api_gateway_method.main.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_alias.main.invoke_arn
}

resource "aws_lambda_permission" "main" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  qualifier     = aws_lambda_alias.main.name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*"
}
