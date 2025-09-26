data "aws_caller_identity" "this" {}

resource "aws_s3_bucket" "incoming" {
  bucket        = "${var.project_name}-incoming-${data.aws_caller_identity.this.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.incoming.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "bucket_name" { value = aws_s3_bucket.incoming.bucket }
output "bucket_arn" { value = aws_s3_bucket.incoming.arn }
