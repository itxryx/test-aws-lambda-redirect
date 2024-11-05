provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_iam_role" "lambda_role" {
  name = "test_lambda_redirect_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "redirect_function" {
  filename         = "../function.zip"
  function_name    = "test-lambda-redirect"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  source_code_hash = filebase64sha256("../function.zip")

  environment {
    variables = {
      TARGET_URL = "https://example.com"
    }
  }
}

resource "aws_lambda_function_url" "function_url" {
  function_name = aws_lambda_function.redirect_function.function_name
  authorization_type = "NONE"

  cors {
    allow_origins = ["*"]
  }
}

resource "aws_lambda_permission" "allow_function_url" {
  statement_id  = "AllowPublicAccessToFunctionURL"
  action        = "lambda:InvokeFunctionUrl"
  function_name = aws_lambda_function.redirect_function.function_name
  principal     = "*"
  function_url_auth_type = "NONE"
}