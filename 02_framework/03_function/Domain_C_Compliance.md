# Domain C: Compliance (컴플라이언스)

**버전**: v2.0 (NEW)
**최종 수정**: 2025-11-20
**목적**: 규제 준수, 표준, 정책, 감사

---

## 1. Domain 개요

### 1.1 정의
Compliance Domain은 **규제, 표준, 정책 준수**를 위한 통제 집합입니다.

### 1.2 v2.0 신규 추가 사유
- v1.0: C = Compute (컴퓨팅) → R (Resource)로 통합
- v2.0: C = Compliance (독립 Domain 필요성 증가)
- 이유: SOC 2, ISO 27001, GDPR, PCI-DSS 등 규제 강화

### 1.3 핵심 목표
1. **규제 준수**: GDPR, PCI-DSS, SOC 2, ISO 27001
2. **감사 추적**: 모든 변경 이력 기록
3. **정책 자동화**: Policy as Code

---

## 2. Tag 상세 정의

### C1: Regulatory Compliance (규제 준수)

**구성 요소**:
- **C1.1**: GDPR (General Data Protection Regulation)
  - Right to be Forgotten, Data Portability
  - Consent Management

- **C1.2**: PCI-DSS (Payment Card Industry)
  - Cardholder data protection
  - Network segmentation

- **C1.3**: HIPAA (Health Insurance Portability)
  - PHI (Protected Health Information)
  - Encryption requirements

**Layer/Zone**: All Layers, Zone 3-4

**사용 예시**:
```yaml
GDPR Compliance (C1.1):
  Tags: [C1.1, S8.3, D5.1]

  Data Subject Rights:
    - Right to Access: API endpoint /api/users/{id}/data
    - Right to be Forgotten: DELETE /api/users/{id} (hard delete)
    - Data Portability: Export to JSON format

  Consent Management:
    - Cookie Consent: CookieBot, OneTrust
    - Marketing Consent: Opt-in required
    - Data Processing Consent: Explicit consent stored in DB

  Breach Notification:
    - Detection: SIEM alerts (S5.1)
    - Notification: Within 72 hours
    - Documentation: Incident report (S5.3)
```

---

### C2: Security Standards (보안 표준)

**구성 요소**:
- **C2.1**: SOC 2 (Service Organization Control)
  - Type I: Design effectiveness
  - Type II: Operational effectiveness

- **C2.2**: ISO 27001 (Information Security Management)
  - ISMS (Information Security Management System)
  - Risk assessment, Controls

- **C2.3**: CIS Benchmarks
  - OS hardening, Database security
  - Automated scanning

**Layer/Zone**: All Layers

**사용 예시**:
```yaml
SOC 2 Type II (C2.1):
  Tags: [C2.1, S8.1, S8.2]

  Trust Service Criteria:
    - Security: Firewall (S1.1), Encryption (S3.1, S3.2)
    - Availability: 99.9% uptime, DR plan (D5.3)
    - Processing Integrity: Input validation, Error handling
    - Confidentiality: Access controls (S2.2), DLP
    - Privacy: GDPR compliance (C1.1)

  Audit Evidence:
    - CloudTrail logs (S8.1): 7 years retention
    - Change management: Jira tickets, Git commits
    - Access reviews: Quarterly (S6.1)
    - Incident response: Playbooks (S5.3)
```

---

### C3: Policy & Governance (정책 및 거버넌스)

**구성 요소**:
- **C3.1**: Policy as Code
  - OPA (Open Policy Agent)
  - AWS Config Rules, Azure Policy

- **C3.2**: Configuration Management
  - Terraform, Ansible, CloudFormation
  - Infrastructure as Code (IaC)

- **C3.3**: Change Management
  - Approval workflow
  - Rollback plan

**Layer/Zone**: L4 (Management), Zone 4

**사용 예시**:
```yaml
Policy as Code (C3.1):
  Tags: [C3.1, S6.1, S8.2]

  OPA Policies:
    - deny_public_s3_buckets:
        Rule: S3 buckets must not be public
        Enforcement: Terraform plan fails if violated

    - require_mfa_for_admin:
        Rule: Admin accounts must have MFA enabled
        Enforcement: AWS Config Rule → Alert

    - enforce_encryption:
        Rule: All RDS instances must have encryption
        Enforcement: CloudFormation template validation

  Compliance Scanning:
    - Tool: Checkov, tfsec
    - Frequency: Every git push (CI/CD)
    - Report: Compliance dashboard (Grafana)
```

