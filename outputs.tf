output "invoke_url" {
  description = "You can ivoke the Lambda function using the following URL:"
  value       = "${aws_api_gateway_stage.dev_stage.invoke_url}${aws_api_gateway_resource.api_resource.path}"
}