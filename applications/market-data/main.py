import os
import json
import boto3
import logging
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from datetime import datetime

# Logging setup
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Market Data Ingestion Service",
    description="Consumes market data events from SQS and stores to DynamoDB",
    version="1.0.0"
)

# AWS clients — boto3 automatically uses IRSA credentials when running in EKS
AWS_REGION      = os.getenv("AWS_REGION", "ap-south-1")
SQS_QUEUE_URL   = os.getenv("SQS_QUEUE_URL", "")
DYNAMODB_TABLE  = os.getenv("DYNAMODB_TABLE", "fintech-market-data")

sqs      = boto3.client("sqs", region_name=AWS_REGION)
dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)
table    = dynamodb.Table(DYNAMODB_TABLE)


class MarketEvent(BaseModel):
    symbol: str
    price: float
    volume: int
    timestamp: str = None


@app.get("/health")
def health():
    """Health check — Kubernetes liveness and readiness probe hits this"""
    return {"status": "ok", "service": "market-data-ingestion"}


@app.get("/metrics-info")
def metrics_info():
    """Shows current queue depth — useful for debugging KEDA scaling"""
    try:
        response = sqs.get_queue_attributes(
            QueueUrl=SQS_QUEUE_URL,
            AttributeNames=["ApproximateNumberOfMessages"]
        )
        depth = response["Attributes"]["ApproximateNumberOfMessages"]
        return {"queue_depth": depth, "queue_url": SQS_QUEUE_URL}
    except Exception as e:
        logger.error(f"Could not get queue depth: {e}")
        return {"queue_depth": "unknown", "error": str(e)}


@app.post("/ingest")
def ingest_event(event: MarketEvent):
    """
    Manually ingest a market event.
    In production this is triggered by SQS — this endpoint is for testing.
    """
    try:
        if not event.timestamp:
            event.timestamp = datetime.utcnow().isoformat()

        table.put_item(Item={
            "symbol":    event.symbol,
            "timestamp": event.timestamp,
            "price":     str(event.price),
            "volume":    str(event.volume),
            "ingested_at": datetime.utcnow().isoformat()
        })

        logger.info(f"Stored market event: {event.symbol} @ {event.price}")
        return {"status": "stored", "symbol": event.symbol, "price": event.price}

    except Exception as e:
        logger.error(f"Failed to store event: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/process-queue")
def process_queue():
    """
    Polls SQS and processes all pending messages.
    In production KEDA scales this service based on queue depth.
    """
    processed = 0
    errors    = 0

    while True:
        response = sqs.receive_message(
            QueueUrl=SQS_QUEUE_URL,
            MaxNumberOfMessages=10,
            WaitTimeSeconds=1
        )

        messages = response.get("Messages", [])
        if not messages:
            break

        for msg in messages:
            try:
                body = json.loads(msg["Body"])

                table.put_item(Item={
                    "symbol":    body["symbol"],
                    "timestamp": body.get("timestamp", datetime.utcnow().isoformat()),
                    "price":     str(body["price"]),
                    "volume":    str(body.get("volume", 0)),
                    "source":    "sqs"
                })

                # Delete from queue only after successful processing
                sqs.delete_message(
                    QueueUrl=SQS_QUEUE_URL,
                    ReceiptHandle=msg["ReceiptHandle"]
                )
                processed += 1

            except Exception as e:
                logger.error(f"Failed to process message: {e}")
                errors += 1

    return {"processed": processed, "errors": errors}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)