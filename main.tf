provider "aws" {
  region = "us-east-1" 
}


resource "aws_s3_bucket" "buck-for-task3" {
  bucket = "buck-for-task3" 
}



resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_s3_exec_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}


resource "aws_iam_policy" "lambda_s3_policy" {
  name        = "lambda_s3_policy"
  description = "Policy for Lambda to access S3 and CloudWatch"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::buck-for-task3/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "lambda_s3_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}


resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/csv_reader_lambda"
  retention_in_days = 7
}


resource "aws_lambda_function" "csv_reader_lambda" {
  function_name    = "csv_reader_lambda"
  role            = aws_iam_role.lambda_exec_role.arn
  runtime         = "python3.8"
  handler         = "lambda_function.lambda_handler"
  filename        = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")
  
  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.csv_bucket.id
    }
  }
}



