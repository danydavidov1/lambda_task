output "lambda_version" {
  value = module.lambda_function.lambda_function_version
}

output "alias_arn" {
  value = aws_lambda_alias.prod_lambda_alias.arn
}

output "alias_invoke_arn" {
  value = aws_lambda_alias.prod_lambda_alias.invoke_arn
}