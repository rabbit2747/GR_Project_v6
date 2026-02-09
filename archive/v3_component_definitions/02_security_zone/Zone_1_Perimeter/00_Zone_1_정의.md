# Zone 1: Perimeter Zone (경계 존)

## 📋 Zone 정보

| 속성 | 값 |
|------|-----|
| **Zone명** | Zone 1 - Perimeter Zone |
| **한글명** | 경계 존 |
| **신뢰 수준** | Low |
| **공격 노출도** | Highest |
| **버전** | v1.0.0 |

---

## 🎯 정의

Zone 1은 **외부 트래픽의 첫 번째 방어선으로, 인터넷과 내부 시스템 사이의 보안 경계**입니다.

**핵심 역할**:
- **트래픽 필터링**: 악의적인 요청 차단 (SQL Injection, XSS 등)
- **부하 분산**: 트래픽을 여러 백엔드 서버로 분산
- **DDoS 방어**: 대규모 공격으로부터 시스템 보호
- **TLS 종료**: HTTPS 암호화/복호화 처리

**보안 원칙**:
- **모든 것을 의심**: 모든 인바운드 트래픽을 잠재적 위협으로 간주
- **심층 방어**: 여러 계층의 보안 통제 적용
- **최소 노출**: 필요한 포트/프로토콜만 허용
- **실시간 모니터링**: 모든 트래픽 로깅 및 분석

---

## 🏗️ Zone 1 아키텍처

### 논리적 배치

```
                     인터넷
                       ↓
┌─────────────────────────────────────────────┐
│          Zone 1 (Perimeter)                 │
│                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│  │   CDN    │  │   WAF    │  │  DDoS    │ │
│  │(Cloudflare)│ │(ModSec) │  │Protection│ │
│  └──────────┘  └──────────┘  └──────────┘ │
│        ↓              ↓              ↓     │
│  ┌────────────────────────────────────┐   │
│  │       Load Balancer (L7)           │   │
│  │        (NGINX, HAProxy)            │   │
│  └────────────────────────────────────┘   │
│                    ↓                       │
└─────────────────────────────────────────────┘
                     ↓ 검증된 트래픽만
┌─────────────────────────────────────────────┐
│          Zone 2 (Application)               │
│              API Servers                    │
└─────────────────────────────────────────────┘
```

---

## 📊 배치 구성요소

### Very Common (필수 배치)

| 구성요소 | Layer | 목적 | 주요 제품 |
|---------|-------|------|----------|
| **WAF** | Layer 2 | 웹 공격 차단 | ModSecurity, AWS WAF, Cloudflare WAF |
| **Load Balancer** | Layer 2 | 트래픽 분산 | NGINX, HAProxy, AWS ALB/NLB |
| **CDN** | Layer 2 | 컨텐츠 캐싱, 가속 | Cloudflare, Akamai, CloudFront |

### Common (자주 배치)

| 구성요소 | Layer | 목적 | 주요 제품 |
|---------|-------|------|----------|
| **Reverse Proxy** | Layer 2 | 요청 라우팅 | NGINX, Apache, Traefik |
| **DDoS Protection** | Layer 2 | DDoS 공격 방어 | Cloudflare, AWS Shield, Arbor Networks |
| **API Gateway** | Layer 7 | API 관리 | Kong, AWS API Gateway, Apigee |

### Rare (특수 배치)

| 구성요소 | Layer | 목적 | 사용 사례 |
|---------|-------|------|----------|
| **VPN Gateway** | Layer 2 | 원격 접근 | 재택 근무 지원 |
| **Email Gateway** | Layer 7 | 이메일 보안 | 스팸/피싱 차단 |
| **CASB (Cloud Access Security Broker)** | Cross-Layer | 클라우드 SaaS 보안 | 규제 산업 |

---

## 🔐 보안 정책

### 네트워크 정책

