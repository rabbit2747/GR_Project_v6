# Zone 2: Application Zone (애플리케이션 존)

## 📋 Zone 정보

| 속성 | 값 |
|------|-----|
| **Zone명** | Zone 2 - Application Zone |
| **한글명** | 애플리케이션 존 |
| **신뢰 수준** | Medium |
| **공격 노출도** | Medium |
| **버전** | v1.0.0 |

---

## 🎯 정의

Zone 2는 **비즈니스 로직을 실행하고 API를 제공하는 핵심 애플리케이션 영역**입니다.

**핵심 역할**:
- **비즈니스 로직**: 핵심 기능 구현 및 실행
- **API 제공**: RESTful API, GraphQL, gRPC 엔드포인트
- **데이터 처리**: Zone 3 (Data)와 안전하게 연동
- **서비스 간 통신**: 마이크로서비스 간 메시징

**보안 원칙**:
- **인증된 접근만 허용**: Zone 1에서 검증된 트래픽만 수신
- **최소 권한 원칙**: Database 접근 시 필요한 권한만
- **서비스 간 암호화**: mTLS로 서비스 간 통신 보호
- **입력 검증**: 모든 입력 데이터 재검증

---

## 🏗️ Zone 2 아키텍처

### 논리적 배치

```
┌─────────────────────────────────────────────┐
│           Zone 1 (Perimeter)                │
│         Load Balancer / WAF                 │
└─────────────────────────────────────────────┘
                     ↓ 검증된 트래픽
┌─────────────────────────────────────────────┐
│          Zone 2 (Application)               │
│                                             │
│  ┌──────────────────────────────────────┐  │
│  │      API Gateway (Kong)              │  │
│  │  /users, /orders, /products          │  │
│  └──────────────────────────────────────┘  │
│              ↓         ↓         ↓         │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐   │
│  │ User    │  │ Order   │  │ Product │   │
│  │ Service │  │ Service │  │ Service │   │
│  └─────────┘  └─────────┘  └─────────┘   │
│       ↕️            ↕️            ↕️        │
│  ┌──────────────────────────────────────┐  │
│  │   Message Queue (Kafka, RabbitMQ)    │  │
│  └──────────────────────────────────────┘  │
│                                             │
└─────────────────────────────────────────────┘
                     ↓ SQL/NoSQL Query
┌─────────────────────────────────────────────┐
│           Zone 3 (Data)                     │
│       Database, Object Storage              │
└─────────────────────────────────────────────┘
```

---

## 📊 배치 구성요소

### Very Common (필수 배치)

| 구성요소 | Layer | 목적 | 주요 제품 |
|---------|-------|------|----------|
| **Backend API** | Layer 7 | RESTful API 제공 | Node.js, Spring Boot, Django |
| **App Server** | Layer 7 | 비즈니스 로직 실행 | Tomcat, Gunicorn, Puma |
| **Message Queue** | Layer 6 | 비동기 메시징 | Kafka, RabbitMQ, AWS SQS |

### Common (자주 배치)

| 구성요소 | Layer | 목적 | 주요 제품 |
|---------|-------|------|----------|
| **API Gateway** | Layer 7 | API 라우팅, 인증 | Kong, AWS API Gateway, Apigee |
| **Service Mesh** | Layer 6 | 서비스 간 통신 관리 | Istio, Linkerd, Consul Connect |
| **Cache** | Layer 5 | 데이터 캐싱 | Redis, Memcached |

### Rare (특수 배치)

| 구성요소 | Layer | 목적 | 사용 사례 |
|---------|-------|------|----------|
| **GraphQL Server** | Layer 7 | GraphQL API | 복잡한 쿼리 요구사항 |
| **Serverless Functions** | Layer 7 | 이벤트 기반 처리 | AWS Lambda, Azure Functions |
| **Stream Processing** | Layer 6 | 실시간 데이터 처리 | Kafka Streams, Flink |

---

## 🔐 보안 정책

### 네트워크 정책

