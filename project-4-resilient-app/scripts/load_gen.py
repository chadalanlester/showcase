#!/usr/bin/env python3
import os, time, threading, requests, sys

if len(sys.argv) < 2:
    print("usage: load_gen.py <url> [SECONDS] [CLIENTS]")
    sys.exit(2)

url     = sys.argv[1]
dur     = int(sys.argv[2]) if len(sys.argv) > 2 else int(os.getenv("DURATION", "120"))
clients = int(sys.argv[3]) if len(sys.argv) > 3 else int(os.getenv("CLIENTS", "50"))

def worker():
    end = time.time() + dur
    s = requests.Session()
    while time.time() < end:
        try:
            s.get(url, timeout=2)
        except Exception:
            pass

threads = [threading.Thread(target=worker, daemon=True) for _ in range(clients)]
[t.start() for t in threads]
[t.join() for t in threads]
print(f"Load complete: {clients} clients for {dur}s -> {url}")
