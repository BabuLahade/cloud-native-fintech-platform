# ADR-006: ArgoCD for GitOps

**Date:** 2026-06
**Status:** Accepted
**Author:** Babu Lahade

## Context

Need a deployment workflow with audit trail, drift detection, and automated sync.
Option 1: manual kubectl apply in CI pipeline.
Option 2: ArgoCD watching Git continuously.

## Decision

Use ArgoCD. No manual kubectl apply in production ever.

## Reasons

| Requirement | Manual kubectl | ArgoCD GitOps |
|---|---|---|
| Audit trail | None | Every change is a Git commit with author and timestamp |
| Drift detection | None | Detects within 3 minutes, reverts automatically |
| Rollback | Re-run old pipeline | git revert and ArgoCD deploys previous state |
| ClickOps prevention | None | selfHeal overwrites manual kubectl changes |

## Workflow

1. Developer pushes code
2. GitHub Actions builds image, runs Trivy scan, pushes to ECR, updates image tag in Git
3. ArgoCD detects manifest change
4. ArgoCD syncs cluster automatically

## Consequences

ArgoCD runs in argocd namespace — around 256MB RAM overhead.
All manifests must live in Git. Manual kubectl changes are overwritten within 3 minutes.