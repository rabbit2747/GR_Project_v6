# CDN (Content Delivery Network)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | CDN |
| **한글명** | 콘텐츠 전송 네트워크 |
| **Layer** | Layer 2 (Network Infrastructure) |
| **분류** | Content Distribution |
| **Function Tag (Primary)** | N3.1 (CDN) |
| **Function Tag (Secondary)** | D2.1 (Edge Caching) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

CDN은 **지리적으로 분산된 서버 네트워크를 통해 콘텐츠를 빠르게 전달하는 시스템**입니다.

### 핵심 기능

1. **Edge Caching (엣지 캐싱)**
   - 사용자 가까운 서버에서 콘텐츠 제공
   - Origin 서버 부하 감소
   - 빠른 응답 시간 (낮은 지연시간)

2. **성능 향상**
   - 대역폭 절감
   - TTFB (Time To First Byte) 감소
   - 동시 접속 처리 능력 향상

3. **보안**
   - DDoS 방어
   - WAF 통합
   - SSL/TLS 지원

---

## 🏗️ CDN 작동 원리

### 기본 구조
```
[사용자 (서울)]
    ↓ (DNS 조회)
[CDN DNS] → 가장 가까운 Edge 서버 응답
    ↓
[Edge Server (서울 POP)]
    ↓ (Cache Miss 시)
[Origin Server (미국)]

POP (Point of Presence): CDN 엣지 서버 위치
```

### 캐싱 흐름
```
1. 사용자 요청: example.com/image.jpg
2. DNS → cdn.example.com (CNAME)
3. Edge Server 확인:
   - Cache Hit → 즉시 응답 (10-50ms)
   - Cache Miss → Origin 요청 (200-500ms) → 캐싱 → 응답
4. 다음 요청부터 Cache Hit
```

---

## 🌐 주요 CDN 제공업체

### 1. Cloudflare

**특징**:
- 무료 티어 제공
- 200+ PoP 글로벌
- DDoS 방어 포함
- WAF, Bot 관리

**가격**:
```yaml
Free: $0
  - 무제한 대역폭
  - 기본 DDoS 방어
  - SSL/TLS

Pro: $20/month
  - WAF
  - Image Optimization
  - 모바일 최적화

Business: $200/month
  - 고급 WAF 룰
  - 100% Uptime SLA

Enterprise: 협의
  - 전용 IP
  - 커스텀 SSL
```

---

### 2. AWS CloudFront

**특징**:
- AWS 서비스 통합 (S3, EC2, ALB)
- Lambda@Edge (Edge 컴퓨팅)
- 450+ PoP

**가격**:
```yaml
북미/유럽:
  - 처음 10TB: $0.085/GB
  - 다음 40TB: $0.080/GB
  - 150TB+: $0.060/GB

아시아:
  - 처음 10TB: $0.140/GB
  - 다음 40TB: $0.135/GB

HTTPS 요청: $0.01 per 10,000 requests
```

---

### 3. Akamai

**특징**:
- 가장 큰 CDN 네트워크
- 엔터프라이즈급
- 최고 성능

**용도**: 대기업, 미디어 스트리밍

---

### 4. Fastly

**특징**:
- 실시간 캐시 퍼지 (즉시 삭제)
- VCL (Varnish Configuration Language)
- Edge 컴퓨팅

---

## 📝 CDN 설정

### CloudFront Distribution 예시

```yaml
OriginDomainName: example.com
OriginPath: /static

CacheBehaviors:
  - PathPattern: "*.jpg"
    MinTTL: 86400  # 1일
    MaxTTL: 31536000  # 1년
    DefaultTTL: 86400
    Compress: true
    ViewerProtocolPolicy: redirect-to-https

  - PathPattern: "*.html"
    MinTTL: 0
    MaxTTL: 86400
    DefaultTTL: 3600  # 1시간
    ForwardedValues:
      QueryString: false
      Cookies: none

  - PathPattern: "/api/*"
    MinTTL: 0
    MaxTTL: 0
    CachePolicyId: 4135ea2d-6df8-44a3-9df3-4b5a84be39ad  # CachingDisabled

PriceClass: PriceClass_All  # 전세계
SSL: AcmCertificateArn
```

---

### Cache-Control Headers

