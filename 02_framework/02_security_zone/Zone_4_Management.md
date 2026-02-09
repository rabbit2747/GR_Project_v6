# Zone 4: Management (관리 영역)

## 📋 문서 정보

**Zone**: 4 - Management
**영문명**: Management Zone
**한글명**: 관리 영역
**위치**: 시스템 전체 관리 계층
**신뢰 수준**: Very High (80%)
**작성일**: 2025-01-20

---

## 🎯 Zone 정의

### 개요

**Zone 4 (Management)**는 **시스템 전체의 통제, 모니터링, 보안 관리를 담당하는 최고 신뢰 영역**입니다.

```yaml
핵심 역할:
  - 보안 정보 및 이벤트 관리 (SIEM)
  - 신원 및 접근 관리 (IAM)
  - 비밀 정보 관리 (Secrets Management)
  - 모니터링 및 알람
  - IT 서비스 관리 (ITSM)
  - 신뢰 수준: 80% (매우 높은 신뢰)
```

### 계층 위치

```yaml
Zone 1-3, 5 (모든 Zone) → Zone 4 (Management)
                             ↑
                       관리 및 통제 허브
                       - 로그/메트릭 수집
                       - 보안 정책 배포
                       - 위협 탐지
```

---

## 📦 Zone 4 구성요소

### 1. SIEM (Security Information & Event Management)

**대표 SIEM**:
```yaml
Commercial:
  - Splunk Enterprise Security
  - IBM QRadar
  - ArcSight (Micro Focus)
  - LogRhythm

오픈소스:
  - Wazuh (오픈소스, 가장 인기)
  - OSSEC
  - Elastic Security (ELK + SIEM)
  - Graylog
```

**기능**:
```yaml
로그 수집:
  - Zone 1-3, 5로부터 Syslog 수집
  - 실시간 로그 스트리밍
  - 로그 정규화 (Parsing)

위협 탐지:
  - 규칙 기반 탐지 (Rule-based)
  - 이상 탐지 (Anomaly Detection)
  - 위협 인텔리전스 연동 (Zone 0-B)

알람:
  - Critical: 즉시 통보 (PagerDuty, Slack)
  - High: 30분 내 검토
  - Medium: 1시간 내 검토

대시보드:
  - 실시간 보안 이벤트
  - 공격 시도 시각화
  - Compliance 리포트 (GDPR, PCI-DSS)
```

**Function Tags**:
- Primary: `S9.1` (SIEM)
- Secondary: `S9.2` (Threat Detection), `S9.3` (Incident Response)

**Zone 배치**: Zone 4 (Management)

---

### 2. IAM (Identity & Access Management)

**대표 IAM 시스템**:
```yaml
클라우드 IAM:
  - AWS IAM
  - Azure AD (Entra ID)
  - Google Cloud IAM

Enterprise SSO:
  - Okta
  - Auth0
  - Azure AD (Enterprise)

Self-Hosted:
  - Keycloak (오픈소스)
  - FreeIPA
  - OpenLDAP
```

**기능**:
```yaml
사용자 인증:
  - Username/Password
  - MFA (Multi-Factor Authentication)
  - SSO (Single Sign-On)
  - Certificate-based

권한 관리:
  - RBAC (Role-Based Access Control)
  - ABAC (Attribute-Based Access Control)
  - 최소 권한 원칙 (Least Privilege)

감사:
  - 로그인 이력 기록
  - 권한 변경 로그
  - 이상 로그인 탐지 (Impossible Travel)
```

**Function Tags**:
- Primary: `S2.1` (RBAC - Role-Based Access Control)
- Control: `S2.2` (MFA), `S2.3` (SSO)

**Zone 배치**: Zone 4 (Management)

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
  - Lambda 통합

Azure Key Vault:
  - Secrets, Keys, Certificates
  - RBAC 통합

Kubernetes Secrets:
  - Base64 Encoding (암호화 아님!)
  - External Secrets Operator 권장 (Vault 연동)
```

**기능**:
```yaml
비밀 정보 저장:
  - API Key, Database Password
  - Certificate, SSH Key
  - Encryption Key

