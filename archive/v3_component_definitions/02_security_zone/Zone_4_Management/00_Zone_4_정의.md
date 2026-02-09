# Zone 4: Management Zone (관리 존)

## 📋 Zone 정보

| 속성 | 값 |
|------|-----|
| **Zone명** | Zone 4 - Management Zone |
| **한글명** | 관리 존 |
| **신뢰 수준** | Highest |
| **공격 노출도** | Lowest |
| **버전** | v1.0.0 |

---

## 🎯 정의

Zone 4는 **시스템 전체의 통제, 모니터링, 보안 관리를 담당하는 최고 신뢰 영역**입니다.

**핵심 역할**:
- **중앙 통제**: 모든 Zone의 보안 정책 관리
- **가시성 확보**: 전체 시스템 모니터링 및 로깅
- **신원 관리**: 사용자 및 서비스 인증/인가
- **비밀 관리**: 암호, 인증서, API 키 중앙 관리

**보안 원칙**:
- **최소 노출**: Zone 0(인터넷)에 절대 직접 노출 금지
- **최소 권한**: 극소수 관리자만 접근 허용
- **완전 감사**: 모든 활동 로깅 및 검토
- **물리적 격리**: 가능한 경우 물리적으로 분리된 네트워크

---

## 🏗️ Zone 4 아키텍처

### 논리적 배치

```
┌─────────────────────────────────────────────┐
│            Zone 4 (Management)              │
│                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│  │   SIEM   │  │   IAM    │  │  Vault   │ │
│  │ (Splunk) │  │(Keycloak)│  │(Secrets) │ │
│  └──────────┘  └──────────┘  └──────────┘ │
│                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│  │Monitoring│  │   ITSM   │  │  Config  │ │
│  │(Prometheus)│ │(ServiceNow)│ │(Consul) │ │
│  └──────────┘  └──────────┘  └──────────┘ │
│                                             │
└─────────────────────────────────────────────┘
              ↕️ 관리 트래픽만
┌─────────────────────────────────────────────┐
│          Zone 1, 2, 3, 5                    │
│         (모든 운영 Zone)                      │
│  ↕️ 위협 인텔리전스 수집 (Zone 0)             │
└─────────────────────────────────────────────┘
```

---

## 📊 배치 구성요소

### Very Common (필수 배치)

| 구성요소 | Layer | 목적 | 주요 제품 |
|---------|-------|------|----------|
| **SIEM** | Cross-Layer | 보안 이벤트 통합 분석 | Splunk, QRadar, Sentinel |
| **IAM** | Cross-Layer | 중앙 인증/인가 | Keycloak, Okta, Auth0 |
| **Secrets Management** | Cross-Layer | 비밀 정보 중앙 관리 | HashiCorp Vault, AWS Secrets Manager |
| **Monitoring** | Cross-Layer | 시스템 전체 모니터링 | Prometheus + Grafana, Datadog |

### Common (자주 배치)

| 구성요소 | Layer | 목적 | 주요 제품 |
|---------|-------|------|----------|
| **ITSM** | Cross-Layer | IT 서비스 관리 | ServiceNow, Jira Service Management |
| **Configuration Management** | Cross-Layer | 설정 중앙 관리 | Consul, etcd, Spring Cloud Config |
| **Backup Server** | Layer 5 | 백업 중앙 관리 | Veeam, Commvault |
| **PKI (Certificate Authority)** | Cross-Layer | 인증서 발급 및 관리 | Let's Encrypt, DigiCert |

### Rare (특수 배치)

| 구성요소 | Layer | 목적 | 사용 사례 |
|---------|-------|------|----------|
| **Security Operations Center (SOC)** | Cross-Layer | 24/7 보안 모니터링 | 대규모 엔터프라이즈 |
| **Privileged Access Management (PAM)** | Cross-Layer | 특권 계정 관리 | 금융, 의료 |
| **Data Loss Prevention (DLP)** | Cross-Layer | 데이터 유출 방지 | 규제 산업 |

