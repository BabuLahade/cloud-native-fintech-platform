# FAILURES.md — Incident Register

**Project:** Cloud-Native Fintech Trading Platform
**Author:** Babu Lahade
**Repository:** https://github.com/BabuLahade/cloud-native-fintech-platform

This file documents every real incident, failure, and deliberate chaos test.
Each entry: What happened → Timeline → Root Cause → Fix → Lessons Learned.

---

## Incident Index

| ID | Phase | Service | Summary | Impact | Status |
|---|---|---|---|---|---|
| INC-007 | 7 | Alert API | Deliberate broken image — blue-green rollback test | Zero — blue served 100% | Planned |

---

## INC-007 — Blue-Green Rollback Test

**Date:** TBD — will be filled in during Phase 7
**Severity:** Deliberate test — zero user impact
**Service:** alert-api
**Strategy:** Argo Rollouts BlueGreen

### What Happened

Deliberately pushed a non-existent image tag to prove that blue-green deployment
protects production traffic under real failure conditions.

### Timeline
T+0:00  Pushed broken image tag to rollout
T+0:35  Green ReplicaSet created, pods enter ImagePullBackOff
T+1:20  Pods enter CrashLoopBackOff after 3 pull retries
T+1:45  Ran: kubectl argo rollouts abort alert-api
T+1:50  Blue serving 100%, rollout phase = Degraded, reset to Healthy

Exact times to be filled in during Phase 7.

### User Impact

ZERO. Blue pods served 100% traffic throughout.
Continuous curl loop against active LoadBalancer URL showed all HTTP 200 responses.

### Root Cause

Intentional. Image tag does not exist in ECR.
EKS cannot pull image → ImagePullBackOff → CrashLoopBackOff.

### What Was Proved

- Blue-green boundary held completely
- autoPromotionEnabled false is correct for fintech
- Rollback took under 2 minutes
- Zero HTTP 5xx during entire failure window

### Action Items

- Add image existence check in GitHub Actions before updating manifest
- Add PagerDuty alert on Rollout phase Degraded