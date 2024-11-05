# AWSプロバイダーの設定
# 東京リージョンを使用
provider "aws" {
  region = "ap-northeast-1"
}

# IAMロールの作成
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

# IAMポリシーのアタッチ
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda関数の定義
resource "aws_lambda_function" "redirect_function" {
  filename         = "../function.zip"              # デプロイするコードの.zipファイル
  function_name    = "test-lambda-redirect"         # 関数名
  role             = aws_iam_role.lambda_role.arn   # IAMロールのARNを指定
  handler          = "index.handler"                # エントリーポイントの設定 (index.js / handler())
  runtime          = "nodejs20.x"                   # ランタイム
  source_code_hash = filebase64sha256("../function.zip") # デプロイ検知用のハッシュ値

  # 環境変数の設定
  environment {
    variables = {
      TARGET_URL = "https://example.com" # リダイレクト先URL
    }
  }
}

# Lambda関数URLの有効化
resource "aws_lambda_function_url" "function_url" {
  function_name = aws_lambda_function.redirect_function.function_name

  # 認証不要で公開アクセスを許可
  authorization_type = "NONE"
  cors {
    allow_origins = ["*"]
  }
}

# Lambda関数URLのアクセス許可設定
resource "aws_lambda_permission" "allow_function_url" {
  statement_id  = "AllowPublicAccessToFunctionURL"
  action        = "lambda:InvokeFunctionUrl"
  function_name = aws_lambda_function.redirect_function.function_name
  principal     = "*"                   # 全てのユーザーにアクセス許可
  function_url_auth_type = "NONE"       # 認証不要で公開アクセス
}