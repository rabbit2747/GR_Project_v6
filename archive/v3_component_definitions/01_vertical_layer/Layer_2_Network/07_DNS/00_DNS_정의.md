# DNS (Domain Name System)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | DNS |
| **한글명** | 도메인 네임 시스템 |
| **Layer** | Layer 2 (Network Infrastructure) |
| **분류** | Name Resolution |
| **Function Tag (Primary)** | N2.1 (DNS Resolver) |
| **Function Tag (Secondary)** | N2.2 (Authoritative DNS) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

DNS는 **도메인 이름을 IP 주소로 변환하는 인터넷 전화번호부 시스템**입니다.

### 핵심 기능

1. **이름 해석 (Name Resolution)**
   - example.com → 93.184.216.34
   - 사람이 읽기 쉬운 도메인 사용

2. **부하 분산**
   - Round Robin DNS
   - 지리적 라우팅 (Geo-DNS)
   - 가중치 기반 라우팅

3. **서비스 검색**
   - MX 레코드 (메일 서버)
   - SRV 레코드 (서비스 위치)
   - TXT 레코드 (검증, SPF)

---

## 🏗️ DNS 계층 구조

```
                [Root Servers] (.)
                      ↓
            [TLD Servers] (.com, .org, .net)
                      ↓
        [Authoritative Name Servers] (example.com)
                      ↓
              [Recursive Resolvers]
                      ↓
                  [Client]

조회 흐름:
1. Client → Recursive Resolver: example.com?
2. Resolver → Root: .com NS?
3. Root → Resolver: a.gtld-servers.net
4. Resolver → TLD (.com): example.com NS?
5. TLD → Resolver: ns1.example.com
6. Resolver → Authoritative: example.com A?
7. Authoritative → Resolver: 93.184.216.34
8. Resolver → Client: 93.184.216.34 (캐싱)
```

---

## 📝 DNS 레코드 유형

### 주요 레코드

| 타입 | 설명 | 예시 |
|------|------|------|
| **A** | IPv4 주소 | example.com → 93.184.216.34 |
| **AAAA** | IPv6 주소 | example.com → 2606:2800:220:1:248:1893:25c8:1946 |
| **CNAME** | 별칭 (Canonical Name) | www.example.com → example.com |
| **MX** | 메일 서버 | example.com → mail.example.com (우선순위: 10) |
| **TXT** | 텍스트 정보 | SPF, DKIM, 도메인 검증 |
| **NS** | 네임서버 | example.com → ns1.example.com |
| **SOA** | 권한 시작 (Start of Authority) | 도메인 관리 정보 |
| **SRV** | 서비스 레코드 | _sip._tcp.example.com → sip.example.com:5060 |
| **CAA** | 인증 기관 인증 | example.com → letsencrypt.org |

---

### 레코드 예시

```dns
; A 레코드 (IPv4)
example.com.      300   IN  A      93.184.216.34
www.example.com.  300   IN  A      93.184.216.34

; AAAA 레코드 (IPv6)
example.com.      300   IN  AAAA   2606:2800:220:1:248:1893:25c8:1946

; CNAME (별칭)
blog.example.com.  300  IN  CNAME  example.com.
cdn.example.com.   300  IN  CNAME  d111111abcdef8.cloudfront.net.

; MX (메일)
example.com.      300   IN  MX     10 mail1.example.com.
example.com.      300   IN  MX     20 mail2.example.com.

; TXT (SPF, DKIM)
example.com.      300   IN  TXT    "v=spf1 include:_spf.google.com ~all"
_dmarc.example.com. 300 IN  TXT    "v=DMARC1; p=quarantine; rua=mailto:dmarc@example.com"

; NS (네임서버)
example.com.      86400 IN  NS     ns1.example.com.
example.com.      86400 IN  NS     ns2.example.com.

; SOA
example.com.      86400 IN  SOA    ns1.example.com. admin.example.com. (
                                    2024010101 ; Serial
                                    3600       ; Refresh
                                    1800       ; Retry
                                    604800     ; Expire
                                    86400 )    ; Minimum TTL
```

---

## 🌐 DNS 제공업체

### 1. Cloudflare DNS

**특징**:
- 무료
- 가장 빠른 DNS (1.1.1.1)
- DDoS 방어

**가격**: 무료

---

### 2. AWS Route 53

**특징**:
- 고급 라우팅 (Geo, Latency, Failover)
- Health Check 통합
- AWS 서비스 통합

**가격**:
```yaml
Hosted Zone: $0.50/month
Queries:
  - 처음 1B: $0.40 per 1M queries
  - 다음 1B: $0.20 per 1M queries
Health Check: $0.50/month (선택)
```

---

### 3. Google Cloud DNS

**특징**:
- 100% SLA
- Anycast 네트워크

**가격**:
```yaml
Zone: $0.20/month
Queries: $0.40 per 1M queries
```

---

### 4. BIND (오픈소스)

**특징**:
- 가장 널리 사용되는 DNS 서버
- 온프레미스 운영

**설정 예시** (`/etc/bind/named.conf.local`):
```bind
zone "example.com" {
    type master;
    file "/etc/bind/zones/db.example.com";
    allow-transfer { 10.0.1.2; };  # Secondary NS
};

zone "1.0.10.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.10.0.1";
};
```

