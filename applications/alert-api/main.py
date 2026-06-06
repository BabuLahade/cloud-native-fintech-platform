import os
import boto3
import logging
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from datetime import datetime
from typing import Optional

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# APP_VERSION is injected via Kubernetes Deployment env var
# This lets you see which version (blue or green) is serving during INC-007
APP_VERSION = os.getenv("APP_VERSION", "1.0.0")

app = FastAPI(
    title="Alert API Service",
    description="Exposes trading alerts — uses Argo Rollouts blue-green deployment",
    version=APP_VERSION
)

AWS_REGION     = os.getenv("AWS_REGION", "ap-south-1")
DYNAMODB_TABLE = os.getenv("DYNAMODB_TABLE", "fintech-alerts")

dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)
table    = dynamodb.Table(DYNAMODB_TABLE)


class Alert(BaseModel):
    alert_id:   str
    symbol:     str
    alert_type: str  # PRICE_TARGET, STOP_LOSS, VOLUME_SPIKE
    message:    str
    severity:   str  # LOW, MEDIUM, HIGH, CRITICAL
    timestamp:  Optional[str] = None


@app.get("/health")
def health():
    """
    Health check endpoint.
    Also returns APP_VERSION — during INC-007 you can see
    which version (blue or green) is responding.
    """
    return {
        "status":  "ok",
        "service": "alert-api",
        "version": APP_VERSION
    }


@app.post("/alerts")
def create_alert(alert: Alert):
    """Create a new trading alert"""
    try:
        if not alert.timestamp:
            alert.timestamp = datetime.utcnow().isoformat()

        table.put_item(Item={
            "alert_id":   alert.alert_id,
            "symbol":     alert.symbol,
            "alert_type": alert.alert_type,
            "message":    alert.message,
            "severity":   alert.severity,
            "timestamp":  alert.timestamp,
            "version":    APP_VERSION
        })

        logger.info(f"Created alert: {alert.alert_id} for {alert.symbol}")
        return {"status": "created", "alert_id": alert.alert_id}

    except Exception as e:
        logger.error(f"Failed to create alert: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/alerts/{alert_id}")
def get_alert(alert_id: str):
    """Get a specific alert by ID"""
    try:
        response = table.get_item(Key={"alert_id": alert_id})
        item     = response.get("Item")

        if not item:
            raise HTTPException(status_code=404, detail="Alert not found")

        return item

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to fetch alert: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/alerts")
def list_alerts():
    """List all alerts — limited to 50 for safety"""
    try:
        response = table.scan(Limit=50)
        items    = response.get("Items", [])
        return {
            "alerts":  items,
            "count":   len(items),
            "version": APP_VERSION
        }

    except Exception as e:
        logger.error(f"Failed to list alerts: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/version")
def version():
    """
    Returns the current version.
    During INC-007 blue-green test — curl this repeatedly
    to confirm only one version is serving at any time.
    """
    return {"version": APP_VERSION, "timestamp": datetime.utcnow().isoformat()}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)