# Cloud-Native Fintech Trading Platform

Production-grade Kubernetes platform simulating a real fintech trading company on AWS.

**Author:** Babu Lahade — MCA Cloud Computing, SPPU 2026
**Contact:** babulahade@gmail.com | +91-9322016757
**GitHub:** https://github.com/BabuLahade/cloud-native-fintech-platform

---

## What This Project Demonstrates

| Domain | Technologies |
|---|---|
| Infrastructure as Code | Terraform (modular) |
| Kubernetes Platform | EKS, Karpenter, KEDA, HPA, Argo Rollouts |
| GitOps | ArgoCD |
| DevSecOps | GitHub Actions, Trivy, OWASP ZAP |
| Security | IRSA per-service, NetworkPolicy, External Secrets Operator |
| Observability | Prometheus, Grafana, Alertmanager, PagerDuty |
| SRE | SLO 99.5%, Error Budget, Runbooks |
| FinOps | Cost Explorer Lambda, Grafana Cost Dashboard |
| Disaster Recovery | Route53 failover, RDS Multi-AZ, S3 CRR |
| Chaos Engineering | AWS FIS |

---

## Business Scenario

A fintech company processes live stock market data (NSE/BSE).

- Process market events in real time during market hours 9:15 AM to 3:30 PM IST
- Scale to zero after market close — zero pod cost overnight
- Zero-downtime deployments for trading alert APIs
- 99.5% availability SLO
- Every deployment is a Git commit

---

## The 3 Microservices

| Service | Scaling | Deployment | IRSA Permission |
|---|---|---|---|
| Market Data Ingestion | KEDA 0 to 20 pods on SQS depth | Standard | SQS read only |
| Portfolio Calculator | HPA CPU 2 to 10 pods | Rolling | DynamoDB read+write |
| Alert API | HPA 2 to 8 pods | Argo Rollouts Blue-Green | DynamoDB read only |

---

## Architecture
Users → CloudFront → WAF → ALB → EKS
├── Market Data Ingestion  (KEDA, 0→20 pods)
├── Portfolio Calculator   (HPA, 2→10 pods)
└── Alert API              (Argo Rollouts Blue-Green)
GitHub → GitHub Actions → ECR → ArgoCD → EKS
Trivy SAST + OWASP ZAP DAST in pipeline
EKS → Prometheus → Grafana → Alertmanager → PagerDuty

---

## Key Incident

**INC-007** — Deliberate broken image deployment. Blue served 100% traffic while green was in CrashLoopBackOff. Documented in docs/FAILURES.md.

---

## Build Phases

| Phase | What Gets Built |
|---|---|
| 0 | Repo structure, ADRs, Terraform backend |
| 1 | VPC, subnets, SGs, ECR, OIDC |
| 2 | EKS cluster, node group, LB controller |
| 3 | FastAPI microservices, Docker, ECR push |
| 4 | IRSA, NetworkPolicy, Secrets Manager, ESO, PDB |
| 5 | KEDA, HPA, Karpenter NodePool |
| 6 | ArgoCD GitOps |
| 7 | Argo Rollouts blue-green + INC-007 |
| 8 | Prometheus + Grafana + Alertmanager |
| 9 | GitHub Actions + Trivy + OWASP ZAP |
| 10 | SLO + Error Budget + PagerDuty |
| 11 | FinOps Lambda + Cost dashboard |
| 12 | Route53 DR + S3 CRR + AWS FIS chaos |
| 13 | ADRs + FAILURES.md + diagrams + resume bullets |