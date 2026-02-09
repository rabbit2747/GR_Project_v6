# Layer 2: Network Infrastructure (네트워크 인프라)

## 📋 문서 정보

**Layer**: 2 - Network Infrastructure
**영문명**: Network Infrastructure
**한글명**: 네트워크 인프라
**위치**: 하단 계층
**목적**: 네트워크 연결, 라우팅, 보안 제공
**작성일**: 2025-01-20

---

## 🎯 Layer 정의

### 개요

**Layer 2 (Network Infrastructure)**는 시스템 간 **네트워크 통신과 보안 경계**를 제공하는 계층입니다.

### 핵심 개념

```yaml
핵심 특징:
  - 네트워크 트래픽 라우팅 및 필터링
  - Zone 경계 제어 핵심 계층
  - 부하 분산 및 고가용성
  - 변경 빈도: Medium (월 단위)

주요 역할:
  - Load Balancing (트래픽 분산)
  - Firewall (네트워크 보안)
  - Reverse Proxy (SSL Termination, Caching)
  - VPN (원격 접속)
  - CDN (콘텐츠 배포)
```

---

## 📦 Network Infrastructure 구성요소

### 1. Load Balancer (로드 밸런서)

**정의**: 트래픽을 여러 서버로 분산하여 가용성과 성능 향상

**유형**:
```yaml
Layer 4 (L4) Load Balancer:
  - Transport Layer (TCP/UDP)
  - 빠른 처리 속도
  - 대표: F5 BIG-IP, HAProxy, AWS NLB

Layer 7 (L7) Load Balancer:
  - Application Layer (HTTP/HTTPS)
  - URL 기반 라우팅, Header 조작
  - 대표: Nginx, HAProxy, AWS ALB, Google Cloud Load Balancing

Global Load Balancer:
  - DNS 기반 지리적 분산
  - 대표: AWS Route53, Cloudflare Load Balancing
```

**Function Tags**:
- Primary: `N1.1` (L4 Load Balancing), `N1.2` (L7 Load Balancing)
- Secondary: `S5.1` (SSL/TLS Termination), `R3.1` (Health Check)

**Zone 배치**:
- Zone 1 (Perimeter) - 외부 트래픽 수신
- Zone 2 (Application) - 내부 마이크로서비스 간 분산

---

### 2. Firewall (방화벽)

**정의**: 네트워크 트래픽을 검사하고 차단하는 보안 장비

**유형**:
```yaml
Traditional Firewall:
  - Stateful Packet Inspection
  - 포트/IP 기반 필터링
  - 대표: Cisco ASA, Palo Alto

Next-Gen Firewall (NGFW):
  - Deep Packet Inspection
  - Application Awareness
  - IDS/IPS 통합
  - 대표: Palo Alto PA-Series, Fortinet FortiGate

Web Application Firewall (WAF):
  - Layer 7 공격 방어
  - OWASP Top 10 보호
  - 대표: Cloudflare WAF, AWS WAF, F5 ASM
```

**Function Tags**:
- Primary: `S1.1` (Network Firewall), `S1.2` (WAF)
- Control: `S1.3` (DDoS Protection), `S1.4` (IPS/IDS)

**Zone 배치**: Zone 1 (Perimeter)

---

### 3. Reverse Proxy (리버스 프록시)

**정의**: 클라이언트와 백엔드 서버 사이에서 요청을 중계

**대표 기술**:
```yaml
Nginx:
  - 고성능 HTTP 서버
  - SSL Termination
  - Static File Serving
  - Caching

Apache HTTP Server:
  - mod_proxy 모듈
  - Flexible Configuration

Envoy:
  - Service Mesh Proxy
  - Kubernetes 환경
  - gRPC 지원

Caddy:
  - 자동 HTTPS (Let's Encrypt)
  - 간편한 설정
```

**Function Tags**:
- Primary: `N2.1` (Reverse Proxy)
- Secondary: `S5.1` (SSL/TLS Termination), `D2.5` (Static Content Caching)
- Interface: `I1.1` (HTTP/HTTPS)

