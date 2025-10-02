from fastapi import FastAPI
from pydantic import BaseModel
import os, time
import uvicorn

app = FastAPI(title="Transaction API", version="1.0.0")
start_time = time.time()

class Transaction(BaseModel):
    id: str
    amount: float
    currency: str = "USD"

@app.get("/healthz")
def healthz():
    return {"status":"ok","uptime_seconds":int(time.time()-start_time)}

@app.post("/transactions")
def create_txn(txn: Transaction):
    return {"ok": True, **txn.model_dump()}

@app.get("/transactions/{txn_id}")
def get_txn(txn_id: str):
    return {"id": txn_id, "status": "settled"}

if __name__ == "__main__":
    port = int(os.getenv("PORT", "8080"))
    uvicorn.run(app, host="0.0.0.0", port=port)
