DR-001: Amazon EKS over Amazon ECS

**Date:** 2026-06
**Status:** Accepted
**Author:** Babu Lahade

## Context

The platform needs to run 3 microservices with different scaling strategies.
Market Data needs scale-to-zero. Alert API needs blue-green deployment.
Choice is between ECS Fargate and EKS.

## Decision

Use Amazon EKS.

## Reasons

| Requirement | ECS Fargate | EKS |
|---|---|---|
| Scale to zero | Not native | KEDA minReplicaCount=0 |
| Blue-green deployment | Manual ALB target groups | Argo Rollouts native |
| GitOps | No native controller | ArgoCD works natively |
| Chaos engineering | Limited | Full AWS FIS support |
| Industry standard | AWS-only skill | Portable, used everywhere |

## Consequences

Higher initial setup complexity. Mitigated by Terraform modules.
Stronger portfolio signal — Kubernetes is the industry standard for Platform Engineer roles.
