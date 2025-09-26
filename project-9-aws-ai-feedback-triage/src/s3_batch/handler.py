import csv, io, uuid, boto3
from common.util import analyze, persist, maybe_alert
s3 = boto3.client("s3")

def lambda_handler(event, context):
    for rec in event.get("Records", []):
        b = rec["s3"]["bucket"]["name"]; k = rec["s3"]["object"]["key"]
        obj = s3.get_object(Bucket=b, Key=k)
        data = obj["Body"].read()
        reader = csv.DictReader(io.StringIO(data.decode("utf-8")))
        for row in reader:
            text = (row.get("text") or "").strip()
            if not text: continue
            customer_id = row.get("customer_id", "anonymous")
            channel = row.get("channel", "csv")
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
    return {"statusCode": 200}
