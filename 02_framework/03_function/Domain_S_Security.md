# Domain S: Security (보안)

**버전**: v2.0
**최종 수정**: 2025-11-20
**목적**: 인증, 인가, 암호화, 취약점 관리, 보안 모니터링

---

## 1. Domain 개요

### 1.1 정의
Security Domain은 **기밀성(Confidentiality), 무결성(Integrity), 가용성(Availability)** 보장을 위한 보안 통제 집합입니다.

### 1.2 v1.0 → v2.0 변경사항
- Vulnerability Management (S4) 추가
- SIEM 통합 (S5 확장)
- AI/ML 보안 (S7.4) 추가
- Total tags: 25 → 35+

### 1.3 핵심 목표
1. **Zero Trust Architecture**: "절대 신뢰하지 말고, 항상 검증하라"
2. **Defense in Depth**: 다층 보안 방어
3. **Least Privilege**: 최소 권한 원칙
4. **Security by Design**: 설계 단계부터 보안 고려

---

## 2. Tag 체계

### Tag 구조
```
S + [숫자] + (선택적 서브 카테고리)
예: S1 (Perimeter Security), S2.1 (Authentication - MFA)
```

---

## 3. Tag 상세 정의

### S1: Perimeter Security (경계 보안)

**목적**: 외부 위협 차단 (Zone 0 → Zone 1 경계)

**구성 요소**:
- **S1.1**: WAF (Web Application Firewall)
  - 도구: AWS WAF, Cloudflare WAF, ModSecurity
  - 차단: SQL Injection, XSS, CSRF, OWASP Top 10
  - Rule Set: AWS Managed Rules, OWASP CRS

- **S1.2**: DDoS Protection
  - 도구: AWS Shield Advanced, Cloudflare
  - Layer 3/4: SYN Flood, UDP Amplification
  - Layer 7: HTTP Flood, Slowloris

- **S1.3**: Bot Management
  - 도구: Cloudflare Bot Management
  - 탐지: User-Agent, Behavioral analysis
  - CAPTCHA: hCaptcha, reCAPTCHA v3

**Layer/Zone 연관**: L1 (Perimeter), Zone 1

**CVE 예시**:
```yaml
CVE-2024-12345: ModSecurity Bypass
  Affected: ModSecurity 3.0.x
  Severity: High
  Mitigation: Upgrade to 3.0.10
```

**MITRE ATT&CK**: T1190 (Exploit Public-Facing Application)

---

### S2: Authentication & Authorization (인증 및 인가)

**목적**: 사용자 신원 확인 및 접근 권한 관리

**구성 요소**:
- **S2.1**: Authentication
  - **S2.1.1**: Password-based (bcrypt, Argon2)
  - **S2.1.2**: MFA (TOTP, WebAuthn, SMS)
  - **S2.1.3**: SSO (SAML 2.0, OAuth 2.0, OIDC)

- **S2.2**: Authorization
  - **S2.2.1**: RBAC (Role-Based Access Control)
  - **S2.2.2**: ABAC (Attribute-Based Access Control)
  - **S2.2.3**: OAuth 2.0 & JWT (RS256)

**Layer/Zone 연관**: L1-L2, Zone 1-2

**사용 예시**:
```yaml
JWT Token (S2.2.3):
  {
    "sub": "user_12345",
    "roles": ["user", "premium"],
    "iat": 1700000000,
    "exp": 1700003600
  }
  Signed with: RSA-SHA256
```

**MITRE ATT&CK**: T1078 (Valid Accounts), T1110 (Brute Force)

---

### S3: Data Protection (데이터 보호)

**목적**: 데이터 암호화 및 보안 전송

**구성 요소**:
- **S3.1**: Encryption in Transit
  - TLS 1.3, mTLS (Mutual TLS)
  - Certificate: Let's Encrypt, ACM

- **S3.2**: Encryption at Rest
  - Database: PostgreSQL TDE, AES-256
  - File: AWS S3 SSE-KMS
  - Key Management: AWS KMS, HashiCorp Vault

- **S3.3**: Data Masking & Tokenization
  - PII Masking: Email, Phone
  - Tokenization: Credit Card → Token