**Zone File** (`/etc/bind/zones/db.example.com`):
```dns
$TTL 86400
@   IN  SOA ns1.example.com. admin.example.com. (
        2024010101  ; Serial
        3600        ; Refresh
        1800        ; Retry
        604800      ; Expire
        86400 )     ; Minimum TTL

    IN  NS  ns1.example.com.
    IN  NS  ns2.example.com.

@   IN  A   93.184.216.34
www IN  A   93.184.216.34
mail IN  A   93.184.216.50

@   IN  MX  10 mail.example.com.
```

---

## 🚀 고급 라우팅 (Route 53)

### 1. Geolocation Routing (지리적 라우팅)

```yaml
한국 사용자 → 서울 리전 (ap-northeast-2)
미국 사용자 → 버지니아 리전 (us-east-1)
기타 → 도쿄 리전 (ap-northeast-1)

Record Set:
  - Name: example.com
  - Type: A
  - Value: 52.78.123.45
  - Geolocation: Asia - South Korea
```

---

### 2. Latency-based Routing (지연시간 기반)

```yaml
사용자에게 가장 빠른 리전 응답

Health Check:
  - 서울 리전 (20ms)
  - 도쿄 리전 (50ms)
  - 버지니아 리전 (200ms)

→ 서울 리전 IP 반환
```

---

### 3. Weighted Routing (가중치 기반)

```yaml
A/B Testing, Canary Deployment:

example.com:
  - v1: 10.0.1.10 (Weight: 90)
  - v2: 10.0.1.20 (Weight: 10)

→ 90% 트래픽 → v1
→ 10% 트래픽 → v2
```

---

### 4. Failover Routing (장애 조치)

```yaml
Primary: 10.0.1.10 (서울)
  Health Check: HTTPS /health (5s interval)

Secondary: 10.0.2.10 (도쿄)
  Standby

Primary 장애 시 → Secondary로 자동 전환
```

---

## 🔒 DNS 보안

### 1. DNSSEC (DNS Security Extensions)

**목적**: DNS 응답 위변조 방지

```yaml
작동 방식:
1. Zone Signing: 개인키로 서명
2. 공개키 배포: DS 레코드 (상위 도메인)
3. 검증: Resolver가 서명 검증

장점:
- DNS 스푸핑 방지
- Cache Poisoning 방지

단점:
- 복잡한 설정
- 약간의 성능 저하
```

---

### 2. DNS over HTTPS (DoH)

```
일반 DNS:
  Client → DNS (UDP 53, 평문)

DoH:
  Client → DNS (HTTPS 443, 암호화)

제공업체:
  - Cloudflare: https://1.1.1.1/dns-query
  - Google: https://dns.google/dns-query
  - Quad9: https://dns.quad9.net/dns-query

장점:
- ISP 스니핑 방지
- 프라이버시 보호
```

---

### 3. Rate Limiting (DDoS 방어)

```yaml
Cloudflare:
  - 쿼리 제한: IP당 1000 queries/sec
  - 자동 차단: 임계값 초과 시

BIND:
  rate-limit {
      responses-per-second 10;
      window 5;
  };
```

---

## ⚡ 실무 고려사항

### 1. TTL 설정

```yaml
레코드 유형별 권장 TTL:

A/AAAA (프로덕션):
  - 평시: 3600s (1시간)
  - 마이그레이션 전: 300s (5분) → 빠른 전환

CNAME:
  - 3600s (1시간)

MX:
  - 86400s (1일) → 자주 변경 안 함

NS:
  - 86400s (1일)

TXT:
  - 300s (5분) → 검증 빠르게
```

### 2. DNS Propagation (전파 시간)

```yaml
DNS 변경 후 전파 시간:
  - Local Resolver: TTL 경과 후
  - ISP Resolver: 수 시간
  - 글로벌: 24-48시간 (최대)

빠른 전파 방법:
  1. 변경 전 TTL을 300s로 낮춤 (24시간 전)
  2. DNS 레코드 변경
  3. 전파 확인 후 TTL 복구
```

### 3. 모니터링

```yaml
DNS Health Check:
  - Query Response Time
  - Uptime (99.99% 목표)
  - Query Success Rate

도구:
  - dig, nslookup (CLI)
  - DNSViz (DNSSEC 검증)
  - DNS Checker (전파 확인)

알림:
  - DNS Resolution Failure
  - High Query Latency (> 100ms)
  - DNSSEC Validation Failure
```

---

## 🔧 DNS 조회 명령어

```bash
# dig (상세)
dig example.com
dig example.com +short
dig example.com MX
dig @1.1.1.1 example.com  # 특정 DNS 서버

# nslookup
nslookup example.com
nslookup -type=MX example.com

# host
host example.com
host -t MX example.com

# Windows
nslookup example.com
```

---

## 🔗 관련 문서

- [Layer 2 정의](../00_Layer_2_정의.md)
- [CDN](../06_CDN/00_CDN_정의.md)
- [Load Balancer](../01_Load_Balancer/00_Load_Balancer_정의.md)

---

**문서 끝**
