# Project 3: Secure OIDC Terraform (S3 hardened)

provider "aws" {
  region = var.region
}

# -------- Primary bucket --------
resource "aws_s3_bucket" "secure" {
  bucket        = var.bucket_name
  force_destroy = false
  tags = { Project = "sre-showcase", Component = "project-3" }
}

# Versioning on primary
resource "aws_s3_bucket_versioning" "secure_v" {
  bucket = aws_s3_bucket.secure.id
  versioning_configuration { status = "Enabled" }
}

# -------- Log bucket (for access logs) --------
resource "aws_s3_bucket" "logs" {
  bucket        = "${var.bucket_name}-logs"
  force_destroy = false
  tags = { Project = "sre-showcase", Component = "project-3-logs" }

  # tfsec:ignore:aws-s3-enable-bucket-logging
  # Reason: avoid recursive logging on the log bucket
}

# Ownership controls (compatible with ACL-less accounts)
resource "aws_s3_bucket_ownership_controls" "logs_owner" {
  bucket = aws_s3_bucket.logs.id
  rule { object_ownership = "BucketOwnerPreferred" }
}

# Versioning on logs
resource "aws_s3_bucket_versioning" "logs_v" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration { status = "Enabled" }
}

# -------- KMS CMK for SSE --------
resource "aws_kms_key" "s3" {
  description             = "CMK for S3 encryption (Project 3)"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags = { Project = "sre-showcase" }
}

# SSE on primary (CMK)
resource "aws_s3_bucket_server_side_encryption_configuration" "secure_sse" {
  bucket = aws_s3_bucket.secure.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
  }
}

# SSE on logs (CMK)
resource "aws_s3_bucket_server_side_encryption_configuration" "logs_sse" {
  bucket = aws_s3_bucket.logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
  }
}

# -------- Public access blocks --------
resource "aws_s3_bucket_public_access_block" "secure_pab" {
  bucket                  = aws_s3_bucket.secure.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "logs_pab" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -------- Access logging from primary to logs --------
resource "aws_s3_bucket_logging" "secure_logging" {
  bucket        = aws_s3_bucket.secure.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "access/"
}