**Layer/Zone 연관**: All Layers, Zone 1-3

**사용 예시**:
```yaml
TLS Configuration (S3.1):
  Protocol: TLS 1.3
  Cipher: TLS_AES_256_GCM_SHA384
  Certificate: Let's Encrypt Wildcard
  HSTS: max-age=31536000
```

**MITRE ATT&CK**: T1557 (Man-in-the-Middle)

---

### S4: Vulnerability Management (v2.0 신규)

**목적**: 취약점 탐지, 평가, 패치 관리

**구성 요소**:
- **S4.1**: Vulnerability Scanning
  - 도구: Nessus, Qualys, AWS Inspector
  - 스캔: OS, Applications, Libraries
  - 주기: Weekly (non-prod), Monthly (prod)

- **S4.2**: Dependency Scanning
  - 도구: Snyk, Dependabot, npm audit
  - Auto-fix: Minor version updates

- **S4.3**: Patch Management
  - OS: Automated (AWS Systems Manager)
  - Application: Tested in staging → Production
  - SLA: Critical (24h), High (7d), Medium (30d)

**Layer/Zone 연관**: All Layers, Zone 2-4

**사용 예시**:
```yaml
Vulnerability Workflow:
  1. Scan: AWS Inspector (S4.1)
  2. Finding: CVE-2024-67890 (PostgreSQL 14.0, Critical)
  3. Assess: CVSS 9.8, Exploitable
  4. Remediate: Upgrade 14.0 → 14.10
  5. Verify: Re-scan
  6. Report: Update vulnerability DB (atomized format)
```

**MITRE ATT&CK**: T1190 (Exploit Public-Facing Application)

---

### S5: Security Monitoring & Incident Response

**목적**: 보안 이벤트 탐지, 분석, 대응

**구성 요소**:
- **S5.1**: SIEM (Security Information and Event Management)
  - 도구: Splunk, QRadar, Azure Sentinel
  - Logs: WAF, Authentication, Database Audit

- **S5.2**: Threat Intelligence
  - 도구: MISP, ThreatConnect
  - IoC: IP, Domain, Hash

- **S5.3**: Incident Response
  - Playbook: NIST CSF
  - Phases: Identify → Protect → Detect → Respond → Recover

**Layer/Zone 연관**: L4 (Management), Zone 4

**사용 예시**:
```yaml
Security Incident: Brute Force Attack
  Detection: 150 failed login attempts in 5 minutes (S5.1)
  Source IP: 203.0.113.45
  Action:
    - Block IP at WAF (S1.1)
    - Alert: Slack #security-alerts
  MITRE ATT&CK: T1110.001 (Brute Force)
```

**MITRE ATT&CK**: T1078 (Valid Accounts), T1110 (Brute Force)

---

### S6: Identity & Access Management (IAM)

**목적**: 사용자 및 서비스 계정 관리

**구성 요소**:
- **S6.1**: User Lifecycle Management
  - Provisioning: Automated (SCIM)
  - De-provisioning: Offboarding
  - Access Review: Quarterly

- **S6.2**: Service Accounts & API Keys
  - Rotation: Every 90 days
  - Storage: AWS Secrets Manager, Vault

- **S6.3**: Privileged Access Management (PAM)
  - Just-in-Time Access
  - Session Recording
  - Approval Workflow

**Layer/Zone 연관**: L4 (Management), Zone 4

**사용 예시**:
```yaml
IAM Policy (S6.1):
  User: developer@example.com
  Role: Developer
  Permissions:
    - EC2: Read (Zone 2 only)
    - S3: Read/Write (bucket: dev-assets)
    - RDS: Connect (dev-database only)
```

**MITRE ATT&CK**: T1078 (Valid Accounts)

---

### S7: Application Security

**목적**: 소프트웨어 개발 단계 보안

**구성 요소**:
- **S7.1**: SAST (Static Application Security Testing)
  - 도구: SonarQube, Checkmarx, Semgrep
  - 탐지: SQL Injection, XSS, Hardcoded Secrets

- **S7.2**: DAST (Dynamic Application Security Testing)
  - 도구: OWASP ZAP, Burp Suite
  - Testing: Running application (staging)

