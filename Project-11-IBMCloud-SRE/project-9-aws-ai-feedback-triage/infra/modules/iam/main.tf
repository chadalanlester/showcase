data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${var.project_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

data "aws_iam_policy_document" "inline" {
  statement {
    sid = "Comprehend"
    actions = [
      "comprehend:DetectSentiment",
      "comprehend:DetectKeyPhrases",
      "comprehend:DetectEntities",
      "comprehend:DetectDominantLanguage",
    ]
    resources = ["*"]
  }

  statement {
    sid       = "DynamoDB"
    actions   = ["dynamodb:PutItem"]
    resources = [var.dynamodb_arn]
  }

  statement {
    sid       = "Logs"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }

  statement {
    sid       = "S3Read"
    actions   = ["s3:GetObject"]
    resources = ["${var.s3_bucket_arn}/*"]
  }

  # Keep simple to break circular deps. Tighten later if desired.
  statement {
    sid       = "SNSPublish"
    actions   = ["sns:Publish"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "inline" {
  name   = "${var.project_name}-lambda-inline"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.inline.json
}

output "lambda_role_arn" { value = aws_iam_role.lambda.arn }
