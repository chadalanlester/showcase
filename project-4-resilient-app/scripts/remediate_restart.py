#!/usr/bin/env python3
import json
import subprocess
import sys

NS   = sys.argv[1] if len(sys.argv) > 1 else "resilient"
DEP  = sys.argv[2] if len(sys.argv) > 2 else "trivia-api"
TH_P = int(sys.argv[3]) if len(sys.argv) > 3 else 50  # percent available threshold

def k(cmd):
    return subprocess.check_output(cmd, text=True)

try:
    j = json.loads(k(["kubectl","-n",NS,"get","deploy",DEP,"-o","json"]))
except subprocess.CalledProcessError as e:
    print(f"Error: {e}", file=sys.stderr); sys.exit(1)

desired = int(j["spec"]["replicas"])
avail   = int(j["status"].get("availableReplicas", 0))
pct     = int((avail * 100) / max(desired,1))

print(f"desired={desired} available={avail} pct={pct}% threshold={TH_P}%")

if pct < TH_P:
    subprocess.check_call(["kubectl","-n",NS,"rollout","restart","deploy",DEP])
    print("Action: rollout restart triggered")
else:
    print("Action: none (healthy)")