---

## 🔐 보안 정책

### 네트워크 정책

```yaml
인바운드 규칙:
  허용:
    - Zone 1-3, 5 → Zone 4: Syslog (UDP 514), Metrics (TCP 9090)
    - 관리자 VPN → Zone 4: SSH (TCP 22), HTTPS (TCP 443)

  차단:
    - Zone 0 (인터넷) → Zone 4: 모든 프로토콜 (절대 차단)
    - Zone 5 (일반 사용자) → Zone 4: 모든 프로토콜

아웃바운드 규칙:
  허용:
    - Zone 4 → Zone 1-3, 5: 정책 배포 API (HTTPS)
    - Zone 4 → Zone 0 (외부): OS 업데이트, SIEM 연동, 위협 인텔리전스 (HTTPS)

  제한:
    - Zone 4 → Zone 0: Proxy를 통한 제한적 접근만
    - Zone 4 → Zone 3: 직접 접근 금지 (Zone 2 경유)
```

### 인증 정책

```yaml
관리자 인증:
  1차: Username + Password (최소 16자, 복잡도 높음)
  2차: MFA (Google Authenticator, YubiKey)
  3차: 디바이스 인증서 (Optional)

세션 관리:
  - 타임아웃: 15분 (비활동 시)
  - 절대 타임아웃: 4시간
  - 재인증: 중요 작업 시 매번 MFA 요구

특권 계정 (Privileged Account):
  - Just-In-Time (JIT) 액세스: 필요 시에만 임시 권한 부여
  - 승인 워크플로: 2명 이상 승인 필요
  - 세션 녹화: 모든 특권 세션 기록
```

### 로깅 정책

```yaml
로그 수집 범위:
  - 모든 로그인 시도 (성공/실패)
  - 모든 정책 변경
  - 모든 시스템 설정 변경
  - 모든 비밀 정보 접근 (Vault)
  - 모든 특권 명령 실행

로그 보존 기간:
  - 최소: 1년
  - 규제 산업: 3-7년
  - 보관: 변조 방지 스토리지 (WORM - Write Once Read Many)

로그 분석:
  - 실시간: SIEM으로 즉시 전송
  - 일일 리뷰: 보안팀 검토
  - 주간 리포트: 관리자 보고
```

### 데이터 취급

```yaml
저장 시 암호화:
  - 알고리즘: AES-256
  - 키 관리: Hardware Security Module (HSM)
  - 백업: 암호화된 상태로 보관

전송 시 암호화:
  - 프로토콜: TLS 1.3 이상
  - 인증서: 자체 PKI 또는 신뢰할 수 있는 CA
  - Perfect Forward Secrecy (PFS) 필수

접근 통제:
  - 역할 기반 (RBAC): Admin, Security Engineer, DevOps
  - 최소 권한: 업무 수행에 필요한 최소한만
  - 정기 검토: 분기별 권한 재검토
```

---

## 🚪 Zone 경계 통제

### Zone 4 → Zone 1-3, 5 (아웃바운드)

```yaml
통제 메커니즘: API Gateway + TLS

허용 트래픽:
  - 정책 배포: IAM → All Zones (HTTPS)
  - 설정 업데이트: Config Server → All Zones (HTTPS)
  - 알림 전송: SIEM → Zone 1 (Webhook)

검증 절차:
  1. API Token 검증
  2. 요청 서명 확인 (HMAC)
  3. 요청 속도 제한 (Rate Limiting)
  4. 로깅 (모든 요청 기록)
```

### Zone 1-3, 5 → Zone 4 (인바운드)

