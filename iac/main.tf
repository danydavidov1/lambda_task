resource "random_string" "s3_suffix" {
  length  = 12
  special = false
  upper = false
  numeric = false
}

resource "aws_s3_bucket" "s3" {
  bucket = "${var.project_name}-${random_string.s3_suffix.result}"
  force_destroy = true
}

module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"
  version = "6.5.0"

  function_name = "lambda-${var.project_name}"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  publish       = true

  source_path = "../lambda_code"

  store_on_s3 = true
  s3_bucket   = aws_s3_bucket.s3.id
  
  environment_variables = {
    URL_PATH = var.url_path
  }
}

resource "aws_lambda_alias" "prod_lambda_alias" {
  name             = "prod"
  description      = "prod version"
  function_name    = module.lambda_function.lambda_function_arn
  function_version = module.lambda_function.lambda_function_version
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_alias.prod_lambda_alias.arn
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.lab_api_gw.execution_arn}/*/*"
}

resource "aws_api_gateway_rest_api" "lab_api_gw" {
  name        = var.project_name
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.lab_api_gw.id
  parent_id   = aws_api_gateway_rest_api.lab_api_gw.root_resource_id
  path_part   = var.url_path
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.lab_api_gw.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.lab_api_gw.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_alias.prod_lambda_alias.invoke_arn
}



resource "aws_api_gateway_deployment" "prod" {
  depends_on = [ aws_api_gateway_integration.lambda] 

  rest_api_id = "${aws_api_gateway_rest_api.lab_api_gw.id}"
    triggers = {
        redeployment = sha1(jsonencode(aws_api_gateway_rest_api.lab_api_gw.body))
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.prod.id
  rest_api_id   = aws_api_gateway_rest_api.lab_api_gw.id
  stage_name    = "prod"
}