---

### C4: Audit & Logging (감사 및 로깅)

**구성 요소**:
- **C4.1**: Audit Trail
  - CloudTrail, Azure Activity Log
  - Immutable logs

- **C4.2**: Log Retention
  - Compliance: 7 years (SOC 2, ISO 27001)
  - Storage: S3 Glacier, Cold storage

- **C4.3**: Audit Reports
  - Automated report generation
  - Evidence collection

**Layer/Zone**: All Layers

**사용 예시**:
```yaml
Audit Logging (C4.1):
  Tags: [C4.1, S8.1, M3.2]

  Log Sources:
    - AWS CloudTrail: All API calls
    - Database Audit: PostgreSQL pg_audit
    - Application Audit: User actions, Data changes

  Retention Policy (C4.2):
    - Hot Storage (S3 Standard): 30 days
    - Warm Storage (S3 IA): 1 year
    - Cold Storage (S3 Glacier): 7 years
    - Immutability: S3 Object Lock enabled

  Audit Report (C4.3):
    - Quarterly: Access review report
    - Annual: SOC 2 audit evidence
    - On-demand: GDPR data subject request
```

---

### C5: Data Residency & Sovereignty (데이터 상주성)

**구성 요소**:
- **C5.1**: Geographic Data Isolation
  - EU data in EU region
  - China data in China region

- **C5.2**: Cross-Border Data Transfer
  - Standard Contractual Clauses (SCC)
  - Binding Corporate Rules (BCR)

- **C5.3**: Local Data Laws
  - China: Cybersecurity Law
  - Russia: Data Localization Law

**Layer/Zone**: L3 (Data), Zone 3

**사용 예시**:
```yaml
Data Residency (C5.1):
  Tags: [C5.1, D1.1, S8.3]

  Regional Isolation:
    - EU Users:
        Database: PostgreSQL (eu-west-1)
        Storage: S3 (eu-west-1)
        Processing: EC2 (eu-west-1)

    - US Users:
        Database: PostgreSQL (us-east-1)
        Storage: S3 (us-east-1)
        Processing: EC2 (us-east-1)

  Cross-Border Transfer (C5.2):
    - Legal Basis: Standard Contractual Clauses
    - Encryption: TLS 1.3 in transit (S3.1)
    - Documentation: Data Processing Agreement (DPA)
```

---

## 3. Layer/Zone 연관성

| Layer | Compliance Tags | 통제 |
|-------|----------------|------|
| L1 | C3.1 | Policy as Code |
| L2 | C2.3 | CIS Benchmarks |
| L3 | C5.1, C4.1 | Data Residency, Audit |
| L4 | C2.1, C4.3 | SOC 2, Audit Reports |

### Zone별 Compliance 요구사항

```
Zone 3 (Data):
  - GDPR (C1.1), PCI-DSS (C1.2)
  - Encryption at Rest (S3.2)
  - Audit Logging (C4.1)

Zone 4 (Management):
  - SOC 2 (C2.1), ISO 27001 (C2.2)
  - Access Review (S6.1, C3.3)
  - Incident Response (S5.3)
```

---

## 4. CVE 매핑

Compliance Domain 자체는 소프트웨어 컴포넌트가 아니므로 직접적인 CVE는 없음.
단, Compliance 도구 (OPA, Terraform)의 취약점은 Domain T에서 관리.

---

## 5. MITRE ATT&CK 매핑

| Technique | Compliance Tag | 대응 통제 |
|-----------|---------------|----------|
| T1078 (Valid Accounts) | C4.1, S8.1 | Audit logging, Access review |
| T1565 (Data Manipulation) | C4.1 | Immutable audit logs |
| T1530 (Data from Cloud Storage) | C5.1, C1.1 | Data residency, Encryption |

---

## 6. 다음 단계

- **Domain S (Security)**: S8.2와 통합 (Compliance Frameworks)
- **Domain T (Tech Stack)**: Compliance 도구 버전 관리
- **Domain P (Platform)**: P2.3 (IaC)와 연동

---

**문서 종료**
