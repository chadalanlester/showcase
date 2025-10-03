locals { name = var.project_name }

# Ensure build dir exists at infra/build
resource "null_resource" "prepare_build" {
  provisioner "local-exec" {
    command = "mkdir -p ${path.root}/build"
  }
}

# Package entire src so shared 'common' is included
data "archive_file" "ingest_zip" {
  type        = "zip"
  source_dir  = "${path.root}/../src"
  output_path = "${path.root}/build/ingest_api.zip"
  depends_on  = [null_resource.prepare_build]
}

data "archive_file" "s3_zip" {
  type        = "zip"
  source_dir  = "${path.root}/../src"
  output_path = "${path.root}/build/s3_batch.zip"
  depends_on  = [null_resource.prepare_build]
}

resource "aws_lambda_function" "ingest" {
  function_name    = "${local.name}-ingest-api"
  role             = var.lambda_role_arn
  handler          = "ingest_api/handler.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.ingest_zip.output_path
  source_code_hash = data.archive_file.ingest_zip.output_base64sha256
  timeout          = 10
  environment {
    variables = {
      TABLE_NAME   = var.dynamodb_table
      ALERTS_TOPIC = var.alerts_topic_arn
    }
  }
}

resource "aws_lambda_function" "s3_batch" {
  function_name    = "${local.name}-s3-batch"
  role             = var.lambda_role_arn
  handler          = "s3_batch/handler.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.s3_zip.output_path
  source_code_hash = data.archive_file.s3_zip.output_base64sha256
  timeout          = 30
  environment {
    variables = {
      TABLE_NAME   = var.dynamodb_table
      ALERTS_TOPIC = var.alerts_topic_arn
    }
  }
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_batch.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_bucket_arn
}

resource "aws_s3_bucket_notification" "this" {
  bucket = var.s3_bucket_name
  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_batch.arn
    events              = ["s3:ObjectCreated:Put"]
  }
  depends_on = [aws_lambda_permission.allow_s3]
}

output "ingest_lambda_arn" { value = aws_lambda_function.ingest.arn }
output "s3_lambda_arn" { value = aws_lambda_function.s3_batch.arn }


# Alarms created unconditionally. Action is optional if alerts_topic_arn is empty.
resource "aws_cloudwatch_metric_alarm" "ingest_errors" {
  alarm_name          = "${local.name}-ingest-errors"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  dimensions          = { FunctionName = aws_lambda_function.ingest.function_name }
  alarm_actions       = var.alerts_topic_arn != "" ? [var.alerts_topic_arn] : []
}

resource "aws_cloudwatch_metric_alarm" "s3_errors" {
  alarm_name          = "${local.name}-s3batch-errors"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  dimensions          = { FunctionName = aws_lambda_function.s3_batch.function_name }
  alarm_actions       = var.alerts_topic_arn != "" ? [var.alerts_topic_arn] : []
}

data "aws_region" "current" {}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        "type" : "metric",
        "properties" : {
          "title" : "Ingest Invocations",
          "view" : "timeSeries",
          "stat" : "Sum",
          "period" : 300,
          "region" : data.aws_region.current.name,
          "metrics" : [
            ["AWS/Lambda", "Invocations", "FunctionName", aws_lambda_function.ingest.function_name]
          ]
        }
      },
      {
        "type" : "metric",
        "properties" : {
          "title" : "S3 Batch Invocations",
          "view" : "timeSeries",
          "stat" : "Sum",
          "period" : 300,
          "region" : data.aws_region.current.name,
          "metrics" : [
            ["AWS/Lambda", "Invocations", "FunctionName", aws_lambda_function.s3_batch.function_name]
          ]
        }
      }
    ]
  })
}
