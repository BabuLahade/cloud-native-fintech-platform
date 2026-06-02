# ADR-002: KEDA over HPA for Market Data Ingestion

**Date:** 2026-06
**Status:** Accepted
**Author:** Babu Lahade

## Context
Market Data Ingestion processes SQS messages only during market hours .
9:15 AM to 3:30 PM IST. Queue is empty for 18 hours per day 

## Decision 

Use KEDA with SQS scaler for Market Data Ingestion.
Use standard HPA for Portfolio Calculator and Alert API.

## Reasons

| Feature | HPA | KEDA |
|---|---|---|
| Scale to zero | No — minReplicas minimum is 1 | Yes — minReplicaCount=0 |
| Scaling trigger | CPU or memory only | SQS depth, Kafka lag, 60+ sources |
| Idle cost 18 hrs/day | 1 pod running = wasted money | 0 pods = Rs 0 |
| Reaction to work | Lags until CPU rises | Immediate on queue depth |

## Consequences

KEDA operator required via Helm.
Cold start around 30 seconds at 9:15 AM — acceptable because messages buffer in SQS.