```yaml
통제 메커니즘: Firewall + 로그 수집 Agent

허용 트래픽:
  - 로그 전송: All Zones → SIEM (Syslog, Fluentd)
  - 메트릭 전송: All Zones → Prometheus (Metrics API)
  - 알림 전송: All Zones → ITSM (Webhook)

검증 절차:
  1. 송신자 IP/포트 검증
  2. 데이터 형식 검증 (Schema Validation)
  3. 속도 제한 (DoS 방어)
  4. 로그 무결성 검증 (Hash)
```

### Zone 4 → Zone 0 (외부 연동)

```yaml
통제 메커니즘: Egress Proxy + TLS

허용 트래픽:
  - 위협 인텔리전스 수집: SIEM → 외부 Threat Feed (HTTPS)
  - OS/소프트웨어 업데이트: All Services → 공식 리포지토리 (HTTPS)
  - 외부 SIEM 연동: SIEM → 클라우드 SIEM (HTTPS)

검증 절차:
  1. 목적지 도메인 화이트리스트 검증
  2. TLS 인증서 검증 (Certificate Pinning)
  3. 전송 데이터 검사 (민감 정보 유출 방지)
  4. 모든 아웃바운드 연결 로깅
```

---

## 💡 실전 배치 예시

### 예시 1: Startup (소규모)

```yaml
Zone 4 구성:
  - Monitoring: Prometheus + Grafana (Cloud)
  - IAM: Auth0 (SaaS)
  - Secrets: AWS Secrets Manager (Cloud)
  - SIEM: Datadog Security Monitoring (SaaS)

특징:
  - 클라우드 SaaS 중심 (관리 부담 최소화)
  - 비용: ~$500-1,000/월
  - 인력: DevOps 1명 겸임

보안 수준:
  - ⭐⭐⭐⚪⚪ (중간)
  - MFA 필수, 로그 보존 3개월
```

### 예시 2: Mid-size Company (중견기업)

```yaml
Zone 4 구성:
  - Monitoring: Prometheus + Grafana (Self-hosted)
  - IAM: Keycloak (Self-hosted)
  - Secrets: HashiCorp Vault (Self-hosted)
  - SIEM: Wazuh (Open-source)
  - ITSM: Jira Service Management (Cloud)

특징:
  - 하이브리드 (중요 시스템 Self-hosted)
  - 비용: ~$3,000-5,000/월
  - 인력: Security Engineer 1명, DevOps 2명

보안 수준:
  - ⭐⭐⭐⭐⚪ (높음)
  - MFA + PAM, 로그 보존 1년
```

### 예시 3: Enterprise (대기업)

```yaml
Zone 4 구성:
  - Monitoring: Prometheus + Grafana + Thanos (HA)
  - IAM: Keycloak (HA Cluster)
  - Secrets: HashiCorp Vault (HA + HSM)
  - SIEM: Splunk Enterprise (HA)
  - ITSM: ServiceNow (Enterprise)
  - PAM: CyberArk (Privileged Access)
  - SOC: 24/7 Security Operations Center

특징:
  - 완전 자체 구축 + HA
  - 비용: ~$50,000-100,000/월
  - 인력: Security Team 5명, DevOps Team 10명

보안 수준:
  - ⭐⭐⭐⭐⭐ (최고)
  - MFA + PAM + SOC, 로그 보존 7년
```

---

## 🔄 Zone 4 운영 프로세스

### 일일 운영

```yaml
08:00 - 일일 보안 리뷰:
  - SIEM 알림 검토
  - 전날 로그인 실패 검토
  - 시스템 헬스 체크

12:00 - 정기 점검:
  - 백업 상태 확인
  - 디스크 용량 확인
  - 인증서 만료 확인

18:00 - 주간 준비:
  - 예정된 변경 사항 검토
  - 취약점 스캔 결과 리뷰

24:00 - 자동화:
  - 로그 롤오버
  - 백업 실행
  - 리포트 생성
```

### 주간 운영

```yaml
월요일:
  - 주간 보안 회의
  - 전주 인시던트 리뷰

수요일:
  - 권한 검토 (신규 요청 승인)
  - 정책 변경 배포

금요일:
  - 취약점 스캔 실행
  - 주간 리포트 작성
```