자동 Rotation:
  - Database Password (3개월)
  - API Key (6개월)
  - Certificate (1년)

접근 제어:
  - 최소 권한 (Least Privilege)
  - TTL (Time to Live)
  - Audit Logging
```

**Function Tags**:
- Primary: `S4.2` (Secrets Management)
- Control: `S4.1` (Encryption at Rest)

**Zone 배치**: Zone 4 (Management)

---

### 4. Monitoring (모니터링)

**대표 도구**:
```yaml
Metrics Collection:
  - Prometheus (오픈소스, CNCF)
  - Datadog
  - New Relic
  - AWS CloudWatch

Visualization:
  - Grafana (오픈소스)
  - Kibana (ELK Stack)
  - Datadog Dashboard

APM (Application Performance Monitoring):
  - Datadog APM
  - New Relic APM
  - Dynatrace
  - Jaeger (분산 추적)
```

**기능**:
```yaml
메트릭 수집:
  - CPU, Memory, Disk, Network
  - Application Metrics (API 응답 시간, 에러율)
  - Database Metrics (쿼리 응답 시간, 커넥션 수)

알람:
  - Threshold Alert (CPU >80%, Disk >90%)
  - Anomaly Detection (평소보다 10배 많은 에러)
  - Service Down Alert

대시보드:
  - 시스템 전체 상태
  - Zone별 트래픽
  - 비즈니스 메트릭 (주문 수, 결제 금액)
```

**Function Tags**:
- Primary: `M1.1` (Metrics Collection)
- Secondary: `M1.2` (Visualization)

**Zone 배치**: Zone 4 (Management)

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
  - Slack, GitHub 통합

Freshservice, Zendesk:
  - SaaS ITSM
  - 중소기업 적합
```

**기능**:
```yaml
Incident Management:
  - 장애 티켓 생성
  - SLA 관리
  - Escalation 룰

Change Management:
  - 변경 요청 (Change Request)
  - 승인 워크플로우
  - Rollback 계획

Knowledge Base:
  - 문제 해결 가이드
  - Runbook
  - FAQ
```

**Function Tags**:
- Primary: `M4.1` (ITSM)

**Zone 배치**: Zone 4 (Management)

---

## 🔐 Zone 4 보안 정책

### 신뢰 수준

```yaml
신뢰 수준: Very High (80%)
  - 가장 엄격한 접근 통제
  - 다중 인증 (MFA) 필수
  - 모든 접근 로깅 및 감사

기본 원칙:
  - Least Privilege (최소 권한)
  - MFA Everywhere (모든 접근 MFA 필수)
  - Audit Everything (모든 활동 로깅)
  - Segregation of Duties (업무 분리)
```

### 네트워크 정책

```yaml
인바운드:
  허용:
    - Zone 1-3, 5 → Zone 4: Syslog, Metrics (로그/메트릭)
    - Zone 5 (관리자) → Zone 4: HTTPS (MFA 인증 후)
  차단:
    - Zone 0-A → Zone 4: 외부 직접 접근 절대 금지

아웃바운드:
  허용:
    - Zone 4 → Zone 1-3, 5: 정책 API (보안 정책 배포)
    - Zone 4 → Zone 0-B: HTTPS (위협 인텔리전스, 업데이트)
  차단:
    - Zone 4 → Zone 0-A: 일반 인터넷 접근 금지
```

### 접근 제어

```yaml
인증:
  - MFA 필수 (TOTP, SMS, Hardware Key)
  - Certificate-based (선택적)
  - IP Allowlist (관리자 사무실)

권한:
  - Security Admin: SIEM, IAM, Secrets 관리
  - Monitoring Admin: Grafana, Prometheus 관리
  - ITSM Admin: ServiceNow 관리
  - 일반 사용자: 읽기 전용 (Dashboard)

세션:
  - 타임아웃: 15분 (비활성 시)
  - 재인증: 2시간마다
  - 자동 로그아웃: 8시간 (업무 시간)
```

---

## 🔄 Zone 4 트래픽 흐름

### 로그 수집 흐름