```yaml
인바운드 규칙:
  허용:
    - Zone 1 → Zone 2: HTTP/HTTPS (검증된 트래픽)
    - Zone 0 → Zone 2: 관리 API, 헬스 체크

  차단:
    - Zone 4 (사용자) → Zone 2: 직접 접근 절대 금지
    - 인터넷 → Zone 2: 모든 프로토콜

아웃바운드 규칙:
  허용:
    - Zone 2 → Zone 3: TLS 암호화 Database 연결
    - Zone 2 → Zone 1: API 응답
    - Zone 2 → Zone 0: 로그/메트릭 전송
    - Zone 2 내부: Service-to-Service (mTLS)

  제한:
    - Zone 2 → 인터넷: 극도로 제한적 (외부 API 호출만)
    - Zone 2 → Zone 4: 직접 연결 금지
```

### 인증 정책

```yaml
사용자 인증:
  - JWT Token 검증 (서명, 만료 시간)
  - OAuth 2.0 / OpenID Connect
  - Token Refresh: 15분 (Access Token), 7일 (Refresh Token)

Service-to-Service 인증:
  - mTLS (Mutual TLS): 양방향 인증서 검증
  - Service Account: 서비스별 전용 계정
  - API Key: 내부 서비스 간 (백업)

API 인가:
  - RBAC (Role-Based Access Control)
  - 권한 확인: IAM (Zone 0) 연동
  - 세밀한 권한: 리소스별, 작업별
```

### 로깅 정책

```yaml
로그 수집 범위:
  - 모든 API 호출 (endpoint, method, status, latency)
  - 비즈니스 로직 실행 (성공/실패)
  - Database 쿼리 (쿼리 타입, 소요 시간)
  - 에러 및 예외 (스택 트레이스)

로그 보존 기간:
  - 일반 로그: 90일
  - 에러 로그: 180일
  - 감사 로그 (audit): 1년

로그 형식:
  - 구조화: JSON 형식
  - 추적: Request ID (분산 추적)
  - 메타데이터: user_id, service_name, environment
```

### 데이터 취급

```yaml
민감 데이터 처리:
  - PII 암호화: 애플리케이션 레벨 암호화 (AES-256)
  - 마스킹: 로그에서 민감 데이터 제거/마스킹
  - 최소 수집: 필요한 데이터만 요청

Database 접근:
  - ORM 사용: SQL Injection 방어
  - 파라미터화 쿼리: Prepared Statement
  - 최소 권한: 읽기/쓰기 권한 분리

입력 검증:
  - 화이트리스트: 허용된 값만 수락
  - 타입 검증: 데이터 타입 확인
  - 길이 제한: 버퍼 오버플로 방어
  - Sanitization: XSS 방어 (HTML 이스케이프)
```

---

## 🚪 Zone 경계 통제

### Zone 1 → Zone 2 (인바운드)

```yaml
통제 메커니즘: API Gateway + Service Mesh

검증 절차:
  1. TLS 종료: HTTPS → HTTP (내부)
  2. JWT 검증: 서명, 만료 시간, 권한
  3. Rate Limiting: 사용자별 속도 제한
  4. Request Validation: 스키마 검증
  5. 라우팅: 마이크로서비스로 전달

보안 헤더 추가:
  - X-User-ID: 인증된 사용자 ID
  - X-Request-ID: 요청 추적용 UUID
  - X-Forwarded-For: 원본 클라이언트 IP
```

### Zone 2 → Zone 3 (아웃바운드)

```yaml
통제 메커니즘: Database Firewall + Connection Pool

접근 통제:
  1. Database 계정 검증
  2. 쿼리 타입 제한 (DDL 금지)
  3. 쿼리 복잡도 제한 (타임아웃)
  4. 연결 수 제한 (Connection Pool)

보안 조치:
  - TLS 암호화: Database 연결 암호화
  - Read Replica: 읽기 전용 쿼리 분리
  - Query Logging: 모든 쿼리 기록
```

---

## 💡 실전 배치 예시

### 예시 1: Startup (소규모)

```yaml
Zone 2 구성:
  - API Server: Node.js + Express (3대, Auto Scaling)
  - Cache: Redis (1대, ElastiCache)
  - Message Queue: AWS SQS (Managed)

아키텍처:
  - 모놀리식 API (단일 서비스)
  - Database: PostgreSQL (Zone 3)

트래픽:
  - ~100 req/sec
  - 평균 응답 시간: 100ms

비용:
  - EC2 (t3.medium × 3): ~$150/월
  - ElastiCache (t3.small): ~$30/월
  - SQS: ~$10/월
  - 총: ~$190/월

특징:
  - 간단한 구조
  - 빠른 배포
  - 운영 부담 낮음

보안 수준: ⭐⭐⭐⚪⚪
```

