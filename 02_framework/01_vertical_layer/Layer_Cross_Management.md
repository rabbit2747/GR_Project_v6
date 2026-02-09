# Cross-Layer: Management & Security (관리 & 보안)

## 📋 문서 정보

**Layer**: Cross-Layer - Management & Security
**영문명**: Management & Security
**한글명**: 관리 & 보안
**위치**: 모든 계층 관통
**목적**: 전체 인프라 모니터링, 보안, 관리
**작성일**: 2025-01-20

---

## 🎯 Layer 정의

### 개요

**Cross-Layer (Management & Security)**는 **모든 계층에 걸쳐** 작동하는 관리 및 보안 시스템입니다.

```yaml
핵심 특징:
  - Layer 1-7 모두 관통
  - Horizontal Concerns (횡단 관심사)
  - 모니터링, IAM, SIEM, ITSM 등
```

---

## 📦 Cross-Layer 구성요소

### 1. Monitoring (모니터링)

**Metrics Collection (메트릭 수집)**:
```yaml
Prometheus:
  - Pull 기반 메트릭 수집
  - PromQL 쿼리
  - Time-Series DB

Grafana:
  - 시각화 대시보드
  - Alerting

Cloud Monitoring:
  - AWS CloudWatch
  - Azure Monitor
  - Google Cloud Monitoring
```

**Function Tags**:
- Primary: `M1.1` (Metrics Collection)
- Secondary: `M1.2` (Visualization)

---

**Logging (로그 수집)**:
```yaml
ELK Stack:
  - Elasticsearch (저장 & 검색)
  - Logstash (수집 & 변환)
  - Kibana (시각화)

Fluentd/Fluent Bit:
  - 경량 로그 수집기
  - CNCF 프로젝트

Loki:
  - Grafana Labs
  - Prometheus와 유사한 설계
```

**Function Tags**:
- Primary: `M2.1` (Log Aggregation)
- Secondary: `M2.2` (Log Analysis)

---

**APM (Application Performance Monitoring)**:
```yaml
Datadog:
  - Full-stack Observability
  - APM + Infrastructure + Logs

New Relic:
  - APM + Synthetic Monitoring

Dynatrace:
  - AI 기반 Root Cause Analysis

오픈소스:
  - Jaeger (분산 추적)
  - Zipkin
```

**Function Tags**:
- Primary: `M3.1` (APM)
- Secondary: `M3.2` (Distributed Tracing)

---

### 2. IAM (Identity & Access Management)

**대표 IAM 시스템**:
```yaml
클라우드 IAM:
  - AWS IAM
  - Azure AD
  - Google Cloud IAM

Enterprise SSO:
  - Okta
  - Auth0
  - Azure AD (Enterprise)

Self-Hosted:
  - Keycloak (오픈소스)
  - FreeIPA
```

**Function Tags**:
- Primary: `S2.1` (RBAC - Role-Based Access Control)
- Control: `S2.2` (MFA), `S2.3` (SSO)

---

### 3. Secrets Management

**대표 도구**:
```yaml
HashiCorp Vault:
  - 오픈소스 + Enterprise
  - Dynamic Secrets
  - Encryption as a Service

AWS Secrets Manager:
  - Fully Managed
  - Auto Rotation

Azure Key Vault:
  - Secrets, Keys, Certificates

Kubernetes Secrets:
  - Base64 Encoding (암호화 아님!)
  - External Secrets Operator 권장
```

**Function Tags**:
- Primary: `S4.2` (Secrets Management)
- Control: `S4.1` (Encryption at Rest)

---

### 4. SIEM (Security Information & Event Management)

**대표 SIEM**:
```yaml
Commercial:
  - Splunk Enterprise Security
  - IBM QRadar
  - ArcSight

오픈소스:
  - Wazuh
  - OSSEC
  - Elastic Security (ELK + SIEM)
```

**Function Tags**:
- Primary: `S9.1` (SIEM)
- Secondary: `S9.2` (Threat Detection), `S9.3` (Incident Response)

---

### 5. ITSM (IT Service Management)

**대표 ITSM 도구**:
```yaml
ServiceNow:
  - 엔터프라이즈 ITSM
  - Incident, Change, Problem Management

Jira Service Management:
  - Atlassian
  - DevOps 친화적

Freshservice, Zendesk:
  - SaaS ITSM
```

**Function Tags**:
- Primary: `M4.1` (ITSM)

---

### 6. Testing (테스팅)

**Unit Testing**:
```yaml
Jest (JavaScript):
  - React, Node.js

Pytest (Python):
  - FastAPI, Django

JUnit (Java):
  - Spring Boot
```

**Integration Testing**:
```yaml
Postman/Newman:
  - API Testing

Rest Assured (Java):
  - REST API Testing
```

**E2E Testing**:
```yaml
Playwright:
  - Cross-browser E2E
  - Chromium, Firefox, WebKit

Cypress:
  - JavaScript E2E

Selenium:
  - Legacy, 여전히 인기
```

**Performance Testing**:
```yaml
k6 (Grafana Labs):
  - Modern Load Testing
  - JavaScript DSL

JMeter (Apache):
  - Java 기반

Locust (Python):
  - Python 기반 분산 Load Testing
```

**Function Tags**:
- Primary: `M5.1` (Testing)
- Secondary: `M5.2` (E2E Testing), `M5.3` (Performance Testing)

---

## 🔒 Cross-Layer 보안 원칙

### Zero Trust Architecture

```yaml
원칙:
  - Never Trust, Always Verify
  - Least Privilege Access
  - Micro-Segmentation

구현:
  - Identity-based Access (IAM)
  - MFA Everywhere
  - Continuous Monitoring (SIEM)
```

---

## 📊 실전 예시

### 예시: Kubernetes 기반 Observability Stack

```yaml
Cross-Layer (Management):
  Monitoring:
    - Prometheus (Metrics)
    - Grafana (Dashboard)
    - Loki (Logs)
    - Jaeger (Distributed Tracing)

  IAM:
    - Keycloak (SSO)
    - Kubernetes RBAC

  Secrets:
    - HashiCorp Vault
    - External Secrets Operator

  SIEM:
    - Wazuh (오픈소스)
    - Falco (Runtime Security)

  Testing:
    - Playwright (E2E)
    - k6 (Load Testing)

Zone 배치:
  - Zone 4 (Management Zone) - 관리 도구 배치
  - Zone 2-3 → Metrics/Logs 수집
```

---

## ✅ 체크리스트

### 모니터링

- [ ] Prometheus + Grafana 대시보드 구성
- [ ] 알람 룰 설정 (CPU >80%, Disk >90%)
- [ ] 로그 보관 정책 (30일 이상)

### 보안

- [ ] IAM 정책 최소 권한 원칙
- [ ] MFA 활성화 (모든 관리자)
- [ ] Secrets Rotation (3-6개월)
- [ ] SIEM 알람 설정 (비정상 로그인 시도)

### 테스팅

- [ ] Unit Test 커버리지 ≥80%
- [ ] E2E 테스트 자동화
- [ ] Performance Baseline 설정

---

## 🔗 관련 문서

- [차원 1: Deployment Layer 개요](00_차원1_개요.md)
- [Layer 0-7 모든 계층](00_차원1_개요.md)

---

## 📞 변경 이력

**v1.0 (2025-01-20)** - 초기 작성:
- ✅ Monitoring, IAM, Secrets, SIEM, ITSM, Testing 분류
- ✅ Zero Trust 원칙
- ✅ Observability Stack 예시

---

**문서 끝**
