import os
import boto3
import logging
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from datetime import datetime
from typing import List

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Portfolio Calculator Service",
    description="Calculates portfolio value and P&L",
    version="1.0.0"
)

AWS_REGION     = os.getenv("AWS_REGION", "ap-south-1")
DYNAMODB_TABLE = os.getenv("DYNAMODB_TABLE", "fintech-portfolios")

dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)
table    = dynamodb.Table(DYNAMODB_TABLE)


class Position(BaseModel):
    symbol:   str
    quantity: float
    avg_cost: float
    price:    float


class Portfolio(BaseModel):
    portfolio_id: str
    owner:        str
    positions:    List[Position] = []


@app.get("/health")
def health():
    return {"status": "ok", "service": "portfolio-calculator"}


@app.post("/portfolio")
def create_portfolio(portfolio: Portfolio):
    """Create or update a portfolio"""
    try:
        table.put_item(Item={
            "portfolio_id": portfolio.portfolio_id,
            "owner":        portfolio.owner,
            "positions":    [p.dict() for p in portfolio.positions],
            "created_at":   datetime.utcnow().isoformat()
        })
        return {"status": "created", "portfolio_id": portfolio.portfolio_id}

    except Exception as e:
        logger.error(f"Failed to create portfolio: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/portfolio/{portfolio_id}")
def get_portfolio(portfolio_id: str):
    """Fetch raw portfolio data"""
    try:
        response = table.get_item(Key={"portfolio_id": portfolio_id})
        item     = response.get("Item")

        if not item:
            raise HTTPException(status_code=404, detail="Portfolio not found")

        return item

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to fetch portfolio: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/portfolio/{portfolio_id}/calculate")
def calculate_portfolio(portfolio_id: str):
    """
    Calculate current portfolio value and P&L.
    This is the core business logic of this service.
    """
    try:
        response = table.get_item(Key={"portfolio_id": portfolio_id})
        item     = response.get("Item")

        if not item:
            raise HTTPException(status_code=404, detail="Portfolio not found")

        positions   = item.get("positions", [])
        total_value = 0.0
        total_cost  = 0.0

        position_results = []
        for pos in positions:
            quantity    = float(pos["quantity"])
            avg_cost    = float(pos["avg_cost"])
            price       = float(pos["price"])
            value       = quantity * price
            cost        = quantity * avg_cost
            pnl         = value - cost
            pnl_percent = (pnl / cost * 100) if cost > 0 else 0

            total_value += value
            total_cost  += cost

            position_results.append({
                "symbol":      pos["symbol"],
                "quantity":    quantity,
                "avg_cost":    avg_cost,
                "price":       price,
                "value":       round(value, 2),
                "pnl":         round(pnl, 2),
                "pnl_percent": round(pnl_percent, 2)
            })

        total_pnl     = total_value - total_cost
        total_pnl_pct = (total_pnl / total_cost * 100) if total_cost > 0 else 0

        result = {
            "portfolio_id":   portfolio_id,
            "owner":          item.get("owner"),
            "total_value":    round(total_value, 2),
            "total_cost":     round(total_cost, 2),
            "total_pnl":      round(total_pnl, 2),
            "total_pnl_pct":  round(total_pnl_pct, 2),
            "positions":      position_results,
            "calculated_at":  datetime.utcnow().isoformat()
        }

        # Write calculation result back to DynamoDB
        table.update_item(
            Key={"portfolio_id": portfolio_id},
            UpdateExpression="SET last_calculated = :t, last_pnl = :p",
            ExpressionAttributeValues={
                ":t": datetime.utcnow().isoformat(),
                ":p": str(round(total_pnl, 2))
            }
        )

        return result

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Calculation error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)