```yaml
인바운드 규칙:
  허용:
    - 인터넷 → Zone 1: HTTP (TCP 80), HTTPS (TCP 443)
    - Zone 0 → Zone 1: 관리 API (TCP 443)

  차단:
    - 인터넷 → Zone 1: SSH (TCP 22), RDP (TCP 3389)
    - 인터넷 → Zone 1: Database 포트 (3306, 5432, 27017 등)

아웃바운드 규칙:
  허용:
    - Zone 1 → Zone 2: 검증된 HTTP/HTTPS
    - Zone 1 → Zone 0: 로그/메트릭 전송

  차단:
    - Zone 1 → Zone 3: 직접 Database 접근 절대 금지
    - Zone 1 → 인터넷: 불필요한 아웃바운드 연결

Rate Limiting (속도 제한):
  - IP당 요청: 100 req/sec
  - 전체: 10,000 req/sec
  - 동일 IP 반복 실패: 10회 → 10분 차단
```

### 인증 정책

```yaml
API Key/Token 검증:
  - Authorization 헤더 검증
  - JWT Token 서명 확인 (공개키 검증만)
  - API Key 블랙리스트 확인

IP 기반 통제:
  - Whitelist: 신뢰할 수 있는 IP (파트너사, 사무실)
  - Blacklist: 악의적 IP (위협 인텔리전스 연동)
  - GeoIP: 특정 국가 차단 (선택적)

Bot 탐지:
  - User-Agent 검증
  - CAPTCHA (의심스러운 트래픽)
  - 행동 패턴 분석
```

### 로깅 정책

```yaml
로그 수집 범위:
  - 모든 HTTP 요청/응답 (헤더 + 상태 코드)
  - 차단된 요청 (WAF 룰 포함)
  - TLS 핸드셰이크 실패
  - Rate Limiting 초과

로그 보존 기간:
  - 정상 트래픽: 30일
  - 차단 트래픽: 90일
  - 분석: 실시간 SIEM 전송

로그 형식:
  - 표준: Common Log Format (CLF) 또는 JSON
  - 필수 필드: timestamp, client_ip, method, uri, status, user_agent
```

### 데이터 취급

```yaml
TLS/SSL 설정:
  - 최소 버전: TLS 1.2 (권장: TLS 1.3)
  - 암호화 스위트: ECDHE-RSA-AES256-GCM-SHA384
  - HSTS (Strict-Transport-Security): 활성화
  - Certificate Pinning: 고위험 애플리케이션

민감 데이터 처리:
  - 요청 본문 로깅 금지 (민감 데이터 포함 시)
  - PII 마스킹: 로그에서 이메일, 전화번호 등 마스킹
  - Cache-Control: 민감 데이터 캐싱 금지
```

---

## 🚪 Zone 경계 통제

### 인터넷 → Zone 1 (인바운드)

```yaml
통제 메커니즘: WAF + DDoS Protection + CDN

필터링 순서:
  1. DDoS Protection: 대규모 공격 차단
  2. IP Blacklist: 악의적 IP 즉시 차단
  3. CDN Cache: 정적 컨텐츠 캐시 응답
  4. WAF Rules: OWASP Top 10 공격 차단
  5. Rate Limiting: 속도 제한 적용
  6. Load Balancer: 백엔드로 전달

WAF 룰셋:
  - SQL Injection (SQLi)
  - Cross-Site Scripting (XSS)
  - Remote Code Execution (RCE)
  - Local File Inclusion (LFI)
  - Command Injection
  - 사용자 정의 룰
```

### Zone 1 → Zone 2 (아웃바운드)

```yaml
통제 메커니즘: 내부 Firewall + Proxy

검증 절차:
  1. 트래픽 유형 확인 (HTTP/HTTPS만)
  2. 목적지 확인 (Zone 2 서버만)
  3. 헤더 정규화 (보안 헤더 추가)
  4. 요청 크기 제한 (DoS 방어)

추가 보안 헤더:
  - X-Forwarded-For: 원본 IP 기록
  - X-Real-IP: 클라이언트 실제 IP
  - X-Request-ID: 요청 추적용 UUID
```

---

## 💡 실전 배치 예시

### 예시 1: Startup (소규모)

