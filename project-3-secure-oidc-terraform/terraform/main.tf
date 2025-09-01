# Main infrastructure for Project 3: Secure OIDC Terraform

provider "aws" {
  region = var.region
}

# --- Primary S3 Bucket ---
resource "aws_s3_bucket" "secure" {
  bucket        = var.bucket_name
  force_destroy = false

  tags = {
    Project   = "sre-showcase"
    Component = "project-3"
  }
}

# --- Logs bucket (for access logging) ---
resource "aws_s3_bucket" "logs" {
  bucket        = "${var.bucket_name}-logs"
  force_destroy = false

  tags = {
    Project   = "sre-showcase"
    Component = "project-3-logs"
  }

  # tfsec:ignore:aws-s3-enable-bucket-logging
  # Reason: Do not enable logging on the log bucket to avoid recursive logging.
}

# --- Logging from primary bucket into logs bucket ---
resource "aws_s3_bucket_logging" "secure" {
  bucket        = aws_s3_bucket.secure.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "access/"
}

# --- KMS Key for encryption ---
resource "aws_kms_key" "s3" {
  description             = "CMK for S3 bucket encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Project = "sre-showcase"
  }
}

# --- SSE config for primary bucket with CMK ---
resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.secure.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
  }
}

# --- Public access blocks ---
resource "aws_s3_bucket_public_access_block" "secure" {
  bucket                  = aws_s3_bucket.secure.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
