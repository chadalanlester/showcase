# Project 3 — Secure GitHub OIDC Terraform Pipeline (AWS)

**Goal:** Run Terraform from GitHub Actions using AWS **OIDC** (no long-lived keys) with security checks, deploying a compliant S3 bucket (encrypted, versioned, public access blocked).

## Steps

### A) Create the AWS IAM role for OIDC
1. In AWS IAM → Roles → **Create role** → **Web identity**
   - Identity provider: *GitHub* (or add `token.actions.githubusercontent.com` OIDC provider if missing)
   - Audience: `sts.amazonaws.com`
2. Trust policy (replace `OWNER` and `REPO`):
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com" },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": { "token.actions.githubusercontent.com:aud": "sts.amazonaws.com" },
      "StringLike": { "token.actions.githubusercontent.com:sub": "repo:OWNER/REPO:*" }
    }
  }]
}

3. Permissions policy for the role (least privilege for S3 bucket create/update):
{
  "Version":"2012-10-17",
  "Statement": [{
    "Effect":"Allow",
    "Action":[ "s3:*" ],
    "Resource":"*"
  }]
}

4. Save the Role ARN → add to repo secret PROJ3_OIDC_ROLE_ARN.