### 예시 2: Mid-size Company (중견기업)

```yaml
Zone 2 구성:
  - API Gateway: Kong (2대, HA)
  - Microservices: Node.js, Spring Boot (10개 서비스)
  - Cache: Redis Cluster (3 Master + 3 Replica)
  - Message Queue: Kafka (3 Brokers)
  - Service Mesh: Istio

아키텍처:
  - 마이크로서비스 (도메인별 분리)
  - Event-Driven Architecture

트래픽:
  - ~1,000 req/sec
  - 평균 응답 시간: 50ms

비용:
  - API Gateway: ~$200/월
  - Microservices (EC2): ~$1,000/월
  - Redis Cluster: ~$300/월
  - Kafka: ~$500/월
  - 총: ~$2,000/월

특징:
  - 서비스 독립 배포
  - 확장성 우수
  - 복잡도 증가

보안 수준: ⭐⭐⭐⭐⚪
```

### 예시 3: Enterprise (대기업)

```yaml
Zone 2 구성:
  - API Gateway: Kong Enterprise (HA Cluster)
  - Microservices: 100+ 서비스 (Kubernetes)
  - Cache: Redis Enterprise (Multi-AZ)
  - Message Queue: Kafka (MSK, 9 Brokers)
  - Service Mesh: Istio (전사 표준)
  - Serverless: AWS Lambda (이벤트 처리)

아키텍처:
  - 마이크로서비스 + Event-Driven + CQRS
  - Multi-Region Deployment

트래픽:
  - ~10,000 req/sec
  - 평균 응답 시간: 30ms

비용:
  - API Gateway: ~$2,000/월
  - Kubernetes (EKS): ~$5,000/월
  - Redis Enterprise: ~$2,000/월
  - Kafka (MSK): ~$3,000/월
  - Lambda: ~$1,000/월
  - 총: ~$13,000/월

특징:
  - 글로벌 서비스
  - 99.99% 가용성
  - 완전 자동화 CI/CD

보안 수준: ⭐⭐⭐⭐⭐
```

---

## 🔄 Zone 2 데이터 흐름

### 동기 요청 (Synchronous)

```
사용자 → Zone 1 (WAF/LB)
    ↓ 검증된 트래픽
API Gateway (Zone 2) ← JWT 검증
    ↓ 라우팅
User Service (Zone 2) ← 비즈니스 로직
    ↓ SQL Query
PostgreSQL (Zone 3) ← 데이터 조회
    ↑ Query Result
User Service ← 응답 가공
    ↑ JSON Response
API Gateway ← 로깅
    ↑
사용자 ← 200 OK
```

### 비동기 처리 (Asynchronous)

```
사용자 → Zone 1 → API Gateway
    ↓
Order Service ← 주문 생성
    ↓ Publish Event
Kafka (Zone 2) ← "order.created"
    ↓ Subscribe
Payment Service ← 결제 처리
    ↓ Publish Event
Kafka ← "payment.completed"
    ↓ Subscribe
Notification Service ← 이메일 발송
    ↓ Update Database
PostgreSQL (Zone 3)
```

---

## 🚨 Zone 2 인시던트 대응

### 시나리오 1: 서비스 장애

```yaml
탐지:
  - Health Check 실패 (3회 연속)
  - 에러율 급증 (>5%)
  - 응답 시간 증가 (>500ms)

대응:
  1. 자동: Auto Scaling 트리거
  2. 자동: 장애 서버 격리
  3. 수동: 로그 분석 (원인 파악)
  4. 수동: 긴급 패치 또는 롤백

복구:
  - 정상 트래픽 확인
  - 장애 서버 재시작 또는 교체
  - 사후 분석 (Post-mortem)

평균 대응 시간: 5-15분
```

### 시나리오 2: Database 연결 고갈

```yaml
탐지:
  - Database Connection Pool Exhausted
  - "Too many connections" 에러

대응:
  1. 긴급: Connection Pool 크기 증가
  2. 임시: 느린 쿼리 강제 종료
  3. 분석: 쿼리 성능 분석
  4. 최적화: 인덱스 추가, 쿼리 개선

예방:
  - Connection Pool 모니터링
  - Slow Query 로그 분석
  - Read Replica 활용

평균 대응 시간: 10-30분
```

