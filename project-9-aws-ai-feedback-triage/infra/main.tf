module "s3" {
  source       = "./modules/s3"
  project_name = var.project_name
}

module "dynamodb" {
  source       = "./modules/dynamodb"
  project_name = var.project_name
}

module "monitoring" {
  source       = "./modules/monitoring"
  project_name = var.project_name
  alert_email  = var.alert_email
}

module "iam" {
  source        = "./modules/iam"
  project_name  = var.project_name
  s3_bucket_arn = module.s3.bucket_arn
  dynamodb_arn  = module.dynamodb.table_arn
}

module "lambda" {
  source           = "./modules/lambda"
  project_name     = var.project_name
  lambda_role_arn  = module.iam.lambda_role_arn
  dynamodb_table   = module.dynamodb.table_name
  s3_bucket_name   = module.s3.bucket_name
  s3_bucket_arn    = module.s3.bucket_arn
  alerts_topic_arn = module.monitoring.alerts_topic_arn
}

module "api" {
  source       = "./modules/api"
  project_name = var.project_name
  lambda_arn   = module.lambda.ingest_lambda_arn
}
