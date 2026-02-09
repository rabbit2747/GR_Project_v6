# Domain N: Networking (네트워킹)

**버전**: v2.0
**최종 수정**: 2025-11-20
**목적**: 네트워크 연결, 라우팅, 로드 밸런싱, DNS, CDN, VPN

---

## 1. Domain 개요

### 1.1 정의
Networking Domain은 **데이터 전송, 연결 관리, 트래픽 제어**를 담당하는 기능 집합입니다.

### 1.2 핵심 목표
1. **고가용성**: 99.99% 네트워크 업타임
2. **성능 최적화**: 지연 시간 최소화 (RTT <50ms)
3. **보안**: 네트워크 레벨 격리 및 암호화
4. **확장성**: 트래픽 증가에 대응 가능한 구조

---

## 2. Tag 체계

### Tag 구조
```
N + [숫자] + (선택적 서브 카테고리)
예: N1 (Load Balancer), N3.2 (DNS - Authoritative)
```

---

## 3. Tag 상세 정의

### N1: Load Balancer (로드 밸런서)

**목적**: 트래픽 분산 및 고가용성 보장

**구성 요소**:
- **N1.1**: Layer 4 Load Balancer (TCP/UDP)
  - 도구: AWS NLB, HAProxy, NGINX Stream
  - 분산 알고리즘: Round Robin, Least Connections, IP Hash
  - Health Check: TCP SYN, Port Check

- **N1.2**: Layer 7 Load Balancer (HTTP/HTTPS)
  - 도구: AWS ALB, NGINX, Envoy
  - 분산 기준: URL Path, HTTP Header, Cookie
  - 기능: SSL Termination, Content-based Routing

- **N1.3**: Global Load Balancer (GSLB)
  - 도구: AWS Route 53, Cloudflare Load Balancing
  - 분산 기준: Geographic Location, Latency
  - Failover: Multi-Region HA

**사용 예시**:
```yaml
Component: Application Load Balancer (L1, Zone 1)
Tags: [N1.2, S1.2, M1.2]

Configuration:
  Listener:
    - Port: 443
    - Protocol: HTTPS
    - Certificate: ACM (AWS Certificate Manager)

  Target Groups:
    - Name: backend-api-servers
      Port: 8000
      Health Check: GET /health (M1.2)
      Targets:
        - 10.0.1.10:8000 (Zone 2)
        - 10.0.1.11:8000 (Zone 2)

  Routing Rules:
    - Path: /api/* → backend-api-servers
    - Path: /admin/* → admin-servers (require auth)
```

---

### N2: Networking Infrastructure (네트워크 인프라)

**목적**: VPC, Subnet, Routing 등 기본 네트워크 구성

**구성 요소**:
- **N2.1**: VPC (Virtual Private Cloud)
  - 도구: AWS VPC, Azure VNet, GCP VPC
  - CIDR: 10.0.0.0/16 (RFC 1918 private address)
  - Subnets: Public (Zone 1), Private (Zone 2-4)

- **N2.2**: Subnet & Routing
  - Public Subnet: IGW (Internet Gateway) 연결
  - Private Subnet: NAT Gateway 경유
  - Route Table: Destination → Target

- **N2.3**: Network ACL & Security Groups
  - NACL: Stateless, Subnet 레벨
  - Security Group: Stateful, Instance 레벨
  - Default Deny All, Whitelist 방식

**사용 예시**:
```yaml
VPC Configuration:
  VPC CIDR: 10.0.0.0/16

  Subnets:
    - Public Subnet (Zone 1):
        CIDR: 10.0.1.0/24
        Route: 0.0.0.0/0 → IGW
        Components: ALB, NAT Gateway

    - Private Subnet (Zone 2):
        CIDR: 10.0.2.0/24
        Route: 0.0.0.0/0 → NAT Gateway
        Components: Backend API Servers

    - Data Subnet (Zone 3):
        CIDR: 10.0.3.0/24
        Route: No internet access
        Components: PostgreSQL, Redis

  Security Groups:
    - ALB-SG (Zone 1):
        Inbound: 0.0.0.0/0:443 (HTTPS)
        Outbound: Zone 2:8000

    - Backend-SG (Zone 2):
        Inbound: ALB-SG:8000
        Outbound: Zone 3:5432 (PostgreSQL)
```

---

### N3: DNS (Domain Name System)

**목적**: 도메인 이름을 IP 주소로 변환

**구성 요소**:
- **N3.1**: DNS Resolver
  - 도구: AWS Route 53 Resolver, Cloudflare 1.1.1.1
  - Recursive Query, DNS Caching

