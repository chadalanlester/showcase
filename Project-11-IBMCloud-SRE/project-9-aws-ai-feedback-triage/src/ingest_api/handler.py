import json, uuid
from common.util import analyze, persist, maybe_alert

def lambda_handler(event, context):
    body = json.loads(event.get("body") or "{}")
    text = body.get("text")
    customer_id = body.get("customer_id", "anonymous")
    channel = body.get("channel", "api")
    if not text or not isinstance(text, str):
        return {"statusCode": 400, "body": json.dumps({"error": "text required"})}
    analysis = analyze(text)
    item = {
        "pk": f"cust#{customer_id}",
        "sk": f"msg#{uuid.uuid4().hex}",
        "customer_id": customer_id,
        "channel": channel,
        "payload": {"text": text},
        "analysis": analysis,
    }
    persist(item); maybe_alert(item)
    return {"statusCode": 200, "body": json.dumps({"ok": True, "analysis": analysis})}
