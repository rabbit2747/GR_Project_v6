# Load Balancer (로드 밸런서)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Load Balancer |
| **한글명** | 로드 밸런서 |
| **Layer** | Layer 2 (Network Infrastructure) |
| **분류** | Traffic Distribution |
| **Function Tag (Primary)** | N1.1 (L4 LB) |
| **Function Tag (Secondary)** | N1.2 (L7 LB) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

로드 밸런서는 **여러 서버로 트래픽을 분산하여 가용성과 성능을 향상시키는 장비**입니다.

### 핵심 기능

1. **트래픽 분산**
   - 여러 백엔드 서버로 부하 분산
   - 알고리즘 기반 분배 (Round Robin, Least Connection 등)

2. **고가용성**
   - 헬스 체크 (Health Check)
   - 장애 서버 자동 제외
   - 자동 장애 조치 (Failover)

3. **성능 향상**
   - 세션 지속성 (Session Persistence)
   - SSL/TLS Offloading
   - 커넥션 풀링

---

## 🏗️ 로드 밸런서 유형

### 1. L4 Load Balancer (Transport Layer)

**특징**:
- OSI Layer 4 (TCP/UDP) 기반
- IP 주소 + 포트로 분산
- 빠른 처리 속도
- 애플리케이션 내용 모름

**동작 방식**:
```
Client Request (IP: 1.2.3.4, Port: 80)
  ↓
[L4 Load Balancer]
  - Source IP Hash 또는 Round Robin
  ↓
Backend Servers:
  - Server 1: 10.0.1.10:8080
  - Server 2: 10.0.1.11:8080
  - Server 3: 10.0.1.12:8080
```

**대표 제품**:
- **F5 BIG-IP**: LTM (Local Traffic Manager)
- **HAProxy**: 오픈소스, 고성능
- **AWS NLB**: Network Load Balancer
- **NGINX Plus**: Stream 모듈

**성능**:
- Throughput: 수십 Gbps
- Connections/sec: 수백만 CPS
- Latency: < 1ms

---

### 2. L7 Load Balancer (Application Layer)

**특징**:
- OSI Layer 7 (HTTP/HTTPS) 기반
- URL, Header, Cookie 기반 라우팅
- 세밀한 제어 가능
- 상대적으로 느림

**동작 방식**:
```
Client Request:
  GET /api/users HTTP/1.1
  Host: example.com
  Cookie: session=abc123
  ↓
[L7 Load Balancer]
  - Path-based Routing:
    /api/* → API Servers
    /static/* → Static Servers
    /admin/* → Admin Servers
  - Header-based Routing:
    User-Agent: Mobile → Mobile Servers
  ↓
Backend Server Pools
```

**대표 제품**:
- **NGINX**: 오픈소스, 최고 인기
- **HAProxy**: L7 지원
- **AWS ALB**: Application Load Balancer
- **Traefik**: Cloud-native, 동적 설정

**고급 기능**:
- Content-based Routing
- A/B Testing
- Canary Deployment
- Rate Limiting

---

## 🔧 로드 밸런싱 알고리즘

### 1. Round Robin (라운드 로빈)
```
Request 1 → Server 1
Request 2 → Server 2
Request 3 → Server 3
Request 4 → Server 1 (반복)

특징:
- 가장 간단
- 서버 스펙 동일할 때 적합
```

### 2. Least Connection (최소 연결)
```
Server 1: 10 active connections
Server 2: 5 active connections ← 선택
Server 3: 8 active connections

특징:
- 세션 길이가 다를 때 유리
- 동적 부하 분산
```

### 3. IP Hash (소스 IP 해싱)
```
Client IP: 1.2.3.4
Hash(1.2.3.4) % 3 = 1 → Server 2 (항상)

특징:
- 같은 클라이언트 → 같은 서버
- 세션 유지 필요 시
```

### 4. Weighted Round Robin (가중 라운드 로빈)
```
Server 1 (Weight: 5) → 50% 트래픽
Server 2 (Weight: 3) → 30% 트래픽
Server 3 (Weight: 2) → 20% 트래픽

특징:
- 서버 스펙 다를 때
- 신규 서버 점진적 투입 (Canary)
```

---

## 📝 설정 예시

### NGINX (L7 Load Balancer)

```nginx
upstream backend {
    # 로드 밸런싱 알고리즘
    least_conn;

    # 백엔드 서버
    server 10.0.1.10:8080 weight=5 max_fails=3 fail_timeout=30s;
    server 10.0.1.11:8080 weight=3;
    server 10.0.1.12:8080 weight=2 backup;  # 백업 서버

    # Health Check
    check interval=3000 rise=2 fall=3 timeout=1000;
}

server {
    listen 80;
    server_name example.com;

    location /api/ {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        # 타임아웃
        proxy_connect_timeout 5s;
        proxy_send_timeout 10s;
        proxy_read_timeout 10s;
    }

    # Sticky Session (IP Hash)
    location /session/ {
        ip_hash;
        proxy_pass http://backend;
    }
}
```

### HAProxy (L4/L7)

```haproxy
global
    maxconn 50000
    log /dev/log local0

defaults
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

frontend http_front
    bind *:80
    bind *:443 ssl crt /etc/ssl/cert.pem

    # ACL (Access Control List)
    acl is_api path_beg /api/
    acl is_static path_end .jpg .png .css .js

    # Routing
    use_backend api_servers if is_api
    use_backend static_servers if is_static
    default_backend web_servers

backend web_servers
    balance roundrobin
    option httpchk GET /health
    server web1 10.0.1.10:8080 check
    server web2 10.0.1.11:8080 check
    server web3 10.0.1.12:8080 check

backend api_servers
    balance leastconn
    server api1 10.0.2.10:8080 check
    server api2 10.0.2.11:8080 check
```

---

## 🔒 Zone별 배치 패턴

| Zone | 배치 빈도 | 용도 |
|------|----------|------|
| **Zone 1** | Very Common | 인터넷 트래픽 분산 (External LB) |
| **Zone 2** | Common | 내부 서비스 간 분산 (Internal LB) |
| **Zone 3** | Rare | DB Read Replica 분산 |

---

## ⚡ 실무 고려사항

### 1. Health Check 설정

```yaml
Health Check Types:
  HTTP GET:
    Path: /health
    Expected: 200 OK
    Interval: 5s
    Timeout: 2s
    Unhealthy Threshold: 3

  TCP Connect:
    Port: 8080
    Timeout: 3s

  Custom Script:
    Command: check_app_health.sh
    Success: exit 0
```

### 2. Session Persistence (세션 유지)

**방법**:
```yaml
1. Source IP Hash:
   - 같은 IP → 같은 서버
   - NAT 환경에서 문제

2. Cookie-based:
   - LB가 쿠키 삽입
   - 쿠키로 서버 식별

3. Application Session Store:
   - Redis, Memcached
   - 어떤 서버든 세션 접근 가능 (권장)
```

### 3. SSL/TLS Termination

```
[Client] --HTTPS--> [Load Balancer] --HTTP--> [Backend]
                    (SSL Offloading)

장점:
- 백엔드 서버 CPU 부하 감소
- 중앙화된 인증서 관리

단점:
- LB와 백엔드 간 암호화 안 됨
- 규정 준수 문제 (금융, 의료)
```

---

## 🔗 관련 문서

- [Layer 2 정의](../00_Layer_2_정의.md)
- [Reverse Proxy](../04_Reverse_Proxy/00_Reverse_Proxy_정의.md)
- [Layer 7: Application](../../Layer_7_Application/00_Layer_7_정의.md)

---

**문서 끝**
