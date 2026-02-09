# Zone 2: Application (애플리케이션 영역)

## 📋 문서 정보

**Zone**: 2 - Application
**영문명**: Application Zone
**한글명**: 애플리케이션 영역
**위치**: 비즈니스 로직 실행 계층
**신뢰 수준**: Medium (40%)
**작성일**: 2025-01-20

---

## 🎯 Zone 정의

### 개요

**Zone 2 (Application)**는 **비즈니스 로직을 실행하고 API를 제공하는 애플리케이션 계층**입니다.

```yaml
핵심 역할:
  - 비즈니스 로직 처리
  - API 제공 (REST, GraphQL, gRPC)
  - 인증 및 인가
  - 데이터 검증
  - 외부 서비스 연동 (Zone 0-B)
  - 신뢰 수준: 40% (중간 신뢰)
```

### 계층 위치

```yaml
Zone 1 (Perimeter) → Zone 2 (Application) → Zone 3 (Data)
                          ↑
                   비즈니스 로직 계층
                   - 인증/인가
                   - 데이터 검증
                   - 외부 API 호출
```

---

## 📦 Zone 2 구성요소

### 1. API Server (Backend API)

**대표 프레임워크**:
```yaml
Node.js:
  - Express.js
  - Fastify
  - NestJS (TypeScript)

Python:
  - FastAPI (추천)
  - Django REST Framework
  - Flask

Java:
  - Spring Boot
  - Quarkus
  - Micronaut

Go:
  - Gin
  - Echo
  - Fiber
```

**기능**:
```yaml
API 제공:
  - REST API (HTTP/JSON)
  - GraphQL (유연한 쿼리)
  - gRPC (내부 서비스 간 통신)

인증/인가:
  - JWT Token 검증
  - OAuth 2.0 / OIDC
  - API Key 검증
  - RBAC (Role-Based Access Control)

데이터 검증:
  - 입력 값 Sanitization
  - Schema Validation (Joi, Pydantic)
  - SQL Injection 방어
  - XSS 방어
```

**Function Tags**:
- Primary: `A1.5` (Backend API Server)
- Interface: `I1.1` (HTTP/REST), `I1.2` (GraphQL), `I1.3` (gRPC)

**Zone 배치**: Zone 2 (Application)

---

### 2. App Server (애플리케이션 서버)

**유형**:
```yaml
Stateless:
  - Microservices
  - Serverless Functions (AWS Lambda, Cloud Functions)
  - Container (Docker, Kubernetes Pods)

Stateful:
  - WebSocket Server
  - Realtime Server (Socket.IO, SignalR)
  - Session Server
```

**기능**:
```yaml
비즈니스 로직:
  - 주문 처리, 결제, 재고 관리
  - 사용자 등록, 프로필 관리
  - 알림 전송, 이메일 발송

세션 관리:
  - Redis Session Store
  - JWT Token
  - Cookie 관리

에러 처리:
  - 예외 핸들링
  - Retry 로직 (Exponential Backoff)
  - Circuit Breaker (장애 격리)
```

**Function Tags**:
- Primary: `A1.5` (Backend Application)
- Secondary: `R3.2` (Auto Scaling)

---

### 3. Message Queue (메시지 큐)

**대표 서비스**:
```yaml
Apache Kafka:
  - 대용량 이벤트 스트리밍
  - Pub/Sub 모델
  - 분산 처리

RabbitMQ:
  - AMQP 프로토콜
  - 다양한 Exchange 패턴
  - Dead Letter Queue

AWS SQS:
  - Fully Managed
  - Standard / FIFO Queue
  - Lambda 트리거

Redis Streams:
  - Redis 5.0+
  - 경량 메시지 큐
  - Consumer Group
```

**Function Tags**:
- Primary: `D3.3` (Event Streaming), `D3.1` (Message Queue)
- Interface: `I3.1` (AMQP), `I3.2` (Kafka Protocol)

**Zone 배치**: Zone 2 (Application) - 일반적 배치

---

### 4. Service Mesh (서비스 메시)

**대표 도구**:
```yaml
Istio:
  - Envoy Proxy 기반
  - mTLS (상호 TLS)
  - Traffic Management
  - Observability

Linkerd:
  - 경량 Service Mesh
  - Rust 기반 Proxy
  - 간단한 설정

Consul Connect:
  - HashiCorp
  - Service Discovery + Mesh
  - Multi-Cloud 지원
```

