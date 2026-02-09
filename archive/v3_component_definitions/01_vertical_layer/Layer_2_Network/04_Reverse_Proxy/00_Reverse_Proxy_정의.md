# Reverse Proxy (역방향 프록시)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Reverse Proxy |
| **한글명** | 역방향 프록시 |
| **Layer** | Layer 2 (Network Infrastructure) |
| **분류** | Traffic Gateway |
| **Function Tag (Primary)** | N1.3 (Reverse Proxy) |
| **Function Tag (Secondary)** | 없음 |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

역방향 프록시는 **클라이언트 요청을 받아 백엔드 서버로 전달하고, 응답을 클라이언트에게 반환하는 중계 서버**입니다.

### 핵심 기능

1. **요청 중계**
   - 클라이언트와 서버 사이 중간자
   - 백엔드 서버 은닉 (IP 노출 방지)

2. **성능 향상**
   - 정적 콘텐츠 캐싱
   - 압축 (gzip, brotli)
   - HTTP/2, HTTP/3 지원

3. **보안**
   - SSL/TLS Termination
   - Rate Limiting
   - Header 조작

---

## 🔄 Forward Proxy vs Reverse Proxy

### Forward Proxy (일반 프록시)
```
[Client] → [Forward Proxy] → [Internet] → [Server]
         (클라이언트를 위해 작동)

용도:
- 기업 인터넷 필터링
- IP 숨김
- 캐싱
```

### Reverse Proxy
```
[Client] → [Reverse Proxy] → [Backend Servers]
                 (서버를 위해 작동)

용도:
- 로드 밸런싱
- SSL Offloading
- 캐싱
- 보안
```

---

## 🏗️ 대표 제품

### 1. NGINX

**특징**:
- 가장 인기 있는 오픈소스
- 비동기 이벤트 기반 (높은 성능)
- 낮은 메모리 사용량

**사용 사례**:
```nginx
server {
    listen 80;
    server_name example.com;

    # HTTPS 리다이렉트
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name example.com;

    # SSL/TLS
    ssl_certificate /etc/ssl/cert.pem;
    ssl_certificate_key /etc/ssl/key.pem;

    # 정적 파일 캐싱
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # API 프록시
    location /api/ {
        proxy_pass http://backend_servers;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Gzip 압축
    gzip on;
    gzip_types text/plain text/css application/json application/javascript;
    gzip_min_length 1000;
}
```

---

### 2. Apache HTTP Server (mod_proxy)

**특징**:
- 오래된 역사, 안정적
- .htaccess 지원
- 많은 모듈

**설정 예시**:
```apache
<VirtualHost *:80>
    ServerName example.com

    # Reverse Proxy
    ProxyPreserveHost On
    ProxyPass /api http://backend:8080/api
    ProxyPassReverse /api http://backend:8080/api

    # Load Balancer
    <Proxy balancer://mycluster>
        BalancerMember http://10.0.1.10:8080
        BalancerMember http://10.0.1.11:8080
        ProxySet lbmethod=byrequests
    </Proxy>

    ProxyPass / balancer://mycluster/
    ProxyPassReverse / balancer://mycluster/
</VirtualHost>
```

---

### 3. HAProxy

**특징**:
- 전문 로드 밸런서 + 프록시
- TCP/HTTP 모두 지원
- 매우 빠름

---

### 4. Traefik

**특징**:
- Cloud-native, 동적 설정
- Docker, Kubernetes 통합
- Let's Encrypt 자동화

**설정 예시** (Docker Labels):
```yaml
services:
  app:
    image: myapp:latest
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.app.rule=Host(`example.com`)"
      - "traefik.http.routers.app.tls.certresolver=letsencrypt"
      - "traefik.http.services.app.loadbalancer.server.port=8080"
```

---

## 🚀 주요 기능

### 1. SSL/TLS Termination