**Zone 배치**: Zone 1 (Perimeter) or Zone 2 (Application)

---

### 4. VPN Gateway (VPN 게이트웨이)

**정의**: 원격 사용자 또는 사이트 간 암호화 통신 제공

**유형**:
```yaml
Site-to-Site VPN:
  - 지사 간 연결
  - IPsec, GRE Tunnel
  - 대표: Cisco ASA, AWS VPN Gateway

Remote Access VPN:
  - 원격 근무자 접속
  - SSL VPN, IPsec VPN
  - 대표: OpenVPN, Pulse Secure, Cisco AnyConnect

Zero Trust Network Access (ZTNA):
  - 차세대 VPN 대체
  - Identity-based Access
  - 대표: Zscaler Private Access, Cloudflare Access
```

**Function Tags**:
- Primary: `N5.1` (VPN Tunnel)
- Control: `S5.2` (Encrypted Communication)

**Zone 배치**: Zone 1 (Perimeter)

---

### 5. CDN (Content Delivery Network)

**정의**: 글로벌 분산 네트워크를 통한 콘텐츠 배포

**대표 서비스**:
```yaml
글로벌 CDN:
  - Cloudflare (WAF 통합, DDoS 방어)
  - Fastly (Real-time CDN)
  - Akamai (Enterprise CDN)
  - AWS CloudFront

주요 기능:
  - Edge Caching (지연 시간 감소)
  - DDoS Protection
  - Image Optimization
  - Geo-blocking
```

**Function Tags**:
- Primary: `N3.1` (Content Caching)
- Secondary: `S1.3` (DDoS Protection), `D2.2` (Edge Caching)
- Control: `S7.1` (Geo-blocking)

**Zone 배치**:
- Layer 0 (External) - Cloudflare, Fastly (SaaS CDN)
- Layer 2 (Network) - 자체 구축 CDN

---

### 6. DNS (Domain Name System)

**정의**: 도메인 이름을 IP 주소로 변환

**유형**:
```yaml
Authoritative DNS:
  - 도메인 레코드 관리
  - 대표: AWS Route53, Cloudflare DNS, BIND

Recursive Resolver:
  - DNS 질의 처리
  - 대표: Google Public DNS (8.8.8.8), Cloudflare DNS (1.1.1.1)

Private DNS:
  - 내부 네트워크 전용
  - AWS Route53 Private Hosted Zone
```

**Function Tags**:
- Primary: `N3.2` (DNS Resolution)
- Secondary: `N1.3` (Global Load Balancing - DNS 기반)

**Zone 배치**:
- Zone 0-B (External) - Public DNS (Cloudflare, Route53)
- Zone 4 (Management) - Private DNS

---

## 🔒 Security Zone 경계 제어

**Layer 2는 Zone 간 경계 제어의 핵심 계층**입니다.

### Zone 0-A → Zone 1 (인터넷 → 경계)

```yaml
보안 통제:
  - DDoS Protection (Rate Limiting, Traffic Shaping)
  - WAF (OWASP Top 10 방어)
  - NGFW (Application-level Filtering)
  - Geo-blocking (국가별 차단)

구성요소:
  - Cloudflare WAF + DDoS
  - Palo Alto NGFW
  - AWS Shield (DDoS)
```

### Zone 0-B → Zone 1 (Trusted Partner → 경계)

```yaml
보안 통제:
  - API Key 검증
  - IP Allowlist
  - TLS 1.2+ (mTLS 권장)
  - Rate Limiting (per API Key)

구성요소:
  - API Gateway (AWS API Gateway, Kong)
  - Nginx + Lua Script (IP Allowlist)
```

### Zone 1 → Zone 2 (경계 → 애플리케이션)

```yaml
보안 통제:
  - WAF (SQLi, XSS 방어)
  - Rate Limiting (per IP)
  - IPS/IDS
  - SSL/TLS Termination

구성요소:
  - ALB + WAF
  - Nginx Reverse Proxy
```

---

## 🛡️ 보안 고려사항

### 1. DDoS 방어

