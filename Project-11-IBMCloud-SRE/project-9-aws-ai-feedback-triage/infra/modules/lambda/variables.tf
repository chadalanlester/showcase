variable "project_name" { type = string }
variable "lambda_role_arn" { type = string }
variable "dynamodb_table" { type = string }
variable "s3_bucket_name" { type = string }
variable "s3_bucket_arn" { type = string }
variable "alerts_topic_arn" {
  type    = string
  default = ""
}