**기능**:
```yaml
Service-to-Service 통신:
  - mTLS (Mutual TLS) 자동 적용
  - Service Discovery
  - Load Balancing (Client-side)
  - Retry, Timeout, Circuit Breaker

Observability:
  - 분산 추적 (Distributed Tracing)
  - 메트릭 수집 (Prometheus)
  - 로그 수집
```

**Function Tags**:
- Primary: `R5.3` (Service Mesh)
- Control: `S5.3` (mTLS), `M2.1` (Distributed Tracing)

---

### 5. AI/ML 추론 엔진 (v2.0 추가)

**Self-hosted LLM**:
```yaml
Inference Server:
  - vLLM (고성능 LLM 서빙)
  - Text Generation Inference (Hugging Face)
  - LM Studio (로컬 개발)
  - Ollama (로컬 LLM)

Model:
  - Llama 3.1 (Meta)
  - Mistral 7B
  - Gemma 2 (Google)
  - Qwen 2 (Alibaba)

GPU 요구사항:
  - 7B Model: RTX 3090 (24GB) 이상
  - 70B Model: A100 (80GB) × 2 이상
```

**Function Tags**:
- Primary: `A7.1` (LLM Inference)
- Tech Stack: `T1.3` (Python), `T5.1` (PyTorch), `T5.2` (CUDA)

**Zone 배치**: Zone 2 (Application)

---

## 🔐 Zone 2 보안 정책

### 신뢰 수준

```yaml
신뢰 수준: Medium (40%)
  - 인증된 트래픽만 처리
  - 애플리케이션 레벨 보안 적용
  - 최소 권한 원칙 (Least Privilege)

기본 원칙:
  - 인증 필수 (JWT, OAuth)
  - 입력 값 철저한 검증
  - 민감 데이터 암호화
  - 에러 메시지 최소화 (내부 정보 노출 금지)
```

### 네트워크 정책

```yaml
인바운드:
  허용:
    - Zone 1 (Perimeter) → Zone 2: HTTP/HTTPS (검증된 트래픽)
    - Zone 5 (Endpoint) → Zone 1 → Zone 2 (내부 사용자)
  차단:
    - Zone 0-A/0-B → Zone 2 직접 접근 절대 금지
    - Zone 5 → Zone 2 직접 접근 금지

아웃바운드:
  허용:
    - Zone 2 → Zone 3: TLS (Database 쿼리)
    - Zone 2 → Zone 0-B: HTTPS (외부 API 호출: LLM, Payment)
    - Zone 2 → Zone 1: HTTP (응답)
    - Zone 2 → Zone 4: Syslog, Metrics
  차단:
    - Zone 2 → Zone 0-A: 일반 인터넷 직접 접근 금지
```

---

## 🔄 Zone 2 트래픽 흐름

### 일반 API 요청

```
사용자 (Zone 5) → Zone 1 (WAF, Load Balancer)
    ↓ HTTPS
API Server (Zone 2)
    ↓ JWT 검증 ✅
    ↓ 비즈니스 로직 실행
    ↓ SQL Query
Database (Zone 3)
    ↑ Query Result
API Server (Zone 2)
    ↑ JSON Response
Zone 1 → 사용자 (Zone 5)
```

### AI/ML 워크로드 (v2.0)

```
사용자 (Zone 5) → Zone 1 → API Server (Zone 2)
    ↓ Embedding 요청
OpenAI API (Zone 0-B) ← TLS 1.2+, API Key
    ↑ Vector Embedding
API Server (Zone 2)
    ↓ Vector Search
Vector DB (Zone 3: pgvector, Weaviate)
    ↑ 유사 문서 반환
API Server (Zone 2) ← RAG Context 구성
    ↓ LLM 추론 요청
Self-hosted LLM (Zone 2) or OpenAI API (Zone 0-B)
    ↑ LLM Response
API Server (Zone 2)
    ↑ HTTPS
사용자 (Zone 5)
```

### 외부 결제 처리

```
사용자 (Zone 5) → Zone 1 → API Server (Zone 2)
    ↓ Payment Token (브라우저 → Stripe → 우리 서버)
API Server (Zone 2)
    ↓ HTTPS, API Key
Stripe API (Zone 0-B)
    ↑ 결제 성공/실패
API Server (Zone 2)
    ↓ 주문 정보 저장
Database (Zone 3)
    ↑ 저장 완료
API Server (Zone 2)
    ↑ JSON Response
사용자 (Zone 5)
```

