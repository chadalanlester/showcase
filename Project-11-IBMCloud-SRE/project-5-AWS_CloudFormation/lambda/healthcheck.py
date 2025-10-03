"""
HealthCheck Lambda: EC2 status + optional HTTP check.
Simple auto-remediation using reboot. Free-tier friendly.
"""
import json
import os
import time
import urllib.request

import boto3


EC2 = boto3.client("ec2")
SNS_ARN = os.getenv("SNS_TOPIC_ARN")
INSTANCE_ID = os.getenv("INSTANCE_ID")
CHECK_HTTP = os.getenv("CHECK_HTTP", "true").lower() == "true"
HTTP_PATH = os.getenv("HTTP_PATH", "/")


def _public_ip(instance_id: str) -> str | None:
    for r in EC2.describe_instances(InstanceIds=[instance_id])["Reservations"]:
        for i in r["Instances"]:
            return i.get("PublicIpAddress")
    return None


def _status_checks(instance_id: str) -> dict:
    resp = EC2.describe_instance_status(
        InstanceIds=[instance_id],
        IncludeAllInstances=True,
    )
    if not resp["InstanceStatuses"]:
        return {
            "InstanceStatus": "unknown",
            "SystemStatus": "unknown",
            "State": "unknown",
        }
    st = resp["InstanceStatuses"][0]
    return {
        "InstanceStatus": st["InstanceStatus"]["Status"],
        "SystemStatus": st["SystemStatus"]["Status"],
        "State": st["InstanceState"]["Name"],
    }


def _http_ok(ip: str, path: str) -> bool:
    try:
        with urllib.request.urlopen(f"http://{ip}{path}", timeout=5) as r:
            return r.status == 200
    except Exception:
        return False


def _notify(subject: str, msg: str) -> None:
    boto3.client("sns").publish(TopicArn=SNS_ARN, Subject=subject, Message=msg)


def _auto_remediate(instance_id: str, ip: str | None) -> None:
    _notify("Auto-remediation starting", f"Rebooting {instance_id} ({ip})")
    EC2.reboot_instances(InstanceIds=[instance_id])


def lambda_handler(event, context):
    st = _status_checks(INSTANCE_ID)
    ip = _public_ip(INSTANCE_ID)
    http_ok = _http_ok(ip, HTTP_PATH) if (CHECK_HTTP and ip) else None
    needs_action = (CHECK_HTTP and http_ok is False) or (st.get("InstanceStatus") != "ok")

    summary = {
        "instance": INSTANCE_ID,
        "ip": ip,
        "status": st,
        "http_ok": http_ok,
        "timestamp": int(time.time()),
    }

    if needs_action:
        _notify("HealthCheck failed", json.dumps(summary, indent=2))
        _auto_remediate(INSTANCE_ID, ip)

    return summary
