# Domain P: Platform (플랫폼)

**버전**: v2.0
**최종 수정**: 2025-11-20
**목적**: 클라우드 플랫폼, CI/CD, IaC, 버전 관리

---

## 1. Domain 개요

### 1.1 정의
Platform Domain은 **클라우드 플랫폼, DevOps, 인프라 관리** 기능 집합입니다.

### 1.2 v1.0 → v2.0 변경사항
- GitOps (P2.4) 추가
- AI/ML Platform (P3.3) 추가
- Total tags: 20 → 25+

### 1.3 핵심 목표
1. **자동화**: Infrastructure as Code
2. **속도**: CI/CD 파이프라인
3. **일관성**: Immutable Infrastructure

---

## 2. Tag 상세 정의

### P1: Cloud Platform (클라우드 플랫폼)

**구성 요소**:
- **P1.1**: IaaS (AWS EC2, Azure VM, GCP Compute)
- **P1.2**: PaaS (Heroku, Google App Engine)
- **P1.3**: FaaS (AWS Lambda, Azure Functions)
- **P1.4**: CaaS (AWS ECS, GKE, AKS)

**Layer/Zone**: L1-L2, Zone 1-2

**사용 예시**:
```yaml
AWS Cloud (P1.1):
  Tags: [P1.1, P1.3, P1.4, R2.1]
  Services:
    - EC2: t3.large (Zone 2)
    - Lambda: Serverless functions (P1.3)
    - ECS: Container platform (P1.4)
```

---

### P2: CI/CD & DevOps (CI/CD 및 DevOps)

**구성 요소**:
- **P2.1**: Version Control (Git, GitHub, GitLab)
- **P2.2**: CI/CD Pipeline (GitHub Actions, GitLab CI, Jenkins)
- **P2.3**: Infrastructure as Code (Terraform, CloudFormation, Pulumi)
- **P2.4**: GitOps (v2.0 신규)
  - ArgoCD, Flux
  - Git as single source of truth

**Layer/Zone**: L4 (Management), Zone 4

**사용 예시**:
```yaml
CI/CD Pipeline (P2.2):
  Tags: [P2.2, S7.1, S7.2, S7.3]

  GitHub Actions:
    on: push to main

    steps:
      1. Checkout code
      2. SAST: SonarQube scan (S7.1)
      3. Dependency Scan: Snyk (S7.3)
      4. Unit Tests: pytest
      5. Build: Docker image
      6. Push: ECR registry (R1.2)
      7. Deploy: ArgoCD sync (P2.4)
      8. DAST: OWASP ZAP (S7.2)
```

**GitOps Workflow (P2.4)**:
```yaml
ArgoCD (Zone 4):
  Tags: [P2.4, R2.2, P2.3]

  Git Repository: github.com/org/k8s-manifests
  Target Cluster: Kubernetes (Zone 2)

  Sync Policy:
    - Auto-sync: Enabled
    - Prune: Delete resources not in Git
    - Self-heal: Auto-correct drift

  Deployment:
    1. Developer: git push to main
    2. ArgoCD: Detects change
    3. ArgoCD: kubectl apply -f manifests/
    4. Kubernetes: Rolling update
```

---

### P3: Container & Orchestration Platform

**구성 요소**:
- **P3.1**: Container Platform (Docker, Podman)
- **P3.2**: Kubernetes (EKS, GKE, AKS)
- **P3.3**: AI/ML Platform (v2.0 신규)
  - Kubeflow, MLflow, Weights & Biases
  - GPU node management

**Layer/Zone**: L2, Zone 2

**사용 예시**:
```yaml
Kubernetes (P3.2):
  Tags: [P3.2, R2.2, N6.1]

  Cluster: EKS 1.28
  Nodes: 10 (m5.xlarge)
  GPU Nodes: 2 (g5.2xlarge) for AI/ML (P3.3)

  Add-ons:
    - Istio: Service mesh (N6.1)
    - Prometheus: Monitoring (M1.2)
    - ArgoCD: GitOps (P2.4)
    - Kubeflow: ML platform (P3.3)
```

---

### P4: Monitoring & Observability Platform

**구성 요소**:
- **P4.1**: Monitoring Platform (Datadog, New Relic, Dynatrace)
- **P4.2**: Log Aggregation (ELK Stack, Splunk, Loki)
- **P4.3**: Tracing Platform (Jaeger, Zipkin, Tempo)

**Layer/Zone**: L4 (Management), Zone 4

**사용 예시**:
```yaml
Datadog Platform (P4.1):
  Tags: [P4.1, M2.1, M5.1, M8.2]

  Integrations:
    - APM: Backend services (M2.1)
    - Infrastructure: AWS, Kubernetes (M7.3)
    - Logs: Centralized logging (M3.2)
    - RUM: Frontend monitoring (M8.2)
    - Tracing: Distributed tracing (M5.1)
```

---

### P5: Secrets Management & Configuration

**구성 요소**:
- **P5.1**: Secrets Management (Vault, AWS Secrets Manager)
- **P5.2**: Configuration Management (Ansible, Chef, Puppet)
- **P5.3**: Service Discovery (Consul, etcd)

**Layer/Zone**: L4, Zone 4

**사용 예시**:
```yaml
HashiCorp Vault (P5.1):
  Tags: [P5.1, S6.2, S3.2]

  Secrets:
    - Database credentials (auto-rotation 90d)
    - API keys (manual rotation)
    - TLS certificates (auto-renewal)

  Access:
    - Kubernetes Service Accounts (Zone 2)
    - IAM Roles (EC2 instances)
    - AppRole (CI/CD pipeline)
```

---

## 3. Layer/Zone 연관성

| Layer | Platform Tags | 구성 요소 |
|-------|--------------|----------|
| L2 | P3.2 | Kubernetes |
| L4 | P2.2, P4.1 | CI/CD, Monitoring Platform |

---

## 4. CVE 매핑

| CVE ID | Platform | Tech Stack Tag | Severity |
|--------|----------|---------------|----------|
| CVE-2024-11111 | Kubernetes <1.28.0 | T4.4 | High |
| CVE-2024-22222 | Terraform <1.6.0 | T4.8 | Medium |
| CVE-2024-33333 | ArgoCD <2.9.0 | T4.9 | High |

---

## 5. MITRE ATT&CK 매핑

| Technique | Platform Tag | 탐지/차단 |
|-----------|-------------|----------|
| T1525 (Implant Container Image) | P3.1, R1.3 | Image Scanning |
| T1610 (Deploy Container) | P3.2, S7.1 | Admission Controller |

---

## 6. 다음 단계

- **Domain R (Resource)**: P3.2와 연동 (Kubernetes)
- **Domain T (Tech Stack)**: P1.1, P3.2와 연동 (버전)
- **Domain C (Compliance)**: P2.3과 연동 (IaC)

---

**문서 종료**