---

## 🚫 Zone 2 접근 제어

### 허용되는 연결

| 출발 Zone | 목적 Zone | 프로토콜 | 용도 |
|----------|----------|---------|------|
| Zone 1 | Zone 2 | HTTP/HTTPS | 검증된 트래픽 전달 |
| Zone 2 | Zone 3 | TLS | Database 쿼리 |
| Zone 2 | Zone 0-B | HTTPS | 외부 API 호출 (LLM, Payment) |
| Zone 2 | Zone 1 | HTTP | 응답 반환 |
| Zone 2 | Zone 4 | Syslog, Metrics | 로그/메트릭 전송 |

### 차단되는 연결

| 출발 Zone | 목적 Zone | 이유 |
|----------|----------|------|
| Zone 0-A/0-B | Zone 2 | 외부에서 직접 App Server 접근 금지 |
| Zone 5 | Zone 2 | 사용자가 직접 App Server 접근 금지 (Zone 1 경유 필수) |
| Zone 2 | Zone 0-A | 일반 인터넷 직접 접근 금지 |
| Zone 2 | Zone 5 | App Server에서 Endpoint 직접 접근 금지 |

---

## 📊 실전 예시

### 예시 1: 사용자 등록 API

```yaml
시나리오: 사용자가 회원가입

요청:
  POST /api/auth/register
  Body: { email, password, name }

흐름:
  1. Zone 1 (WAF) → 입력 값 검증 ✅
  2. Zone 1 (Load Balancer) → API Server (Zone 2)
  3. API Server (Zone 2):
     - Email 형식 검증 ✅
     - 비밀번호 강도 체크 ✅
     - 비밀번호 해싱 (bcrypt)
     - Database (Zone 3) 저장
  4. JWT Token 생성
  5. 응답: { token, user }

보안:
  - 비밀번호 평문 저장 절대 금지
  - Email 중복 확인
  - Rate Limiting (회원가입: 10/hour per IP)
```

### 예시 2: AI 챗봇 (LLM API 호출)

```yaml
시나리오: 사용자가 AI 챗봇 질문

요청:
  POST /api/chat
  Body: { message: "주문 배송 조회해줘", user_id: "U12345" }

흐름:
  1. API Server (Zone 2) ← JWT 검증 ✅
  2. PII 데이터 제거 (이름, 주민번호 등)
  3. RAG 시스템:
     - Embedding 생성 (OpenAI API - Zone 0-B)
     - Vector DB 검색 (Zone 3: pgvector)
     - 유사 문서 반환 (주문 관련 FAQ)
  4. LLM 추론:
     - OpenAI API (Zone 0-B) or Self-hosted (Zone 2)
     - Prompt: System + Context + User Message
  5. 응답 필터링 (민감 정보 마스킹)
  6. 응답: { answer: "주문 번호를 알려주시면 조회해드릴게요" }

보안:
  - PII 데이터 LLM 전송 금지 ✅
  - Prompt Injection 필터링
  - LLM 비용 모니터링 (월 $10,000 임계값)
```

### 예시 3: 결제 처리 (Stripe)

```yaml
시나리오: 사용자가 상품 결제

흐름:
  1. 사용자 (Zone 5 - 브라우저):
     - Stripe.js로 카드 정보 입력
     - Stripe API (Zone 0-B) 직접 전송
     - Payment Token 수신

  2. 브라우저 → API Server (Zone 2):
     - POST /api/payment
     - Body: { token, amount, order_id }

  3. API Server (Zone 2):
     - JWT 검증 ✅
     - Order 검증 (DB - Zone 3)
     - Stripe API (Zone 0-B) 호출:
       POST https://api.stripe.com/v1/charges
       - API Key (환경 변수)
       - amount, currency, source (token)

  4. Stripe API (Zone 0-B) → 결제 성공

  5. API Server (Zone 2):
     - 주문 상태 업데이트 (DB - Zone 3)
     - 결제 로그 암호화 저장
     - 응답: { status: "success" }

보안:
  - 카드 번호 절대 우리 서버 경유 금지 ✅
  - PCI-DSS 준수 (Stripe에 위임)
  - 결제 로그 암호화 저장
```