- **N3.2**: Authoritative DNS
  - 도구: AWS Route 53, Cloudflare DNS
  - Record Types: A, AAAA, CNAME, MX, TXT, SRV
  - TTL: 60s (동적) ~ 86400s (정적)

- **N3.3**: Private DNS (Internal)
  - 도구: AWS Route 53 Private Hosted Zone
  - Use Case: 내부 서비스 디스커버리
  - Example: db-master.internal → 10.0.3.10

**사용 예시**:
```yaml
DNS Records:
  - Type: A
    Name: api.example.com
    Value: 203.0.113.10 (ALB Public IP)
    TTL: 60

  - Type: CNAME
    Name: www.example.com
    Value: example.com
    TTL: 3600

  - Type: TXT
    Name: _dmarc.example.com
    Value: "v=DMARC1; p=quarantine; rua=mailto:dmarc@example.com"
    TTL: 86400

Private DNS (Zone 2-3 internal):
  - db-master.internal → 10.0.3.10
  - redis-cluster.internal → 10.0.3.20
  - kafka-broker-1.internal → 10.0.2.30
```

---

### N4: CDN (Content Delivery Network)

**목적**: 정적 콘텐츠 캐싱 및 글로벌 배포

**구성 요소**:
- **N4.1**: Edge Caching
  - 도구: Cloudflare, AWS CloudFront, Fastly
  - Cache Policy: Cache-Control Header 기반
  - Purge: API 호출로 캐시 무효화

- **N4.2**: Origin Shield
  - 도구: CloudFront Origin Shield
  - 목적: Origin 서버 부하 감소
  - Cache Hit Ratio: 90%+ 목표

- **N4.3**: Dynamic Content Acceleration
  - 도구: Cloudflare Argo, AWS Global Accelerator
  - 기법: Route optimization, TCP connection pooling

**사용 예시**:
```yaml
CDN Configuration:
  Provider: AWS CloudFront

  Origins:
    - S3 Bucket (Zone 3):
        Domain: static-assets.s3.amazonaws.com
        Path Pattern: /static/*
        Cache TTL: 86400s (1 day)

    - ALB (Zone 1):
        Domain: alb-12345.us-east-1.elb.amazonaws.com
        Path Pattern: /api/*
        Cache TTL: 0 (no cache)

  Cache Behaviors:
    - Path: *.jpg, *.png, *.css, *.js
      Cache: 86400s
      Compress: Gzip, Brotli

    - Path: /api/*
      Cache: No
      Forward Headers: Authorization, X-API-Key

  Security:
    - WAF: Enabled (S1.1)
    - HTTPS Only: Yes
    - Certificate: ACM
```

---

### N5: VPN & Private Connectivity (VPN 및 사설 연결)

**목적**: 안전한 원격 접속 및 하이브리드 클라우드 연결

**구성 요소**:
- **N5.1**: Site-to-Site VPN
  - 도구: AWS VPN, IPsec VPN
  - Use Case: On-Premise ↔ Cloud 연결
  - Protocol: IPsec, IKEv2

- **N5.2**: Client VPN (Remote Access VPN)
  - 도구: OpenVPN, AWS Client VPN, Tailscale
  - Use Case: 재택근무 직원 접속
  - Authentication: MFA, SSO (SAML)

- **N5.3**: Direct Connect / Private Link
  - 도구: AWS Direct Connect, Azure ExpressRoute
  - Use Case: 고속, 안정적인 전용선
  - Bandwidth: 1Gbps ~ 100Gbps

**사용 예시**:
```yaml
VPN Configuration:
  Type: Site-to-Site VPN

  Local Network (On-Premise):
    CIDR: 192.168.0.0/16
    Gateway: Cisco ASA 5525-X

  Remote Network (AWS):
    VPC CIDR: 10.0.0.0/16
    VPN Gateway: vgw-12345

  Tunnels:
    - Tunnel 1: 203.0.113.1 ↔ AWS Endpoint 1
    - Tunnel 2: 203.0.113.2 ↔ AWS Endpoint 2 (Redundancy)

  Routing:
    - 192.168.0.0/16 → VPN Tunnel → 10.0.0.0/16
    - BGP: Enabled (Dynamic routing)

  Security:
    - Encryption: AES-256-GCM
    - Authentication: PSK (Pre-Shared Key) + Certificate
```

---

### N6: Service Mesh (서비스 메시)

**목적**: 마이크로서비스 간 통신 관리

**구성 요소**:
- **N6.1**: Service Mesh Control Plane
  - 도구: Istio, Linkerd, Consul Connect
  - 기능: Service Discovery, Configuration

