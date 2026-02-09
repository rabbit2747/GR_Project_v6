# Zone 1: Perimeter (경계 영역)

## 📋 문서 정보

**Zone**: 1 - Perimeter
**영문명**: Perimeter Zone
**한글명**: 경계 영역
**위치**: 외부와 내부의 경계
**신뢰 수준**: Low (20%)
**작성일**: 2025-01-20

---

## 🎯 Zone 정의

### 개요

**Zone 1 (Perimeter)**는 **외부(Zone 0-A/0-B)와 내부 네트워크 간의 첫 번째 방어선**입니다.

```yaml
핵심 역할:
  - 외부 트래픽 필터링 및 검증
  - DDoS 공격 방어
  - 웹 애플리케이션 방화벽 (WAF)
  - 로드 밸런싱
  - SSL/TLS 종료
  - 신뢰 수준: 20% (낮은 신뢰)
```

### 방어선 역할

```yaml
Zone 0-A (완전 비신뢰) → Zone 1 (경계) → Zone 2 (애플리케이션)
                          ↑
                    첫 번째 방어선
                    - 위협 필터링
                    - 트래픽 검증
                    - Rate Limiting
```

---

## 📦 Zone 1 구성요소

### 1. WAF (Web Application Firewall)

**대표 서비스**:
```yaml
클라우드 WAF:
  - Cloudflare WAF
  - AWS WAF
  - Azure Application Gateway + WAF
  - Fastly Next-Gen WAF

Self-Hosted:
  - ModSecurity (NGINX/Apache)
  - NAXSI (NGINX)
```

**기능**:
```yaml
OWASP Top 10 방어:
  - SQL Injection 차단
  - XSS (Cross-Site Scripting) 차단
  - CSRF (Cross-Site Request Forgery) 차단
  - Path Traversal 차단
  - Remote Code Execution 차단

Rate Limiting:
  - per IP: 100 req/min
  - per Endpoint: 1000 req/min
  - per User (인증 후): 500 req/min

Bot Management:
  - 악성 봇 차단
  - 검색 엔진 봇 허용 (Googlebot, Bingbot)
  - CAPTCHA Challenge
```

**Function Tags**:
- Primary: `S5.2` (WAF - Web Application Firewall)
- Secondary: `S9.2` (Threat Detection)

**Zone 배치**: Zone 1 (Perimeter)

---

### 2. Load Balancer (로드 밸런서)

**대표 서비스**:
```yaml
클라우드:
  - AWS ELB (ALB, NLB)
  - Azure Load Balancer
  - Google Cloud Load Balancing

Self-Hosted:
  - NGINX
  - HAProxy
  - Traefik
```

**기능**:
```yaml
트래픽 분산:
  - Round Robin
  - Least Connections
  - IP Hash
  - Weighted Round Robin

헬스 체크:
  - HTTP Health Check (예: GET /health)
  - TCP Health Check
  - 비정상 인스턴스 자동 제외

SSL/TLS 종료:
  - TLS 1.2, 1.3
  - Certificate 관리
  - SNI (Server Name Indication)
```

**Function Tags**:
- Primary: `N2.2` (Load Balancing)
- Secondary: `R3.1` (High Availability)

**Zone 배치**: Zone 1 (Perimeter)

---

### 3. Reverse Proxy

**대표 도구**:
```yaml
NGINX:
  - 고성능 Reverse Proxy
  - 정적 콘텐츠 서빙
  - Rate Limiting

Apache HTTP Server:
  - mod_proxy
  - mod_rewrite
```

**기능**:
```yaml
요청 라우팅:
  - /api/* → API Server (Zone 2)
  - /static/* → CDN (Zone 0-B)
  - / → Frontend Server (Zone 2)

캐싱:
  - 정적 콘텐츠 캐싱 (이미지, CSS, JS)
  - 캐시 만료 시간 설정
  - Cache-Control 헤더

헤더 조작:
  - X-Forwarded-For 추가
  - X-Real-IP 추가
  - CORS 헤더 설정
```

**Function Tags**:
- Primary: `N2.1` (Reverse Proxy)
- Secondary: `P1.1` (Performance - Caching)

---

### 4. CDN (Content Delivery Network)

**대표 서비스**:
```yaml
글로벌 CDN:
  - Cloudflare
  - Fastly
  - Akamai
  - AWS CloudFront
```

**기능**:
```yaml
정적 콘텐츠 배포:
  - 이미지, CSS, JavaScript
  - 글로벌 Edge 서버 캐싱
  - 지연 시간 감소 (Latency Reduction)

보안:
  - DDoS 방어 (Layer 3/4/7)
  - WAF 통합
  - SSL/TLS 종료

성능 최적화:
  - HTTP/2, HTTP/3 지원
  - Brotli 압축
  - 이미지 최적화 (WebP)
```

