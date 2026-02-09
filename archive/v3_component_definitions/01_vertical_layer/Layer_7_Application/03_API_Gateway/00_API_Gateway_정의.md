# API Gateway (API 게이트웨이)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | API Gateway |
| **한글명** | API 게이트웨이 |
| **Layer** | Layer 7 (Application) |
| **분류** | API Management |
| **Function Tag (Primary)** | A3.1 (API Gateway) |
| **Function Tag (Secondary)** | A3.2 (Service Mesh Gateway) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

API Gateway는 **마이크로서비스의 단일 진입점으로 라우팅, 인증, 속도 제한 등을 처리하는 중앙 관리 시스템**입니다.

---

## 🏗️ 주요 API Gateway

### 1. AWS API Gateway

**특징**: 완전 관리형, Lambda 통합

```yaml
# API Gateway 설정 예시
paths:
  /users:
    get:
      x-amazon-apigateway-integration:
        uri: arn:aws:apigateway:region:lambda:path/functions/arn:aws:lambda:region:account-id:function:getUserFunction/invocations
        httpMethod: POST
        type: aws_proxy
    post:
      x-amazon-apigateway-integration:
        uri: arn:aws:apigateway:region:lambda:path/functions/arn:aws:lambda:region:account-id:function:createUserFunction/invocations
        httpMethod: POST
        type: aws_proxy
```

**가격**:
```yaml
REST API:
  - 처음 333M requests: $3.50 per 1M requests
  - 그 이상: $2.80 per 1M requests

WebSocket API:
  - $1.00 per 1M messages
  - $0.25 per 1M connection minutes
```

---

### 2. Kong Gateway

**특징**: 오픈소스, 플러그인 기반

```yaml
# Kong 서비스 및 라우트 설정
services:
  - name: user-service
    url: http://user-service:3000

routes:
  - name: user-route
    service: user-service
    paths:
      - /api/users
    methods:
      - GET
      - POST

plugins:
  - name: rate-limiting
    config:
      minute: 100
      hour: 5000
  - name: jwt
    config:
      secret_is_base64: false
```

---

### 3. Azure API Management

**특징**: 엔터프라이즈급, 하이브리드/멀티 클라우드 지원

---

## 📊 API Gateway 주요 기능

### 1. 라우팅 & 로드밸런싱

```javascript
// Express Gateway 예시
apiEndpoints:
  users:
    host: '*'
    paths: '/api/users*'
  orders:
    host: '*'
    paths: '/api/orders*'

serviceEndpoints:
  userService:
    url: 'http://user-service:3000'
  orderService:
    url: 'http://order-service:4000'

policies:
  - proxy:
      - action:
          serviceEndpoint: userService
          changeOrigin: true
```

### 2. 인증 & 인가

```yaml
인증 방식:
  - API Key
  - JWT Token
  - OAuth 2.0
  - AWS IAM

예시 (JWT 검증):
  - Authorization: Bearer <token>
  - 게이트웨이에서 토큰 검증
  - 유효한 경우에만 백엔드로 전달
```

### 3. 속도 제한 (Rate Limiting)

```yaml
rate_limiting:
  anonymous:
    requests_per_second: 10
    requests_per_minute: 100

  authenticated:
    requests_per_second: 100
    requests_per_minute: 5000

  premium:
    requests_per_second: 1000
    requests_per_minute: 50000
```

### 4. 요청/응답 변환

```javascript
// Kong 플러그인 예시
{
  "name": "request-transformer",
  "config": {
    "add": {
      "headers": ["X-User-ID:123"],
      "querystring": ["version:v2"]
    },
    "remove": {
      "headers": ["X-Internal-Token"]
    }
  }
}
```

---

## 🔄 API Gateway 패턴

```yaml
Backend for Frontend (BFF):
  - 모바일용 API Gateway
  - 웹용 API Gateway
  - 각각 최적화된 응답 제공

Service Aggregation:
  - 여러 마이크로서비스 호출
  - 결과 병합하여 단일 응답 반환

Circuit Breaker:
  - 백엔드 실패 시 자동 차단
  - 폴백 응답 제공
```

---

## 🔒 Zone별 배치

| Zone | 배치 | 용도 |
|------|------|------|
| **Zone 1** | Very Common | Public API Gateway |
| **Zone 2** | Common | Internal API Gateway |

---

## 🔗 관련 문서

- [Layer 7 정의](../00_Layer_7_정의.md)
- [Backend API](../02_Backend_API/00_Backend_API_정의.md)
- [Service Mesh](../../Layer_6_Runtime/04_Service_Mesh/00_Service_Mesh_정의.md)

---

**문서 끝**
