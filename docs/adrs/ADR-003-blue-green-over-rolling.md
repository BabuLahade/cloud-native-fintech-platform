# ADR-003: Blue-Green over Rolling Deployment for Alert API

**Date:** 2026-06
**Status:** Accepted
**Author:** Babu Lahade

## Context

Alert API is external-facing. Users make trade decisions based on alert data.
Deployments must be zero-downtime with no version mixing.

## Decision

Use Argo Rollouts BlueGreen strategy for Alert API.

## Reasons

During rolling deployment old pods and new pods run simultaneously.
For a financial alert API this is unacceptable.
If v1 uses one risk model and v2 uses another, a user gets inconsistent data mid-session.
A trade decision on v1 data followed by a v2 alert = wrong information.

Blue-green solves this:
- 100% traffic on blue until green is validated
- Traffic switch is instantaneous
- Blue stays running for 10 minutes after switch for instant rollback

INC-007 proves rollback works under real CrashLoopBackOff conditions.

## Consequences

Argo Rollouts operator required.
Double pod count temporarily during deployment.
autoPromotionEnabled set to false — manual approval required before switch.