**Function Tags**:
- Primary: `N3.1` (CDN)
- Secondary: `S5.1` (DDoS Protection)

**Zone 배치**: Zone 1 또는 Zone 0-B (SaaS CDN)

---

### 5. DDoS Protection

**대표 서비스**:
```yaml
클라우드:
  - Cloudflare DDoS Protection
  - AWS Shield (Standard, Advanced)
  - Azure DDoS Protection

기능:
  - Layer 3/4 공격 방어 (SYN Flood, UDP Flood)
  - Layer 7 공격 방어 (HTTP Flood)
  - 자동 Mitigation
  - Rate Limiting
```

**Function Tags**:
- Primary: `S5.1` (DDoS Protection)

**Zone 배치**: Zone 1 (Perimeter)

---

## 🔐 Zone 1 보안 정책

### 신뢰 수준

```yaml
신뢰 수준: Low (20%)
  - Zone 0의 모든 트래픽을 잠재적 위협으로 간주
  - 심층 검사 및 필터링 필수
  - 검증된 트래픽만 Zone 2로 전달

기본 원칙:
  - Zero Trust: 모든 요청 검증
  - Defense in Depth: 다층 방어
  - Fail Secure: 오류 시 차단 (Allow 대신 Deny)
```

### 네트워크 정책

```yaml
인바운드:
  허용:
    - Zone 0-A/0-B → Zone 1: HTTP/HTTPS (80, 443)
  차단:
    - 비표준 포트
    - 알려진 악성 IP
    - Rate Limit 초과

아웃바운드:
  허용:
    - Zone 1 → Zone 2: HTTP/HTTPS (검증된 트래픽)
    - Zone 1 → Zone 4: Logs/Metrics (Syslog, Prometheus)
  차단:
    - Zone 1 → Zone 3 직접 접근 절대 금지
    - Zone 1 → Zone 5 직접 접근 금지
```

---

## 🔄 Zone 1 트래픽 흐름

### 정상 요청 흐름

```
인터넷 사용자 (Zone 0-A)
    ↓ HTTPS (443)
DDoS Protection (Zone 1) ← SYN Flood 방어, Rate Limiting
    ↓
WAF (Zone 1) ← SQL Injection 체크, XSS 차단
    ↓
Load Balancer (Zone 1) ← SSL 종료, 헬스 체크
    ↓
Reverse Proxy (Zone 1) ← 라우팅 (/api → API Server)
    ↓ HTTP (검증된 트래픽)
API Server (Zone 2)
```

### 공격 차단 흐름

```
공격자 (Zone 0-A)
    ↓ DDoS 공격 (초당 10만 요청)
DDoS Protection (Zone 1)
    ↓ 자동 Mitigation
    ↓ CAPTCHA Challenge
    ❌ 차단

공격자 (Zone 0-A)
    ↓ SQL Injection 시도
WAF (Zone 1)
    ↓ 악성 패턴 감지
    ❌ 차단, IP 블랙리스트 추가
```

---

## 🚫 Zone 1 접근 제어

### 허용되는 연결

| 출발 Zone | 목적 Zone | 프로토콜 | 용도 |
|----------|----------|---------|------|
| Zone 0-A/0-B | Zone 1 | HTTPS (443) | 웹 트래픽 |
| Zone 1 | Zone 2 | HTTP/HTTPS | 검증된 트래픽 전달 |
| Zone 1 | Zone 4 | Syslog, Metrics | 로그/메트릭 전송 |
| Zone 0-B (CDN) | Zone 1 | HTTPS | Origin Server 요청 |

### 차단되는 연결

| 출발 Zone | 목적 Zone | 이유 |
|----------|----------|------|
| Zone 0-A | Zone 2 | 외부에서 직접 App Server 접근 금지 |
| Zone 0-A | Zone 3 | 외부에서 직접 Database 접근 금지 |
| Zone 1 | Zone 3 | Perimeter에서 직접 Data Zone 접근 금지 |
| Zone 1 | Zone 5 | Perimeter에서 Endpoint 직접 접근 금지 |

---

## 📊 실전 예시

### 예시 1: 일반 웹사이트 접근

