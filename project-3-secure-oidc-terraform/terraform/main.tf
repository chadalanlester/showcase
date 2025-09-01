resource "aws_s3_bucket" "secure" {
  bucket        = var.bucket_name
  force_destroy = false

  tags = {
    Project   = "sre-showcase"
    Component = "project-3"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.secure.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "v" {
  bucket = aws_s3_bucket.secure.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "pab" {
  bucket                  = aws_s3_bucket.secure.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Customer managed KMS key for S3 SSE
resource "aws_kms_key" "s3" {
  description             = "KMS key for Project 3 S3 bucket encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags = { Project = "sre-showcase", Component = "project-3" }
}

# Access log bucket (separate, hardened)
resource "aws_s3_bucket" "logs" {
  bucket        = "${var.bucket_name}-logs"
  force_destroy = false
  tags = { Project = "sre-showcase", Component = "project-3-logs" }

  # tfsec:ignore:aws-s3-enable-bucket-logging
  # Reason: Do not enable logging on the log bucket to avoid recursive logging.
}

# Ownership controls (works with ACL-less buckets)
resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Versioning on log bucket
resource "aws_s3_bucket_versioning" "logs_v" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Public access block on log bucket
resource "aws_s3_bucket_public_access_block" "logs_pab" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Default SSE on log bucket using same CMK
resource "aws_s3_bucket_server_side_encryption_configuration" "logs_sse" {
  bucket = aws_s3_bucket.logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
  }
}

# (already present above) Default SSE on primary bucket with CMK
# resource "aws_s3_bucket_server_side_encryption_configuration" "sse" { ... }

# (already present above) Server access logging for primary bucket -> logs bucket
# resource "aws_s3_bucket_logging" "secure" { ... }