```
Zone 1 (WAF, Load Balancer) → Syslog → Zone 4 (SIEM)
Zone 2 (API Server) → Syslog → Zone 4 (SIEM)
Zone 3 (Database) → Audit Log → Zone 4 (SIEM)
Zone 5 (Endpoint) → User Activity → Zone 4 (SIEM)

SIEM (Zone 4):
  - 로그 정규화 (Parsing)
  - 위협 탐지 (Rule-based, Anomaly)
  - 알람 생성 (Critical, High, Medium)
  - 대시보드 업데이트
```

### 메트릭 수집 흐름

```
Zone 1-3 (All Services) → Prometheus Exporter
    ↓ HTTP Scraping (Pull 방식)
Prometheus (Zone 4)
    ↓ PromQL 쿼리
Grafana (Zone 4) ← 대시보드 시각화
```

### 위협 인텔리전스 수집

```
외부 위협 인텔리전스 (Zone 0-B: AlienVault, VirusTotal)
    ↓ HTTPS, API Key
SIEM (Zone 4) ← 악성 IP, 취약점 정보
    ↓ 룰 업데이트
WAF (Zone 1) ← 차단 룰 배포
```

---

## 🚫 Zone 4 접근 제어

### 허용되는 연결

| 출발 Zone | 목적 Zone | 프로토콜 | 용도 |
|----------|----------|---------|------|
| Zone 1-3, 5 | Zone 4 | Syslog, Metrics | 로그/메트릭 전송 |
| Zone 5 (관리자) | Zone 4 | HTTPS (MFA) | 관리 콘솔 접근 |
| Zone 4 | Zone 1-3, 5 | 정책 API | 보안 정책 배포 |
| Zone 4 | Zone 0-B | HTTPS | 위협 인텔리전스, 업데이트 |

### 절대 차단되는 연결

| 출발 Zone | 목적 Zone | 이유 |
|----------|----------|------|
| Zone 0-A/0-B | Zone 4 | 외부에서 Management Zone 접근 절대 금지 |
| Zone 5 (일반 사용자) | Zone 4 | 일반 사용자 Management Zone 접근 금지 (관리자만) |
| Zone 4 | Zone 0-A | 일반 인터넷 직접 접근 금지 |

---

## 📊 실전 예시

### 예시 1: 보안 사고 탐지 및 대응

```yaml
시나리오: SQL Injection 공격 시도 탐지

흐름:
  1. 공격자 (Zone 0-A) → SQL Injection 시도
  2. WAF (Zone 1) → 공격 차단 ✅, 로그 전송
  3. SIEM (Zone 4) ← 로그 수신:
     - Source IP: 1.2.3.4
     - Pattern: "' OR '1'='1"
     - Action: Blocked
     - Time: 2025-01-20 14:30:00

  4. SIEM (Zone 4) 분석:
     - 룰 매칭: "SQL Injection Attempt"
     - 심각도: High
     - 동일 IP로부터 5분 내 10회 시도 감지

  5. 알람:
     - PagerDuty → 보안 담당자
     - Slack #security-alerts
     - 이메일 알림

  6. 자동 대응:
     - IP 1.2.3.4 → 블랙리스트 추가 (24시간)
     - WAF (Zone 1)에 차단 룰 배포

  7. Incident 생성:
     - ServiceNow (ITSM - Zone 4)
     - Ticket: INC-2025-0120-001
     - 담당자: 보안팀
```

### 예시 2: 시스템 메트릭 모니터링

```yaml
시나리오: API Server CPU 사용률 급증

흐름:
  1. API Server (Zone 2) → Prometheus Exporter
     - Metric: node_cpu_seconds_total
     - 값: 95% (평소 30%)

  2. Prometheus (Zone 4) ← Scraping (15초 간격)
     - 알람 룰: cpu_usage > 80% for 2 minutes

  3. Grafana (Zone 4) 대시보드:
     - CPU 그래프 급증 시각화
     - 알람 상태: Firing

  4. 알람:
     - PagerDuty → 운영팀
     - Slack #ops-alerts
     - "API Server CPU >80% for 2 minutes"

  5. 조사:
     - Grafana → 상세 메트릭 확인
     - APM (Datadog) → Slow Query 발견
     - Database (Zone 3) → 인덱스 누락 확인

  6. 해결:
     - 인덱스 추가 (ALTER TABLE ADD INDEX)
     - CPU 사용률 정상화 (30%)
     - Incident 종료 (ITSM)
```

