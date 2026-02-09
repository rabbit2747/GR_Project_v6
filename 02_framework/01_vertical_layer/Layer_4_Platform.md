# Layer 4: Platform Services (플랫폼 서비스)

## 📋 문서 정보

**Layer**: 4 - Platform Services
**영문명**: Platform Services
**한글명**: 플랫폼 서비스
**위치**: 중단 계층
**목적**: 개발, 배포, 인프라 자동화 플랫폼 제공
**작성일**: 2025-01-20

---

## 🎯 Layer 정의

### 개요

**Layer 4 (Platform Services)**는 소프트웨어 개발 및 배포를 위한 **플랫폼과 도구**를 제공하는 계층입니다.

```yaml
핵심 역할:
  - CI/CD (지속적 통합 및 배포)
  - IaC (Infrastructure as Code)
  - Version Control (소스 코드 관리)
  - Container Registry
  - Artifact Management
```

---

## 📦 Platform Services 구성요소

### 1. CI/CD (Continuous Integration/Continuous Deployment)

**대표 도구**:
```yaml
클라우드 기반:
  - GitHub Actions
  - GitLab CI/CD
  - AWS CodePipeline + CodeBuild
  - Azure DevOps Pipelines
  - Google Cloud Build

Self-Hosted:
  - Jenkins (가장 인기)
  - TeamCity (JetBrains)
  - Drone CI
  - CircleCI (Self-hosted 지원)
```

**Function Tags**:
- Primary: `P2.1` (CI/CD Pipeline)
- Secondary: `P2.2` (Build Automation), `P2.3` (Deployment Automation)

---

### 2. IaC (Infrastructure as Code)

**대표 도구**:
```yaml
Terraform:
  - Multi-cloud 지원
  - HCL 언어
  - State Management

Ansible:
  - 구성 관리 (Configuration Management)
  - Agentless
  - YAML Playbook

AWS CloudFormation:
  - AWS 전용
  - JSON/YAML Template

Pulumi:
  - 프로그래밍 언어 (TypeScript, Python, Go)
  - Multi-cloud

Kubernetes Manifests:
  - kubectl apply -f
  - Helm Charts
  - Kustomize
```

**Function Tags**:
- Primary: `P3.1` (Infrastructure Automation)

---

### 3. Version Control

**대표 시스템**:
```yaml
Git 기반:
  - GitHub (SaaS, Enterprise)
  - GitLab (SaaS, Self-hosted)
  - Bitbucket (Atlassian)
  - Azure Repos

Legacy:
  - SVN (Subversion)
  - Perforce (게임 개발)
```

**Function Tags**:
- Primary: `P1.1` (Version Control)

---

### 4. Container Registry

**대표 서비스**:
```yaml
클라우드:
  - AWS ECR (Elastic Container Registry)
  - Azure ACR (Azure Container Registry)
  - Google GCR/Artifact Registry

Self-Hosted:
  - Harbor (CNCF 프로젝트)
  - Nexus Repository
  - JFrog Artifactory

Public:
  - Docker Hub (Layer 0 - External)
  - Quay.io
```

**Function Tags**:
- Primary: `P4.1` (Container Registry)
- Control: `S8.1` (Image Scanning - Vulnerability)

---

## 📊 실전 예시

### 예시: GitHub Actions + Terraform + EKS

```yaml
Layer 4 (Platform):
  Version Control: GitHub
  CI/CD: GitHub Actions
  IaC: Terraform
  Container Registry: AWS ECR

Workflow:
  1. 개발자 코드 Push (GitHub)
  2. GitHub Actions Trigger
  3. Docker Build & Push (ECR)
  4. Terraform Apply (EKS 배포)
  5. ArgoCD Sync (GitOps)
```

---

## ✅ 체크리스트

- [ ] CI/CD Pipeline 구성
- [ ] IaC 코드 버전 관리
- [ ] Container Image 취약점 스캔
- [ ] Artifact 보안 저장

---

## 🔗 관련 문서

- [Layer 3: Computing Infrastructure](Layer_3_Computing.md)
- [Layer 6: Runtime](Layer_6_Runtime.md)

---

**문서 끝**
