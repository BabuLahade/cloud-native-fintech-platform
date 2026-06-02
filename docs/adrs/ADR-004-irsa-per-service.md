# ADR-004: IRSA Per-Service over Node IAM Role

**Date:** 2026-06
**Status:** Accepted
**Author:** Babu Lahade

## Context

Pods need AWS permissions. SQS for Market Data. DynamoDB for Portfolio and Alert API.
Option 1: give the EC2 node a broad IAM role that all pods inherit.
Option 2: IRSA — each pod gets its own minimal IAM role.

## Decision

Use IRSA with one dedicated IAM role per service.

## Reasons

Without IRSA: every pod on the node shares the node IAM role.
If the node can access SQS + DynamoDB + S3, every pod can — including compromised ones.

With IRSA:
- Market Data pod → sqs:ReceiveMessage and sqs:DeleteMessage on one queue ARN only
- Portfolio pod → dynamodb:GetItem and dynamodb:PutItem on one table ARN only
- Alert API pod → dynamodb:GetItem read-only on one table ARN only

Blast radius comparison:
- Node IAM: one compromised pod = entire AWS account exposure
- IRSA: one compromised pod = access to exactly that pod's minimal permissions

## Consequences

3 separate IAM roles managed in Terraform irsa module.
OIDC provider must be enabled on EKS cluster.
ServiceAccount must be annotated with the role ARN.