### 월간 운영

```yaml
매월 첫째 주:
  - 패치 관리 (OS, 애플리케이션)
  - 인증서 갱신

매월 셋째 주:
  - 재해 복구 테스트 (DR Drill)
  - 백업 복원 테스트

매월 말:
  - 월간 보안 리포트
  - 비용 분석
```

---

## 📊 Zone 4 모니터링 대시보드

### 핵심 메트릭 (KPI)

```yaml
가용성 (Availability):
  - 목표: 99.9% 이상
  - 측정: Uptime, MTBF (Mean Time Between Failures)

보안 이벤트 (Security Events):
  - 목표: 중요 이벤트 100% 탐지
  - 측정: 탐지율, 오탐률, 평균 대응 시간

로그 손실률 (Log Loss Rate):
  - 목표: 0.01% 이하
  - 측정: 송신 로그 vs. 수신 로그

접근 통제 효율성 (Access Control Effectiveness):
  - 목표: 무단 접근 0건
  - 측정: 로그인 실패율, 비정상 접근 시도
```

### Grafana 대시보드 예시

```yaml
Dashboard 1: 시스템 헬스
  - CPU/Memory/Disk 사용률
  - 네트워크 트래픽
  - 서비스 가용성

Dashboard 2: 보안 이벤트
  - 실시간 알림 (Last 1h)
  - 로그인 실패 Top 10
  - 이상 트래픽 패턴

Dashboard 3: 로그 현황
  - 로그 수집률 (Zone별)
  - 로그 크기 및 보존 현황
  - 로그 손실률

Dashboard 4: IAM 현황
  - 활성 사용자 수
  - 권한 변경 이력
  - MFA 사용률
```

---

## 🚨 Zone 4 인시던트 대응

### 레벨 1: 경미 (Minor)

```yaml
정의: 단일 서비스 장애, 영향 최소

예시:
  - Monitoring Agent 일시 중단
  - 로그 수집 지연 (<5분)

대응:
  1. 자동 복구 시도
  2. 운영팀 알림
  3. 1시간 내 복구

보고: 일일 리포트에 포함
```

### 레벨 2: 중요 (Major)

```yaml
정의: 핵심 서비스 장애, 일부 Zone 영향

예시:
  - SIEM 서버 다운
  - IAM 서비스 장애 (인증 불가)

대응:
  1. 즉시 에스컬레이션
  2. 보안팀 + DevOps 소집
  3. 30분 내 복구 또는 폴백

보고: 즉시 경영진 보고
```

### 레벨 3: 긴급 (Critical)

```yaml
정의: Zone 4 전체 장애 또는 보안 침해

예시:
  - Zone 4 네트워크 단절
  - 무단 접근 탐지
  - 데이터 유출 의심

대응:
  1. 비상 대응팀 소집
  2. 전체 시스템 격리 (필요 시)
  3. 보안 감사 착수
  4. 즉시 복구 또는 재구축

보고: 즉시 경영진 + 규제 기관 보고
```

---

## 🔗 관련 문서

- [Security Zone 개요](../00_Security_Zone_개요.md)
- [Zone 0: External Zone](../Zone_0_External/00_Zone_0_정의.md)
- [Zone 1: Perimeter Zone](../Zone_1_Perimeter/00_Zone_1_정의.md)
- [SIEM 구성요소](../../01_차원1_Deployment_Layer/CrossLayer_Management/04_SIEM/00_SIEM_정의.md)
- [IAM 구성요소](../../01_차원1_Deployment_Layer/CrossLayer_Management/02_IAM/00_IAM_정의.md)
- [Monitoring 구성요소](../../01_차원1_Deployment_Layer/CrossLayer_Management/01_Monitoring/00_Monitoring_정의.md)

---

**문서 끝**