```yaml
시나리오: 사용자가 https://example.com 접속

흐름:
  1. 사용자 (Zone 0-A) → Cloudflare DDoS Protection (Zone 1)
     - Rate Limit 체크 ✅
     - IP Reputation 체크 ✅

  2. Cloudflare WAF (Zone 1)
     - OWASP 룰 체크 ✅
     - Bot Detection ✅

  3. AWS ALB (Zone 1)
     - SSL 종료 (TLS 1.3)
     - 헬스 체크 ✅
     - Target Group → NGINX (Zone 2)

  4. NGINX Reverse Proxy (Zone 1)
     - /api → API Server (Zone 2)
     - / → Frontend Server (Zone 2)

결과: 정상 전달 ✅
```

### 예시 2: SQL Injection 공격

```yaml
시나리오: 공격자가 SQL Injection 시도

요청:
  GET https://example.com/api/user?id=1' OR '1'='1

흐름:
  1. Cloudflare DDoS Protection (Zone 1)
     - Rate Limit 체크 ✅

  2. Cloudflare WAF (Zone 1)
     - SQL Injection 패턴 감지 ❌
     - 룰: "' OR '1'='1" → 차단
     - IP 주소 블랙리스트 추가 (1시간)

  3. SIEM (Zone 4)로 알림
     - 공격 유형: SQL Injection
     - 출발 IP: 1.2.3.4
     - 차단 시간: 2025-01-20 14:30:00

결과: 차단 ❌, 로그 기록
```

### 예시 3: CDN → Origin Server

```yaml
시나리오: CDN에서 정적 콘텐츠 미스, Origin Server 요청

흐름:
  1. Cloudflare CDN (Zone 0-B) → Zone 1 (Origin Server)
     - IP Allowlist 확인 (Cloudflare IP 범위)
     - Cache-Control: public, max-age=3600

  2. NGINX Reverse Proxy (Zone 1)
     - /static/* → Static File Server (Zone 2)
     - 파일 반환 (이미지, CSS)

  3. Cloudflare CDN (Zone 0-B)
     - 파일 캐싱 (Edge 서버)
     - TTL: 1시간

결과: 다음 요청부터 CDN 캐시 Hit ✅
```

---

## 🔒 데이터 취급 원칙

### Zone 1에서 처리 가능한 데이터

```yaml
허용:
  - HTTP 헤더, 쿼리 파라미터
  - 요청 Body (검증 목적)
  - SSL/TLS 메타데이터
  - 로그 (IP, User-Agent, URL)

금지:
  - 민감 데이터 캐싱 (세션, 토큰)
  - 요청 Body 장기 저장
  - PII 데이터 로깅 (이메일, 전화번호)
```

### 로깅 정책

```yaml
수집:
  - 모든 요청/응답 로그
  - WAF 룰 매칭 결과
  - 차단된 IP 목록
  - DDoS 공격 이력

보존:
  - 정상 트래픽: 30일
  - 차단된 트래픽: 90일
  - 보안 사고: 1년 이상

전송:
  - SIEM (Zone 4): 실시간
  - Object Storage (Zone 3): 일일 배치
```

---

## ✅ 체크리스트

### 보안

- [ ] WAF 규칙 적용 (OWASP Top 10)
- [ ] DDoS Protection 활성화
- [ ] Rate Limiting 설정 (per IP, per Endpoint)
- [ ] SSL/TLS 1.2+ 적용
- [ ] HSTS 헤더 설정

### 성능

- [ ] CDN 캐싱 설정
- [ ] HTTP/2 활성화
- [ ] 정적 콘텐츠 압축 (Gzip, Brotli)
- [ ] 헬스 체크 설정 (Load Balancer)

### 모니터링

- [ ] 트래픽 대시보드 (Grafana)
- [ ] SIEM 연동 (Zone 4)
- [ ] 알람 설정 (DDoS, WAF Block)
- [ ] 로그 보존 정책 (30일)

---

## 🔗 관련 문서

- [차원 2: Security Zone 개요](./00_차원2_개요.md)
- [Zone 0-A: Untrusted External](./Zone_0-A_Untrusted.md)
- [Zone 0-B: Trusted Partner](./Zone_0-B_Trusted_Partner.md)
- [Zone 2: Application Zone](./Zone_2_Application.md)
- [Layer 2: Network Infrastructure](../01_차원1_Deployment_Layer/Layer_2_Network.md)

---

## 📞 변경 이력

**v2.0 (2025-01-20)** - v2.0 업데이트:
- ✅ Zone 0 세분화 반영 (0-A, 0-B → Zone 1)
- ✅ 트래픽 흐름 업데이트
- ✅ DDoS Protection, WAF, CDN 상세 정의
- ✅ 실전 예시 추가 (SQL Injection 차단, CDN 흐름)

**v1.0** - 초기 작성:
- Zone 1 기본 정의
- Perimeter 구성요소

---

**문서 끝**