### 예시 3: 관리자 접근 감사

```yaml
시나리오: 관리자가 Secrets Manager 접근

흐름:
  1. 관리자 (Zone 5) → Zone 4 (Vault)
     - URL: https://vault.internal.com
     - MFA 인증 요구

  2. IAM (Zone 4) 인증:
     - Username/Password ✅
     - MFA (TOTP) ✅
     - IP Allowlist 확인 ✅

  3. Vault (Zone 4) 접근:
     - 요청: DB Password 조회
     - Policy: vault-admin (읽기/쓰기)

  4. Audit Log 기록:
     - 사용자: admin@example.com
     - 작업: read /secret/database/password
     - 시간: 2025-01-20 15:00:00
     - IP: 192.168.1.100
     - 결과: Success

  5. SIEM (Zone 4) 분석:
     - 정상 접근으로 판단
     - 업무 시간 내 접근
     - 허용된 IP 범위

  6. 정기 리뷰:
     - 분기별 Audit Log 검토
     - 이상 접근 패턴 분석
     - Compliance 리포트 생성
```

---

## 📋 로깅 및 모니터링

### 로그 수집

```yaml
수집 항목:
  - 모든 관리 활동 (IAM, Vault, SIEM)
  - 로그인 이력 (성공, 실패)
  - 권한 변경 로그
  - 보안 정책 배포 이력

보존:
  - 관리 활동: 2년 이상
  - 로그인 실패: 2년 (보안 사고 대비)
  - 보안 사고: 영구 보존

변조 방지:
  - Immutable Logs (수정 불가)
  - Blockchain 기반 무결성 (선택적)
  - 외부 저장소 (S3 - Zone 3)
```

### 알람 정책

```yaml
Critical (즉시 대응):
  - 보안 사고 (SQL Injection, XSS)
  - 시스템 다운 (API Server, Database)
  - 권한 변경 (관리자 계정)

High (30분 내 대응):
  - 이상 로그인 시도 (5회 실패)
  - 리소스 임계값 초과 (CPU >90%)
  - Backup 실패

Medium (1시간 내 검토):
  - 일반 에러 증가 (평소 10배)
  - 디스크 사용량 증가 (>70%)
  - 외부 API 지연 (>1초)
```

---

## ✅ 체크리스트

### 보안

- [ ] MFA 활성화 (모든 관리자)
- [ ] IP Allowlist 설정
- [ ] Audit Log 활성화
- [ ] Secrets Rotation (3-6개월)
- [ ] SIEM 알람 룰 설정

### 모니터링

- [ ] Prometheus + Grafana 대시보드
- [ ] 알람 룰 설정 (CPU, Memory, Disk)
- [ ] APM 연동 (Datadog, New Relic)
- [ ] 로그 보존 정책 (2년 이상)

### 백업

- [ ] Audit Log 일일 백업 (S3)
- [ ] IAM 정책 백업 (Git)
- [ ] Secrets 백업 (암호화 저장)
- [ ] 복구 테스트 (분기별)

---

## 🔗 관련 문서

- [차원 2: Security Zone 개요](./00_차원2_개요.md)
- [Zone 1-3, 5](./00_차원2_개요.md)
- [Layer Cross: Management & Security](../01_차원1_Deployment_Layer/Layer_Cross_Management.md)

---

## 📞 변경 이력

**v2.0 (2025-01-20)** - v2.0 업데이트:
- ✅ Zone 0-B 연동 (위협 인텔리전스)
- ✅ SIEM 위협 탐지 강화
- ✅ IAM MFA 필수화
- ✅ Audit Log 변조 방지

**v1.0** - 초기 작성:
- Zone 4 기본 정의
- SIEM, IAM, Monitoring

---

**문서 끝**