- **N6.2**: Service Mesh Data Plane (Sidecar Proxy)
  - 도구: Envoy Proxy, Linkerd Proxy
  - 기능: Traffic Routing, Load Balancing, Retry

- **N6.3**: Service Mesh Observability
  - 도구: Jaeger, Kiali, Grafana
  - Metrics: Request Rate, Latency, Success Rate

**사용 예시**:
```yaml
Service Mesh: Istio (Zone 2)
Tags: [N6.1, N6.2, M5.1, S3.1]

Configuration:
  Services:
    - user-service:
        Replicas: 3
        Sidecar: Envoy Proxy (N6.2)
        Traffic Policy:
          - Retry: 3 attempts
          - Timeout: 5s
          - Circuit Breaker: Max Connections 100

    - payment-service:
        Replicas: 2
        Sidecar: Envoy Proxy
        mTLS: Enabled (S3.1)

  VirtualService:
    - Name: user-service-route
      Match:
        - URI: /api/users/*
      Route:
        - Destination: user-service
          Weight: 90% (v1.2)
        - Destination: user-service-canary
          Weight: 10% (v1.3)

  Observability:
    - Distributed Tracing: Jaeger (M5.1)
    - Metrics: Prometheus (M1.2)
```

---

### N7: API Gateway (API 게이트웨이)

**목적**: API 라우팅, 인증, Rate Limiting

**구성 요소**:
- **N7.1**: API Routing
  - 도구: Kong, AWS API Gateway, NGINX
  - Routing: Path-based, Header-based

- **N7.2**: Rate Limiting & Throttling
  - 알고리즘: Token Bucket, Leaky Bucket
  - Limit: 1000 req/min per user, 10000 req/min global

- **N7.3**: API Authentication & Authorization
  - 방식: API Key, JWT, OAuth 2.0
  - Integration: Keycloak, Auth0

**사용 예시**:
```yaml
API Gateway: Kong (L1, Zone 1)
Tags: [N7.1, N7.2, S2.1, I1.1]

Services:
  - Name: user-api
    URL: http://user-service.zone2.internal:8000
    Routes:
      - Path: /api/users
        Methods: [GET, POST, PUT, DELETE]
    Plugins:
      - rate-limiting:
          minute: 1000
          policy: local
      - jwt:
          key_claim_name: kid
          secret_is_base64: false
      - cors:
          origins: ["https://app.example.com"]
          methods: [GET, POST, PUT, DELETE]
          headers: [Authorization, Content-Type]

Response Headers:
  X-RateLimit-Limit: 1000
  X-RateLimit-Remaining: 847
  X-RateLimit-Reset: 1700000000
```

---

### N8: Network Security (네트워크 보안)

**목적**: 네트워크 레벨 위협 차단

**구성 요소**:
- **N8.1**: Firewall
  - 도구: AWS Network Firewall, Palo Alto, Fortinet
  - Rules: Stateful, Stateless
  - IDS/IPS: Snort, Suricata 엔진

- **N8.2**: DDoS Protection
  - 도구: AWS Shield, Cloudflare DDoS Protection
  - Layer 3/4: SYN Flood, UDP Amplification
  - Layer 7: HTTP Flood

- **N8.3**: Network Segmentation
  - VLAN, Subnet 분리
  - Micro-segmentation: Zero Trust 기반

**사용 예시**:
```yaml
Network Firewall Rules (Zone 1):
Tags: [N8.1, S1.1, M6.2]

Stateful Rules:
  - Action: PASS
    Protocol: TCP
    Source: 0.0.0.0/0
    Destination: Zone 1 ALB
    Destination Port: 443

  - Action: DROP
    Protocol: Any
    Source: Known Bad IPs (Threat Intelligence)
    Destination: Any

Stateless Rules (Priority Order):
  1. Allow: Established connections
  2. Drop: Fragmented packets
  3. Drop: Invalid TCP flags (XMAS, NULL)

DDoS Protection:
  - AWS Shield Standard: Enabled
  - CloudFront Rate Limiting: 10000 req/s per IP
  - Auto Scaling: Triggered at 80% capacity
```

---

## 4. Layer/Zone 연관성

### Layer별 Networking 전략

| Layer | 주요 Networking Tags | 구성 요소 |
|-------|---------------------|----------|
| L0 (External) | N4.1 (CDN Edge) | Cloudflare, CloudFront |
| L1 (Perimeter) | N1.2 (ALB), N7.1 (API Gateway) | AWS ALB, Kong |
| L2 (Application) | N6.2 (Service Mesh) | Envoy Sidecar, Istio |
| L3 (Data) | N2.1 (Private Subnet) | VPC, Security Groups |
| L4 (Management) | N5.2 (VPN) | OpenVPN, Bastion Host |
| L5 (Endpoint) | N3.1 (DNS Resolver) | CloudFlare 1.1.1.1 |

