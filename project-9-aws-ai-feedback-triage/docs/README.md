# AI Feedback Triage

A production-style reference project that ingests customer feedback via API or S3 (CSV), analyzes sentiment and key phrases with Amazon Comprehend, and stores results in DynamoDB. Includes monitoring, alerting, and IaC with Terraform.

## Deploy

```bash
make bootstrap
make deploy ALERT_EMAIL="you@example.com"
make outputs
```

## Test

```bash
make test-api
make seed-csv
make query-dynamodb
make sns-subs
```

## Teardown

```bash
cd infra && make destroy
```

## Data model (DynamoDB)

- **pk** = `cust#<customer_id>`
- **sk** = `msg#<uuid>`
- **channel** ∈ {api,csv}
- **sentiment** = POSITIVE|NEGATIVE|NEUTRAL|MIXED
- **analysis** = JSON (lang, scores, key_phrases, entities)
- **payload** = original text
- **created_at** = ISO8601 UTC timestamp

## SRE notes

- **Alarms**: `Errors ≥ 1` on both Lambdas → SNS email.
- **Dashboard**: Lambda invocations time-series (per function).
- **Logs**:  
  `/aws/lambda/<project>-ingest-api`  
  `/aws/lambda/<project>-s3-batch`

## Cost guardrails (Free Tier)

- Lambda < 1M requests/month
- DynamoDB `PAY_PER_REQUEST`
- S3 single bucket, no versioning
- SNS standard (email)
- No Kinesis streams, Step Functions, or KMS CMKs

## Portfolio highlights

- **Production-style Terraform modules** with outputs, variables, and clean state.
- **Dual ingestion paths** (API and S3 CSV).
- **Observability**: alarms, dashboards, structured logging.
- **Operational realism**: PK/SK design, raw + derived storage, alert wiring.
- Fits AWS **Free Tier** but demonstrates real enterprise architecture.
"""