- **S7.3**: Dependency Security
  - 도구: Snyk, npm audit, OWASP Dependency-Check
  - Auto-fix: Automated PR

- **S7.4**: AI/ML Security (v2.0 신규)
  - Prompt Injection Detection
  - Model Poisoning Prevention
  - Data Privacy in Training

**Layer/Zone 연관**: L2 (Application), Zone 2

**사용 예시**:
```yaml
CI/CD Security Pipeline:
  1. SAST: SonarQube (fail on Critical/High)
  2. Dependency Scan: Snyk (auto-upgrade)
  3. DAST: OWASP ZAP (staging)
  4. Security Review: Manual sign-off
  5. Deploy: Production
```

**MITRE ATT&CK**: T1059 (Command Injection), T1505 (Web Shell)

---

### S8: Compliance & Audit

**목적**: 규제 준수 및 감사 추적

**구성 요소**:
- **S8.1**: Audit Logging
  - 도구: AWS CloudTrail, Azure Activity Log
  - Retention: 7 years

- **S8.2**: Compliance Frameworks
  - Standards: SOC 2, ISO 27001, PCI-DSS, GDPR
  - Controls: CIS Benchmarks, NIST CSF

- **S8.3**: Data Residency & Privacy
  - GDPR: Right to be Forgotten
  - Data Localization: EU data in EU region

**Layer/Zone 연관**: All Layers, Zone 3-4

**사용 예시**:
```yaml
Audit Log (S8.1):
  event: "IAM Policy Changed"
  user: "admin@example.com"
  resource: "iam:policy/DeveloperAccess"
  compliance_tag: "SOC2_CC6.1"

GDPR Request (S8.3):
  Type: Right to be Forgotten
  Actions:
    - Delete user data (PostgreSQL)
    - Delete backups (S3)
    - Anonymize logs
```

**MITRE ATT&CK**: T1078 (Valid Accounts), T1565 (Data Manipulation)

---

## 4. Layer/Zone 연관성

### Layer별 Security Controls

| Layer | 주요 Tags | 통제 |
|-------|----------|------|
| L0 | S1.2 | DDoS Protection |
| L1 | S1.1, S2.1 | WAF, Authentication |
| L2 | S7.1, S2.2 | SAST, Authorization |
| L3 | S3.2, S8.1 | Encryption at Rest, Audit |
| L4 | S6.3, S5.1 | PAM, SIEM |
| L5 | S2.1.2 | MFA |

### Zone별 Security Posture

```
Zone 0-A: Trust 0%, Controls: S1.1, S1.2, S1.3
Zone 0-B: Trust 10%, Controls: S2.2.3, S3.1
Zone 1: Trust 30%, Controls: S2.1, S3.1, S1.1
Zone 2: Trust 50%, Controls: S2.2, S7.1, S3.1
Zone 3: Trust 80%, Controls: S3.2, S8.1
Zone 4: Trust 90%, Controls: S6.3, S2.1.2
Zone 5: Trust 20%, Controls: S2.1.2
```

---

## 5. CVE 매핑 (Domain T 연동)

| CVE ID | 도구 | Tech Stack Tag | Severity |
|--------|------|---------------|----------|
| CVE-2024-11111 | Keycloak <22.0.0 | T4.2 | Critical |
| CVE-2024-22222 | NGINX ModSecurity | T3.1 | High |
| CVE-2024-33333 | Vault | T4.7 | Medium |

---

## 6. MITRE ATT&CK 매핑

| Technique | Security Tag | 탐지/차단 |
|-----------|-------------|----------|
| T1078 | S5.1 | SIEM 이상 탐지 |
| T1110 | S2.1.2, S5.1 | MFA, Rate Limiting |
| T1190 | S1.1, S7.2 | WAF, DAST |
| T1486 | S3.2, S8.1 | Backup, Audit |
| T1552 | S7.1, S6.2 | SAST, Secrets Manager |

---

## 7. 다음 단계

- **Domain M (Monitoring)**: S5.1과 연동 (SIEM)
- **Domain C (Compliance)**: S8.2와 연동 (규제)
- **Domain T (Tech Stack)**: S4.1과 연동 (CVE)

---

**문서 종료**
