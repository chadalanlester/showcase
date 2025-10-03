output "api_gateway_url" { value = module.api.api_invoke_url }
output "s3_bucket_name" { value = module.s3.bucket_name }
output "dynamodb_table" { value = module.dynamodb.table_name }
output "alerts_topic_arn" { value = module.monitoring.alerts_topic_arn }
