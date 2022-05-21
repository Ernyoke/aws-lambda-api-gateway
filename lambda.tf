resource "aws_lambda_function" "lambda" {
  function_name    = "api-gw-backend"
  handler          = "index.handler"
  memory_size      = 1024
  package_type     = "Zip"
  role             = aws_iam_role.lambda_role.arn
  runtime          = "nodejs14.x"
  filename         = "api-gw-backend.zip"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 60
  architectures    = ["arm64"]

  layers = [
    "arn:aws:lambda:${var.region}:580247275435:layer:LambdaInsightsExtension-Arm64:2" # https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Lambda-Insights-extension-versionsARM.html
  ]
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/api-gw-backend.zip"
  source_dir  = "${path.module}/api-gw-backend"
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # Allow execution from the 
  source_arn = "${aws_api_gateway_rest_api.api_gw.execution_arn}/*/*/*"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}