#!/usr/bin/env python3
import sys, requests

if len(sys.argv) < 2:
    print("usage: check_slo.py <prometheus_url> [slo]")
    sys.exit(2)

prom = sys.argv[1].rstrip("/")
slo  = float(sys.argv[2]) if len(sys.argv) > 2 else 0.99

# Simple availability proxy: success rate over 5m for our service.
# Adjust label filters to your metrics if needed.
query = (
  'sum(rate(http_requests_total{job="trivia-api",status!~"5.."}[5m])) / '
  'sum(rate(http_requests_total{job="trivia-api"}[5m]))'
)

try:
    r = requests.get(f"{prom}/api/v1/query", params={"query": query}, timeout=5)
    r.raise_for_status()
    data = r.json()
    results = data.get("data", {}).get("result", [])
    val = float(results[0]["value"][1]) if results else 0.0
except Exception as e:
    print(f"error querying prometheus: {e}")
    sys.exit(2)

print(f"availability={val:.5f} slo={slo:.2f}")
sys.exit(0 if val >= slo else 1)
