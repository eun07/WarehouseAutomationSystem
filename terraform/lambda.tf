terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.63.0"
    }
  }
}
provider "aws" {
  region = "ap-northeast-2"
}

module "lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "my-lambda-existing-package-local"
  description   = "My awesome lambda function"
  handler       = "handler.handler"
  runtime       = "nodejs14.x"

  # local_existing_package = "${path.module}/sales-api.zip"
  source_path = "./sales-api/"


  environment_variables ={
    HOSTNAME="poject3-db.cpajpop7ewnt.ap-northeast-2.rds.amazonaws.com"
    USERNAME=var.user
    PASSWORD=var.password
    DATABASE=var.database
    TOPIC_ARN=aws_sns_topic.stock_update.arn
  }
 
  # policy = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"

    tags = {
    Name = "sales-api-lambda-tf"
  }

}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = module.lambda.lambda_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "dev-http"
  description   = "My awesome HTTP API Gateway"
  protocol_type = "HTTP"
  create_api_domain_name           = false

integrations = {
  "$default" = {
    lambda_arn = module.lambda.lambda_function_arn
    payload_format_version = "2.0"
  }
}
  tags={
    Name="sales-api-gateway"
  }
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "my-lambda-existing-package-local"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*"
}

#Sales-api Lambda
data "archive_file" "stock_lambda" {
  type        = "zip"
  source_dir = "${path.module}/stock-lambda"
  output_path = "${path.module}/stock-lambda-func.zip"
}



module "stock_lambda" {
  source = "terraform-aws-modules/lambda/aws"
  version = "3.3.1"

  function_name = "stock_lambda"
  description   = "My awesome lambda function"
  handler       = "handler.consumer"
  runtime       = "nodejs14.x"
  create_package      = false
  local_existing_package = "${data.archive_file.stock_lambda.output_path}"
  environment_variables = {
    CALLBACKURL = "${module.api_gateway_increase.apigatewayv2_api_api_endpoint}/product/donut"
  }
  # source_path = "./stock-lambda"
}

resource "aws_iam_role_policy_attachment" "stock_lambda_policy" {
  role       = module.stock_lambda.lambda_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

resource "aws_lambda_event_source_mapping" "example" {
  event_source_arn = aws_sqs_queue.terraform_queue.arn
  function_name    = module.stock_lambda.lambda_function_name
}
#stock-lambda


module "increase_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "stock-increase-lambda"
  description   = "My awesome lambda function"
  handler       = "handler.handler"
  runtime       = "nodejs14.x"

  source_path = "./stock-increase-lambda"


  environment_variables ={
    HOSTNAME="poject3-db.cpajpop7ewnt.ap-northeast-2.rds.amazonaws.com"
    USERNAME=var.user
    PASSWORD=var.password
    DATABASE=var.database
  }
 
}

module "api_gateway_increase" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "increase-lambda-gw"
  description   = "My awesome HTTP API Gateway"
  protocol_type = "HTTP"
  create_api_domain_name           = false

integrations = {
  "$default" = {
    lambda_arn = module.increase_lambda.lambda_function_arn
    payload_format_version = "2.0"
  }
}
  tags={
    Name="increase-lambda-gateway"
  }
}

resource "aws_lambda_permission" "api_gw_in" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.increase_lambda.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${module.api_gateway_increase.apigatewayv2_api_execution_arn}/*/*"
}

#stock-increase-lambda

#----------test
# resource "aws_iam_role" "iam_for_lambda" {
#   name = "iam_for_lambda"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "lambda.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF
# }


# resource "aws_lambda_function" "stock_lambda" {

#   filename = "${data.archive_file.stock_lambda.output_path}"
#   source_code_hash = "${data.archive_file.stock_lambda.output_base64sha256}"
  
#   function_name = "stock-lambda-function"
#   handler       = "handler.consumer"
#   role          = aws_iam_role.iam_for_lambda.arn

#   # filename      = "stock-lambda.zip"
#   # source_code_hash = "${base64sha256(file("./stock-lambda/handler.js"))}"
#   runtime = "nodejs14.x"

# }

# resource "aws_iam_role_policy_attachment" "stock_lambda_policy2" {
#   role       = aws_iam_role.iam_for_lambda.name
#   policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
# }
# resource "aws_iam_role_policy_attachment" "stock_lambda_policy" {
#   role       = aws_iam_role.iam_for_lambda.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
# }

# resource "aws_lambda_event_source_mapping" "example" {
#   event_source_arn = aws_sqs_queue.terraform_queue.arn
#   function_name    = aws_lambda_function.stock_lambda.arn
# }


