from flask import Flask, jsonify
import random

app = Flask(__name__)

TRIVIA = [
    "SRE reduces toil with automation.",
    "Golden Signals: latency, traffic, errors, saturation.",
    "HPA scales on CPU or custom metrics.",
    "Liveness restarts; readiness gates traffic.",
    "Argo CD uses Kubernetes CRDs."
]

@app.get("/")
def index():
    return "Welcome to the Resilient Trivia API! Try /trivia, /healthz, /livez"

@app.get("/trivia")
def trivia():
    return jsonify({"fact": random.choice(TRIVIA)})

@app.get("/healthz")
def healthz():
    return "ok", 200

@app.get("/livez")
def livez():
    return "ok", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