```yaml
Layer별 방어:
  Layer 3/4 DDoS:
    - SYN Flood, UDP Flood
    - 방어: Rate Limiting, SYN Cookie

  Layer 7 DDoS:
    - HTTP Flood, Slowloris
    - 방어: WAF, Challenge (Captcha)

권장 구성:
  - Cloudflare DDoS Protection (자동)
  - AWS Shield Standard (무료)
  - AWS Shield Advanced ($3,000/month, 고급 보호)
```

### 2. SSL/TLS 설정

```yaml
권장 설정:
  Protocol: TLS 1.2, TLS 1.3 only
  Cipher Suite:
    - ECDHE-RSA-AES256-GCM-SHA384
    - ECDHE-RSA-AES128-GCM-SHA256

인증서:
  - Let's Encrypt (무료, 자동 갱신)
  - DigiCert, Sectigo (유료, EV 인증서)

HSTS (HTTP Strict Transport Security):
  - max-age=31536000; includeSubDomains; preload
```

### 3. Zero Trust 원칙

```yaml
원칙:
  - 모든 네트워크 트래픽 검증
  - Zone 간 이동 시 재인증
  - Least Privilege (최소 권한)

구현:
  - Micro-Segmentation (Zone 세분화)
  - Service Mesh (Istio, Linkerd)
  - Identity-based Access
```

---

## 📊 실전 예시

### 예시 1: E-Commerce 플랫폼 Layer 2

```yaml
인터넷 (Zone 0-A)
  ↓
Cloudflare CDN + WAF + DDoS Protection (Layer 0)
  ↓
AWS ALB (Layer 2, Zone 1)
  - SSL/TLS Termination
  - WAF Rules (SQLi, XSS)
  - Health Check
  ↓
Nginx Reverse Proxy (Layer 2, Zone 1 → Zone 2)
  - Static File Serving
  - Caching (Redis)
  - Rate Limiting
  ↓
Backend API (Layer 7, Zone 2)
```

### 예시 2: 금융사 온프레미스 Layer 2

```yaml
인터넷 (Zone 0-A)
  ↓
Palo Alto NGFW (Layer 2, Zone 1)
  - DDoS Protection
  - IPS/IDS
  - URL Filtering
  ↓
F5 BIG-IP (Layer 2, Zone 1)
  - SSL/TLS Termination
  - L7 Load Balancing
  - WAF (ASM Module)
  ↓
DMZ Web Server (Layer 7, Zone 1)
  ↓
Internal Firewall (Layer 2, Zone 1 → Zone 2)
  ↓
Application Server (Layer 7, Zone 2)
```

---

## ✅ 체크리스트

### 네트워크 보안

- [ ] WAF 룰셋 최신 상태 유지
- [ ] SSL/TLS 인증서 만료 모니터링
- [ ] DDoS 방어 테스트 (시뮬레이션)
- [ ] Zone 간 Firewall Rule 검토

### 고가용성

- [ ] Load Balancer Health Check 설정
- [ ] Multi-AZ 배포 (AWS, Azure)
- [ ] Failover 테스트 (정기적)

### 모니터링

- [ ] 트래픽 패턴 모니터링
- [ ] 에러율 추적 (4xx, 5xx)
- [ ] 응답 시간 대시보드
- [ ] 비정상 트래픽 알람

---

## 🔗 관련 문서

- [차원 1: Deployment Layer 개요](00_차원1_개요.md)
- [Layer 1: Physical Infrastructure](Layer_1_Physical.md)
- [Layer 3: Computing Infrastructure](Layer_3_Computing.md)
- [차원 2: Security Zone](../02_차원2_Security_Zone/00_차원2_개요.md) (예정)

---

## 📞 변경 이력

**v1.0 (2025-01-20)** - 초기 작성:
- ✅ Network Infrastructure 정의 및 구성요소
- ✅ Load Balancer, Firewall, Reverse Proxy, VPN, CDN, DNS 분류
- ✅ Zone 경계 제어 가이드
- ✅ 보안 고려사항 및 실전 예시

---

**문서 끝**
