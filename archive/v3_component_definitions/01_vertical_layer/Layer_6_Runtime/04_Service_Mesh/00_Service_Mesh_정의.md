# Service Mesh (서비스 메시)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Service Mesh |
| **한글명** | 서비스 메시 |
| **Layer** | Layer 6 (Runtime) |
| **분류** | Service Communication |
| **Function Tag (Primary)** | R4.1 (Istio) |
| **Function Tag (Secondary)** | R4.2 (Linkerd) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

서비스 메시는 **마이크로서비스 간 통신을 관리하는 인프라 계층**입니다.

---

## 🏗️ 주요 서비스 메시

### 1. Istio

**특징**: 풍부한 기능, Envoy Proxy 기반

**주요 기능**:
```yaml
트래픽 관리:
  - Canary Deployment
  - A/B Testing
  - 트래픽 라우팅

보안:
  - mTLS 자동 암호화
  - 인증/인가

관찰성:
  - 분산 추적
  - 메트릭 수집
  - 서비스 그래프
```

**설정 예시**:
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: myapp
spec:
  hosts:
  - myapp
  http:
  - match:
    - headers:
        end-user:
          exact: test
    route:
    - destination:
        host: myapp
        subset: v2
  - route:
    - destination:
        host: myapp
        subset: v1
      weight: 90
    - destination:
        host: myapp
        subset: v2
      weight: 10
```

---

### 2. Linkerd

**특징**: 경량, 빠름, 간단

---

## 📊 Service Mesh 기능

```yaml
트래픽 관리:
  - Load Balancing
  - Retry & Timeout
  - Circuit Breaking

보안:
  - mTLS
  - 인증/인가

관찰성:
  - Metrics (Prometheus)
  - Tracing (Jaeger)
  - Logging
```

---

## 🔒 Zone별 배치

| Zone | 배치 | 용도 |
|------|------|------|
| **Zone 2** | Common | Service Mesh Control Plane |

---

## 🔗 관련 문서

- [Layer 6 정의](../00_Layer_6_정의.md)
- [Orchestration](../02_Orchestration/00_Orchestration_정의.md)

---

**문서 끝**