**개념**: 프록시에서 SSL 복호화, 백엔드는 HTTP
```
[Client] --HTTPS--> [Reverse Proxy] --HTTP--> [Backend]
                    (SSL Offload)

장점:
- 백엔드 CPU 부하 감소
- 중앙 인증서 관리
- TLS 버전 통일

단점:
- 프록시-백엔드 간 암호화 안 됨
```

**NGINX 설정**:
```nginx
server {
    listen 443 ssl http2;

    ssl_certificate /etc/ssl/cert.pem;
    ssl_certificate_key /etc/ssl/key.pem;

    # Modern SSL Configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
    ssl_prefer_server_ciphers off;

    # HSTS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
}
```

---

### 2. Caching (캐싱)

**캐시 대상**:
- 정적 파일 (images, CSS, JS)
- API 응답 (짧은 TTL)

**NGINX 캐싱**:
```nginx
# Cache Zone 정의
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m max_size=1g inactive=60m;

server {
    location / {
        proxy_cache my_cache;
        proxy_cache_valid 200 302 10m;
        proxy_cache_valid 404 1m;

        # Cache Key
        proxy_cache_key "$scheme$request_method$host$request_uri";

        # Cache 헤더
        add_header X-Cache-Status $upstream_cache_status;

        proxy_pass http://backend;
    }
}
```

**캐시 상태**:
```
HIT: 캐시에서 응답
MISS: 백엔드에서 가져옴
BYPASS: 캐시 스킵
EXPIRED: 캐시 만료
```

---

### 3. Compression (압축)

**NGINX gzip**:
```nginx
gzip on;
gzip_vary on;
gzip_proxied any;
gzip_comp_level 6;
gzip_types
    text/plain
    text/css
    text/xml
    application/json
    application/javascript
    application/xml+rss;
gzip_min_length 256;
```

**압축 효과**:
```
HTML (50KB) → gzip → 10KB (80% 감소)
JSON (100KB) → gzip → 20KB (80% 감소)
Images (JPG, PNG) → 압축 효과 거의 없음 (이미 압축됨)
```

---

### 4. Request/Response Header 조작

**보안 헤더 추가**:
```nginx
# XSS Protection
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-XSS-Protection "1; mode=block" always;

# CSP (Content Security Policy)
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'" always;

# Referrer Policy
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
```

**클라이언트 정보 전달**:
```nginx
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header X-Forwarded-Host $host;
```

---

## 🔒 Zone별 배치 패턴

| Zone | 배치 빈도 | 용도 |
|------|----------|------|
| **Zone 1** | Very Common | 인터넷 → 내부 서버 프록시 |
| **Zone 2** | Common | 마이크로서비스 간 프록시 |

---

## ⚡ 실무 고려사항

### 1. Timeouts 설정

```nginx
# 연결 타임아웃
proxy_connect_timeout 60s;

# 요청 전송 타임아웃
proxy_send_timeout 60s;

# 응답 대기 타임아웃
proxy_read_timeout 60s;

# Keepalive
keepalive_timeout 65s;
```

### 2. 버퍼 설정

```nginx
# 백엔드 응답 버퍼
proxy_buffering on;
proxy_buffer_size 4k;
proxy_buffers 8 4k;
proxy_busy_buffers_size 8k;

# 클라이언트 요청 버퍼
client_body_buffer_size 128k;
client_max_body_size 10m;
```

### 3. Rate Limiting

```nginx
# Zone 정의
limit_req_zone $binary_remote_addr zone=mylimit:10m rate=10r/s;

server {
    location /api/ {
        # Rate Limit 적용
        limit_req zone=mylimit burst=20 nodelay;

        # 초과 시 429 반환
        limit_req_status 429;
    }
}
```

---

## 🔗 관련 문서

- [Layer 2 정의](../00_Layer_2_정의.md)
- [Load Balancer](../01_Load_Balancer/00_Load_Balancer_정의.md)
- [CDN](../06_CDN/00_CDN_정의.md)

---

**문서 끝**
