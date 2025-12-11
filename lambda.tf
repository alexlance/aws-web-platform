data "archive_file" "main" {
  type        = "zip"
  output_path = "./lambda.zip"
  source_dir = "./lambda"
}

resource "aws_lambda_alias" "main" {
  name             = "prod"
  description      = "Alias for lambda"
  function_name    = aws_lambda_function.main.arn
  function_version = aws_lambda_function.main.version
}

resource "aws_lambda_function" "main" {
  filename      = data.archive_file.main.output_path
  function_name = var.name
  role          = aws_iam_role.lambda.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.13"
  timeout       = 28
  source_code_hash = data.archive_file.main.output_base64sha256
}

resource "aws_iam_role" "lambda" {
  name = "lambda-${var.name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = ["sts:AssumeRole"]
      }
    ]
  })
}