### 시나리오 3: 메모리 누수

```yaml
탐지:
  - Memory 사용률 지속 증가
  - GC (Garbage Collection) 빈도 증가
  - Out of Memory 에러

대응:
  1. 긴급: 영향받은 인스턴스 재시작
  2. 분석: Heap Dump 수집 및 분석
  3. 수정: 메모리 누수 코드 수정
  4. 배포: 패치 배포

예방:
  - 메모리 프로파일링 (정기)
  - 단위 테스트에서 메모리 검증
  - 로드 테스트 (장시간)

평균 대응 시간: 1-4시간
```

---

## 📊 Zone 2 모니터링 메트릭

### 핵심 메트릭 (KPI)

```yaml
성능 메트릭:
  - Request Latency (ms): p50, p95, p99
  - Throughput (req/sec)
  - Error Rate (%): 4xx, 5xx

가용성 메트릭:
  - Uptime (%)
  - Health Check Success Rate
  - Circuit Breaker State

리소스 메트릭:
  - CPU Usage (%)
  - Memory Usage (%)
  - Database Connection Pool

비즈니스 메트릭:
  - Active Users (count)
  - Transactions per Second (TPS)
  - Revenue Impact (실시간)
```

### Grafana 대시보드 예시

```yaml
Dashboard 1: API 성능
  - Request Latency (p50, p95, p99)
  - Throughput (req/sec)
  - Error Rate (%)
  - Top 10 Slow APIs

Dashboard 2: 서비스 헬스
  - Service Status (up/down)
  - Health Check 성공률
  - Circuit Breaker State
  - 서비스별 CPU/Memory

Dashboard 3: Database
  - Connection Pool Usage
  - Query Latency
  - Slow Queries (>1s)
  - Deadlocks

Dashboard 4: 비즈니스
  - Active Users (실시간)
  - Transaction Success Rate
  - Revenue (실시간)
  - Top 10 API Endpoints
```

---

## 🔧 Zone 2 최적화 기법

### 애플리케이션 최적화

```yaml
코드 최적화:
  - N+1 Query 제거 (Eager Loading)
  - 불필요한 DB 호출 제거
  - 비동기 처리 (Async/Await)

캐싱 전략:
  - Cache Aside: 읽기 중심
  - Write Through: 쓰기 일관성
  - TTL: 데이터 유형별 차등 (1분 ~ 1시간)

Connection Pool:
  - Min: 10 connections
  - Max: 50 connections
  - Idle Timeout: 5분
```

### 마이크로서비스 최적화

```yaml
API 설계:
  - REST: CRUD 작업
  - GraphQL: 복잡한 쿼리
  - gRPC: 내부 서비스 통신

Circuit Breaker:
  - 실패 임계값: 5회
  - Timeout: 10초
  - Half-Open 후 재시도: 30초

Rate Limiting:
  - 사용자별: 100 req/min
  - 서비스별: 10,000 req/min
  - IP별: 1,000 req/min
```

### Database 최적화

```yaml
쿼리 최적화:
  - 인덱스 활용
  - JOIN 최소화
  - Pagination (LIMIT/OFFSET)

Read/Write 분리:
  - Master: 쓰기 전용
  - Replica: 읽기 전용
  - Replication Lag 모니터링

Connection Pooling:
  - HikariCP (Java)
  - Sequelize (Node.js)
  - SQLAlchemy (Python)
```

---

## 🔗 관련 문서

- [Security Zone 개요](../00_Security_Zone_개요.md)
- [Zone 1: Perimeter Zone](../Zone_1_Perimeter/00_Zone_1_정의.md)
- [Zone 3: Data Zone](../Zone_3_Data/00_Zone_3_정의.md)
- [Backend API 구성요소](../../01_차원1_Deployment_Layer/Layer_7_Application/02_Backend_API/00_Backend_API_정의.md)
- [API Gateway 구성요소](../../01_차원1_Deployment_Layer/Layer_7_Application/03_API_Gateway/00_API_Gateway_정의.md)
- [Message Queue 구성요소](../../01_차원1_Deployment_Layer/Layer_6_Runtime/03_Message_Queue/00_Message_Queue_정의.md)

---

**문서 끝**
