import json
)
actions.append("put_public_access_block")

# 2) Remove bucket policy if present
try:
s3.get_bucket_policy(Bucket=bucket)
s3.delete_bucket_policy(Bucket=bucket)
actions.append("delete_bucket_policy")
except Exception:
pass

# 3) Optional: set ACL private (idempotent)
try:
s3.put_bucket_acl(Bucket=bucket, ACL="private")
actions.append("put_bucket_acl_private")
except Exception:
pass

return {"bucket": bucket, "remediation_actions": actions}


def _notify(webhook_url: str, body: Dict[str, Any]):
try:
requests.post(webhook_url, json=body, timeout=6)
except Exception as e:
log.warning("notify failed: %s", e)

# ---- action entrypoint -----------------------------------------------------

def main(params: Dict[str, Any]) -> Dict[str, Any]:
"""IBM Cloud Function web action entrypoint."""
# Authn for web action if using require-whisk-auth is enforced by platform.

# Inputs via default params / env
sm_url = os.getenv("SECRETS_MANAGER_URL") or params.get("SECRETS_MANAGER_URL")
sm_api_key = os.getenv("SECRETS_MANAGER_API_KEY") or params.get("SECRETS_MANAGER_API_KEY")
sm_hmac_id = os.getenv("SM_HMAC_SECRET_ID") or params.get("SM_HMAC_SECRET_ID")
sm_webhook_id = os.getenv("SM_WEBHOOK_SECRET_ID") or params.get("SM_WEBHOOK_SECRET_ID")

if not all([sm_url, sm_api_key, sm_hmac_id, sm_webhook_id]):
return {"statusCode": 500, "body": {"error": "missing secrets manager config"}}

bucket = _find_bucket_name(params) or params.get("bucket")
if not bucket:
# accept explicit override from custom template
bucket = params.get("bucket_name")

sm = _get_sm_client(sm_api_key, sm_url)
hmac = _get_arbitrary_secret(sm, sm_hmac_id)
webhook_url = _get_arbitrary_secret(sm, sm_webhook_id)
if webhook_url.startswith("{"):
# allow KV JSON like {"url": "https://..."}
try:
webhook_url = json.loads(webhook_url).get("url", "")
except Exception:
pass

s3 = _get_cos_client(hmac)

result = {"activation": "start", "bucket": bucket}

if bucket:
try:
rem = _enforce_private(s3, bucket)
result.update(rem)
result["status"] = "remediated"
except Exception as e:
log.exception("remediation failed")
result.update({"status": "error", "error": str(e)})
else:
result.update({"status": "skipped", "reason": "bucket not found in payload"})

_notify(
webhook_url,
{
"tool": "serverless-automation-toolkit",
"event_type": "cos_public_access_auto_revert",
"result": result,
"raw_event_excerpt": {k: params.get(k) for k in list(params.keys())[:8]},
},
)

return {"statusCode": 200, "body": result}
