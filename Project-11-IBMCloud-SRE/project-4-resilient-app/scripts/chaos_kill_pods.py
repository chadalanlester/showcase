#!/usr/bin/env python3
import subprocess, sys, random

ns  = sys.argv[1] if len(sys.argv) > 1 else "resilient"
app = sys.argv[2] if len(sys.argv) > 2 else "trivia-api"

def sh(*args):
    return subprocess.check_output(args, text=True).strip()

try:
    pods = sh("kubectl","-n",ns,"get","pods","-l",f"app={app}","-o","name").splitlines()
except subprocess.CalledProcessError as e:
    print(f"kubectl error: {e}"); sys.exit(1)

if not pods:
    print(f"No pods found in {ns} namespace for app={app}."); sys.exit(1)

victim = random.choice(pods).split("/",1)[1]
subprocess.check_call(["kubectl","-n",ns,"delete","pod",victim,"--grace-period=0","--force"])
print(f"Killed pod: {victim} in ns={ns}")
