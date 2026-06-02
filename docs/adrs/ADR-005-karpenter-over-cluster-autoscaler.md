# ADR-005: Karpenter over Cluster Autoscaler

**Date:** 2026-06
**Status:** Accepted
**Author:** Babu Lahade

## Context

Node autoscaling is required. When KEDA scales Market Data from 0 to 20 pods
at 9:15 AM, new nodes must provision fast enough to handle the burst.

## Decision

Use Karpenter instead of Cluster Autoscaler.

## Reasons

| Feature | Cluster Autoscaler | Karpenter |
|---|---|---|
| Provisioning time | 3 to 5 minutes via ASG | Under 60 seconds via EC2 API directly |
| Instance selection | One node group at a time | Picks cheapest instance that fits |
| Spot handling | Manual spot node groups | Automatic spot with on-demand fallback |
| Node removal | Not built-in | consolidationPolicy WhenEmpty removes idle nodes |

## Market hours scenario

9:15 AM: Queue fills. KEDA creates 20 pending pods. Karpenter provisions spot nodes in under 60 seconds.
3:30 PM: Queue drains. KEDA scales to 0 pods. Karpenter removes empty nodes. Node cost = Rs 0.

## Consequences

Karpenter requires its own IAM role and EC2NodeClass configuration.
NodePool must define instance types and consolidation policy.