---

## 🔒 데이터 취급 원칙

### Zone 2에서 처리 가능한 데이터

```yaml
허용:
  - 비즈니스 데이터 (주문, 상품, 사용자)
  - 인증 토큰 (JWT, Session)
  - 로그 (에러, 비즈니스 로직)

제한적 허용 (암호화 필수):
  - PII (개인 식별 정보)
  - 결제 정보 (Token만, 카드 번호 금지)

금지:
  - 비밀번호 평문 저장/로깅
  - 카드 번호 원본 (PCI-DSS 위반)
  - API Key 평문 로깅
```

### 외부 API 호출 시 데이터 보호

```yaml
LLM API (Zone 0-B):
  ❌ 금지: 고객 PII, 비즈니스 기밀
  ✅ 허용: 일반 텍스트, 익명화된 데이터

Payment API (Zone 0-B):
  ✅ 허용: Payment Token, 주문 금액
  ❌ 금지: 원본 카드 번호

SaaS API (Zone 0-B):
  ⚠️ 제한적: PII (DPA 체결 시)
  ✅ 허용: 비즈니스 데이터
```

---

## 📋 로깅 및 모니터링

### 로그 수집

```yaml
수집 항목:
  - API 호출 로그 (Endpoint, Method, Status Code)
  - 비즈니스 로직 실행 로그
  - 에러 및 예외 로그
  - 외부 API 호출 로그 (LLM, Payment)

보존:
  - 정상 로그: 90일
  - 에러 로그: 180일
  - 보안 사고: 1년 이상

민감 정보 마스킹:
  - 비밀번호, API Key, 카드 번호 절대 로깅 금지
  - PII 마스킹 (이메일: u***@example.com)
```

### 메트릭 수집

```yaml
Application Metrics:
  - 요청 수 (per Endpoint)
  - 응답 시간 (P50, P95, P99)
  - 에러율 (<1% 목표)
  - 동시 접속자 수

Business Metrics:
  - 주문 수 (일별, 월별)
  - 결제 성공률 (>99%)
  - 회원가입 수

AI/ML Metrics (v2.0):
  - LLM API 호출 수
  - LLM 비용 (일별, 월별)
  - Vector Search 응답 시간
  - Prompt Injection 감지 횟수
```

---

## ✅ 체크리스트

### 보안

- [ ] JWT Token 검증 적용
- [ ] 입력 값 Sanitization (SQL Injection, XSS 방어)
- [ ] 비밀번호 해싱 (bcrypt, Argon2)
- [ ] API Key 환경 변수 저장
- [ ] HTTPS Only (내부 통신 포함)

### 성능

- [ ] Database Connection Pooling
- [ ] Redis 캐싱 (세션, 자주 조회되는 데이터)
- [ ] 비동기 처리 (Message Queue)
- [ ] API 응답 시간 <200ms (P95)

### AI/ML (v2.0)

- [ ] PII 데이터 LLM 전송 금지
- [ ] Prompt Injection 필터링
- [ ] LLM 비용 모니터링 (월 임계값)
- [ ] Vector DB 인덱스 최적화 (<100ms)

### 모니터링

- [ ] APM 설정 (Datadog, New Relic)
- [ ] 에러 추적 (Sentry)
- [ ] 로그 수집 (ELK, Loki)
- [ ] 알람 설정 (에러율 >1%, 응답 시간 >500ms)

---

## 🔗 관련 문서

- [차원 2: Security Zone 개요](./00_차원2_개요.md)
- [Zone 1: Perimeter Zone](./Zone_1_Perimeter.md)
- [Zone 3: Data Zone](./Zone_3_Data.md)
- [Layer 7: Application & AI](../01_차원1_Deployment_Layer/Layer_7_Application_AI.md)

---

## 📞 변경 이력

**v2.0 (2025-01-20)** - AI/ML 통합:
- ✅ AI/ML 추론 엔진 배치 (Zone 2)
- ✅ LLM API 호출 흐름 (Zone 0-B 연동)
- ✅ Vector DB 연동 (Zone 3)
- ✅ Prompt Injection 방어
- ✅ AI/ML 메트릭 추가

**v1.0** - 초기 작성:
- Zone 2 기본 정의
- API Server, Message Queue

---

**문서 끝**