```yaml
Zone 1 구성:
  - CDN: Cloudflare (Free Plan)
  - WAF: Cloudflare WAF (Integrated)
  - Load Balancer: NGINX (1대, Self-hosted)

트래픽:
  - ~1,000 req/min
  - 대역폭: ~100GB/월

비용:
  - Cloudflare Free: $0
  - NGINX Server: ~$50/월 (AWS t3.medium)
  - 총: ~$50/월

특징:
  - 클라우드 SaaS 중심
  - 기본 WAF 룰 적용
  - 수동 IP 차단

보안 수준: ⭐⭐⭐⚪⚪
```

### 예시 2: Mid-size Company (중견기업)

```yaml
Zone 1 구성:
  - CDN: Cloudflare Pro
  - WAF: AWS WAF (Managed Rules)
  - Load Balancer: AWS ALB (Application Load Balancer) 2대
  - DDoS Protection: AWS Shield Standard

트래픽:
  - ~10,000 req/min
  - 대역폭: ~1TB/월

비용:
  - Cloudflare Pro: $200/월
  - AWS WAF: ~$100/월
  - AWS ALB: ~$300/월
  - 총: ~$600/월

특징:
  - 하이브리드 (CDN + AWS)
  - 관리형 WAF 룰 자동 업데이트
  - 실시간 대시보드

보안 수준: ⭐⭐⭐⭐⚪
```

### 예시 3: Enterprise (대기업)

```yaml
Zone 1 구성:
  - CDN: Akamai (Enterprise)
  - WAF: Imperva SecureSphere (On-premise)
  - Load Balancer: F5 BIG-IP (HA Pair)
  - DDoS Protection: Arbor Networks (Dedicated)
  - Bot Management: DataDome

트래픽:
  - ~100,000 req/min
  - 대역폭: ~10TB/월

비용:
  - Akamai: ~$5,000/월
  - Imperva: ~$3,000/월
  - F5 BIG-IP: ~$2,000/월 (라이센스)
  - Arbor Networks: ~$5,000/월
  - DataDome: ~$2,000/월
  - 총: ~$17,000/월

특징:
  - 엔터프라이즈급 장비
  - 24/7 SOC 모니터링
  - AI 기반 Bot 탐지
  - 글로벌 PoP (Point of Presence)

보안 수준: ⭐⭐⭐⭐⭐
```

---

## 🔄 Zone 1 트래픽 패턴

### 정상 트래픽 흐름

```
사용자 (전 세계)
    ↓ DNS Resolution
CDN Edge (가장 가까운 PoP)
    ↓ Cache Miss
Origin Shield (리전별 캐시)
    ↓ Cache Miss
WAF (보안 검사)
    ↓ 통과
Load Balancer (L7 라우팅)
    ↓ 헬스 체크된 서버로
Zone 2 (API Server)
    ↑ 응답 (200 OK)
사용자
```

### 공격 트래픽 차단

```
공격자
    ↓ 대량 요청
DDoS Protection (100,000 req/sec 탐지)
    ↓ 차단 (Challenge 페이지)
공격자 (CAPTCHA 실패)
    ❌ 차단

또는

공격자
    ↓ SQL Injection 시도
CDN (통과)
    ↓
WAF (SELECT * FROM users 탐지)
    ↓ 차단 (403 Forbidden)
공격자 (차단 페이지)
    ❌ 차단 + IP 블랙리스트
```

---

## 🚨 Zone 1 인시던트 대응

### 시나리오 1: DDoS 공격

```yaml
탐지:
  - 비정상적 트래픽 급증 (10배 이상)
  - CDN/DDoS Protection 알림

대응:
  1. 자동: Rate Limiting 강화
  2. 자동: Challenge 페이지 활성화
  3. 수동: 공격 패턴 분석
  4. 수동: IP 범위 차단 (필요 시)

복구:
  - 트래픽 정상화 확인
  - 차단 규칙 점진적 완화
  - 사후 분석 리포트

평균 대응 시간: 5-15분
```

### 시나리오 2: Zero-Day 공격

```yaml
탐지:
  - WAF에서 새로운 공격 패턴 탐지
  - 또는 외부 보안 권고 (CVE)

대응:
  1. 긴급: Virtual Patching (WAF 룰 추가)
  2. 임시: 의심스러운 요청 차단
  3. 영구: 애플리케이션 패치 (Zone 2)

예시:
  - CVE-2021-44228 (Log4Shell)
  - WAF 룰: jndi:ldap:// 패턴 차단
  - 애플리케이션: Log4j 업데이트

평균 대응 시간: 1-4시간
```

