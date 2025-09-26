import os, json, boto3
from datetime import datetime, timezone
TABLE_NAME = os.environ["TABLE_NAME"]
ALERTS_TOPIC = os.environ.get("ALERTS_TOPIC")
ddb = boto3.client("dynamodb")
comp = boto3.client("comprehend")
sns = boto3.client("sns") if ALERTS_TOPIC else None
NEGATIVE_LABELS = {"NEGATIVE", "MIXED"}

def analyze(text: str, lang_hint: str | None = None):
    text = text.strip()[:4500]
    lang = lang_hint or comp.detect_dominant_language(Text=text)["Languages"][0]["LanguageCode"]
    sent = comp.detect_sentiment(Text=text, LanguageCode=lang)
    ents = comp.detect_entities(Text=text, LanguageCode=lang)
    keys = comp.detect_key_phrases(Text=text, LanguageCode=lang)
    return {
        "lang": lang,
        "sentiment": sent["Sentiment"],
        "sentiment_scores": sent["SentimentScore"],
        "entities": ents["Entities"],
        "key_phrases": keys["KeyPhrases"],
    }

def persist(item: dict):
    now = datetime.now(timezone.utc).isoformat()
    ddb.put_item(
        TableName=TABLE_NAME,
        Item={
            "pk": {"S": item["pk"]},
            "sk": {"S": item["sk"]},
            "channel": {"S": item.get("channel", "api")},
            "created_at": {"S": now},
            "payload": {"S": json.dumps(item["payload"])},
            "analysis": {"S": json.dumps(item["analysis"])},
            "sentiment": {"S": item["analysis"]["sentiment"]},
        },
    )

def maybe_alert(item: dict):
    if not sns:
        return
    label = item["analysis"]["sentiment"]
    if label in NEGATIVE_LABELS and item["analysis"]["sentiment_scores"]["Negative"] >= 0.6:
        msg = {
            "customer_id": item.get("customer_id"),
            "text": item["payload"]["text"][:280],
            "sentiment": label,
            "score": item["analysis"]["sentiment_scores"],
        }
        sns.publish(TopicArn=ALERTS_TOPIC, Message=json.dumps(msg), Subject="Negative feedback detected")