```http
# 정적 이미지 (1년)
Cache-Control: public, max-age=31536000, immutable

# HTML (1시간, 재검증)
Cache-Control: public, max-age=3600, must-revalidate

# API (캐싱 안 함)
Cache-Control: no-store, no-cache, must-revalidate

# 조건부 캐싱
Cache-Control: public, max-age=3600
ETag: "abc123"
Last-Modified: Wed, 21 Oct 2015 07:28:00 GMT
```

---

## 🚀 캐싱 전략

### 1. Cache Key 설계

```yaml
기본 Cache Key:
  - Host: example.com
  - Path: /images/logo.png
  - Query String: ?version=2

커스텀 Cache Key:
  - Query String 정렬: ?b=2&a=1 → ?a=1&b=2
  - Header 포함: Accept-Language, Accept-Encoding
  - Cookie 포함: session_id (신중히)
```

### 2. TTL (Time To Live) 설정

```yaml
콘텐츠 유형별 권장 TTL:

정적 에셋 (versioned):
  - /assets/app.v123.js
  - TTL: 1년
  - Immutable

정적 에셋 (unversioned):
  - /logo.png
  - TTL: 1일-1주

HTML:
  - /index.html
  - TTL: 1시간-1일

API 응답:
  - /api/products
  - TTL: 1분-1시간 (데이터에 따라)

동적 콘텐츠:
  - /user/profile
  - TTL: 0 (캐싱 안 함)
```

### 3. Cache Invalidation (캐시 무효화)

```yaml
방법:

1. Cache Purge (전체 삭제):
   - CloudFront Invalidation
   - 모든 객체 즉시 삭제
   - 비용: $0.005 per path (처음 1000개 무료)

2. Versioning (권장):
   - /app.js → /app.v124.js
   - HTML에서 버전 변경
   - 자동 갱신, 비용 없음

3. Soft Purge:
   - 캐시를 stale로 표시
   - 재검증 (If-None-Match)
```

---

## 🔒 보안 기능

### 1. DDoS 방어

```yaml
Layer 3/4 DDoS:
  - SYN Flood
  - UDP Flood
  - 자동 차단

Layer 7 DDoS:
  - HTTP Flood
  - Slowloris
  - Rate Limiting
```

### 2. Signed URLs (인증된 URL)

```python
# CloudFront Signed URL
import boto3
from datetime import datetime, timedelta

cf_signer = boto3.client('cloudfront').get_url_signer('KEY_PAIR_ID', lambda: open('private_key.pem', 'rb').read())

url = cf_signer.generate_presigned_url(
    'https://d111111abcdef8.cloudfront.net/private/video.mp4',
    date_less_than=datetime.now() + timedelta(hours=1)
)

# URL 유효기간: 1시간
# 서명 없이 접근 불가
```

### 3. Geo-Blocking (지역 차단)

```yaml
Allowed Countries: KR, US, JP
Blocked Countries: CN, RU

Use Case:
  - 저작권 콘텐츠
  - 규제 준수
  - 라이선스 제한
```

---

## 📊 성능 지표

### Before/After CDN

```yaml
Without CDN:
  - TTFB: 500ms (국제)
  - Page Load: 3-5s
  - Origin Load: 1000 req/s

With CDN:
  - TTFB: 50ms (Edge)
  - Page Load: 1-2s
  - Origin Load: 100 req/s (90% Cache Hit)
  - Bandwidth: 70% 절감
```

---

## ⚡ 실무 고려사항

### 1. Cache Hit Ratio 향상

```yaml
목표: >90% Cache Hit Ratio

개선 방법:
  - Query String 정규화
  - 불필요한 Cookie 제거
  - Vary 헤더 최소화
  - 적절한 TTL 설정
```

### 2. 비용 최적화

```yaml
CloudFront 비용 절감:
  - 압축 활성화 (gzip, brotli)
  - 이미지 최적화 (WebP, AVIF)
  - Origin Shield (중간 캐시 계층)
  - PriceClass 조정 (지역 제한)
```

### 3. 모니터링

```yaml
주요 메트릭:
  - Cache Hit Ratio (%)
  - Request Count
  - Data Transfer (GB)
  - 4xx/5xx Error Rate
  - Origin Response Time

알림:
  - Cache Hit < 80%
  - 5xx Error > 1%
  - High Origin Load
```

---

## 🔗 관련 문서

- [Layer 2 정의](../00_Layer_2_정의.md)
- [Reverse Proxy](../04_Reverse_Proxy/00_Reverse_Proxy_정의.md)
- [DNS](../07_DNS/00_DNS_정의.md)

---

**문서 끝**