### 시나리오 3: TLS 인증서 만료

```yaml
탐지:
  - 만료 30일 전 알림
  - 만료 7일 전 경고
  - 만료 1일 전 긴급 알림

대응:
  1. 자동: Let's Encrypt 자동 갱신
  2. 수동: 상용 인증서 갱신
  3. 배포: 무중단 인증서 교체

예방:
  - 인증서 만료 모니터링
  - 자동 갱신 설정
  - 백업 인증서 준비

평균 대응 시간: 즉시 (자동) 또는 1-2시간 (수동)
```

---

## 📊 Zone 1 모니터링 메트릭

### 핵심 메트릭 (KPI)

```yaml
트래픽 메트릭:
  - Requests per Second (RPS)
  - Bandwidth (Mbps)
  - Cache Hit Rate (%)

성능 메트릭:
  - Response Time (ms): p50, p95, p99
  - SSL/TLS Handshake Time (ms)
  - Backend Connection Time (ms)

보안 메트릭:
  - Blocked Requests (count, %)
  - WAF Rule Triggers (by rule)
  - DDoS Attacks Mitigated

가용성 메트릭:
  - Uptime (%)
  - Error Rate (4xx, 5xx)
  - Backend Health (up/down)
```

### Grafana 대시보드 예시

```yaml
Dashboard 1: 실시간 트래픽
  - RPS (Last 5min)
  - 지역별 트래픽 지도
  - Top 10 요청 경로

Dashboard 2: 보안 이벤트
  - 차단된 요청 (실시간)
  - WAF 룰별 트리거 횟수
  - 블랙리스트 IP Top 10

Dashboard 3: 성능
  - Response Time (p50, p95, p99)
  - Cache Hit Rate
  - Backend Health 상태

Dashboard 4: 에러 분석
  - 4xx/5xx 에러 비율
  - Top 10 에러 경로
  - 에러 타입별 분포
```

---

## 🔧 Zone 1 최적화 기법

### CDN 최적화

```yaml
캐싱 전략:
  - 정적 파일: 1년 (immutable)
  - HTML: 5분 (revalidate)
  - API: No-Cache

압축:
  - Gzip: 텍스트 파일 (HTML, CSS, JS)
  - Brotli: 최신 브라우저
  - 압축률: ~70-80%

HTTP/3 (QUIC):
  - 0-RTT 연결
  - 멀티플렉싱
  - 패킷 손실 복구
```

### WAF 최적화

```yaml
룰 튜닝:
  - False Positive 분석
  - 화이트리스트 예외 추가
  - 중복 룰 제거

성능 최적화:
  - 빠른 룰 우선 배치
  - 정규식 최적화
  - 룰 그룹 병렬 처리

자동화:
  - 위협 인텔리전스 연동
  - Machine Learning 기반 탐지
```

### Load Balancer 최적화

```yaml
알고리즘:
  - Round Robin: 기본
  - Least Connections: 연결 기반
  - IP Hash: 세션 유지

Health Check:
  - 간격: 5초
  - 실패 임계값: 3회
  - 타임아웃: 2초

Keep-Alive:
  - 백엔드 연결 재사용
  - 타임아웃: 60초
  - 최대 요청: 100 req/connection
```

---

## 🔗 관련 문서

- [Security Zone 개요](../00_Security_Zone_개요.md)
- [Zone 0: Management Zone](../Zone_0_Management/00_Zone_0_정의.md)
- [Zone 2: Application Zone](../Zone_2_Application/00_Zone_2_정의.md)
- [WAF 구성요소](../../01_차원1_Deployment_Layer/Layer_2_Network/03_WAF/00_WAF_정의.md)
- [Load Balancer 구성요소](../../01_차원1_Deployment_Layer/Layer_2_Network/01_Load_Balancer/00_Load_Balancer_정의.md)
- [CDN 구성요소](../../01_차원1_Deployment_Layer/Layer_2_Network/06_CDN/00_CDN_정의.md)

---

**문서 끝**