### Zone별 Network Isolation

```
Zone 0-A (Untrusted):
  - No direct network access to internal zones
  - All traffic via Zone 1 (Perimeter)

Zone 0-B (Trusted Partner):
  - API Gateway (N7.1) with authentication
  - Rate Limiting (N7.2)

Zone 1 (Perimeter):
  - Public Subnet (N2.2)
  - Internet Gateway (N2.1)
  - Load Balancer (N1.2)

Zone 2 (Application):
  - Private Subnet (N2.2)
  - NAT Gateway (outbound only)
  - Service Mesh (N6.2)

Zone 3 (Data):
  - Private Subnet (N2.2)
  - No internet access
  - Security Group: Allow only from Zone 2

Zone 4 (Management):
  - Private Subnet (N2.2)
  - VPN Access only (N5.2)
  - Bastion Host: Jump server

Zone 5 (Endpoint):
  - User devices (laptops, mobile)
  - VPN Client (N5.2) for corporate access
```

---

## 5. CVE 매핑

### Networking 도구 취약점 예시

| CVE ID | 영향 받는 도구 | Tech Stack Tag | Severity |
|--------|--------------|---------------|----------|
| CVE-2023-44487 | HTTP/2 Rapid Reset (NGINX, Envoy) | T3.1 (NGINX) | High |
| CVE-2024-12345 | Kong API Gateway <3.4.0 | T4.3 (API Gateway) | Critical |
| CVE-2024-67890 | Istio <1.18.0 | T4.6 (Service Mesh) | Medium |

**대응 전략**:
```yaml
Vulnerability: CVE-2023-44487 (HTTP/2 Rapid Reset)
Affected Components:
  - NGINX ALB (L1, Zone 1)
  - Envoy Proxy (L2, Zone 2)
  - Tags: [N1.2, N6.2, T3.1]

Mitigation:
  - Upgrade: NGINX 1.24.0 → 1.25.2
  - Config: http2_max_concurrent_streams 100 (limit)
  - Monitoring: Track h2 stream resets (M1.2)
  - WAF Rule: Block excessive RST_STREAM frames
```

---

## 6. MITRE ATT&CK 매핑

### Networking 레벨 공격 기법

| MITRE Technique | Networking Tag | 탐지/차단 방법 |
|----------------|---------------|--------------|
| T1071 (Application Layer Protocol) | N7.1, M6.1 | API Gateway 로그 분석 |
| T1090 (Proxy) | N8.1, M6.2 | 알려진 Proxy IP 차단 |
| T1498 (DoS) | N8.2, N1.2 | DDoS Protection, Auto-scaling |
| T1557 (Man-in-the-Middle) | S1.2, N5.1 | mTLS, Certificate Pinning |

---

## 7. Best Practices

### 7.1 Network Architecture
1. **Defense in Depth**: Multiple layers of network security
2. **Zero Trust**: Verify every connection, never trust implicitly
3. **Segmentation**: Isolate workloads by zone and sensitivity

### 7.2 High Availability
1. **Multi-AZ**: Deploy across 3+ Availability Zones
2. **Auto-scaling**: Dynamic capacity based on traffic
3. **Health Checks**: Continuous monitoring (M1.2)

### 7.3 Performance Optimization
1. **CDN**: Cache static content (N4.1)
2. **Connection Pooling**: Reuse TCP connections
3. **HTTP/2 or HTTP/3**: Multiplexing, Header compression

---

## 8. 실제 구현 예시

### Full Network Architecture

```yaml
Internet (Zone 0-A)
  ↓
Cloudflare CDN (N4.1) + DDoS Protection (N8.2)
  ↓
AWS Route 53 (N3.2) → ALB (N1.2, Zone 1)
  ↓
API Gateway (N7.1) → Rate Limiting (N7.2)
  ↓
Service Mesh (N6.2, Zone 2) → Backend Services
  ↓
Private Subnet (N2.2, Zone 3) → PostgreSQL, Redis

Management:
  VPN (N5.2) → Bastion Host (Zone 4) → Internal Access
```

---

## 9. 다음 단계

- **Domain S (Security)**: N8과 연동되는 보안 통제
- **Domain I (Interface)**: N7.1과 연동되는 프로토콜 매핑
- **Domain M (Monitoring)**: N1.2와 연동되는 네트워크 메트릭

---

**문서 종료**
