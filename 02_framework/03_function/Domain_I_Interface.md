# Domain I: Interface (인터페이스)

**버전**: v2.0 (NEW)
**최종 수정**: 2025-11-20
**목적**: 통신 프로토콜, API 스타일, 데이터 포맷 매핑

---

## 1. Domain 개요

### 1.1 정의
Interface Domain은 **시스템 간 통신 프로토콜, API 스타일, 데이터 포맷**을 나타냅니다.

### 1.2 v2.0 신규 추가 사유
**핵심 목적**: 시스템 통신 흐름의 명확한 매핑

```
기존 (v1.0):
  Frontend → Backend API
  문제: 어떤 프로토콜? 어떤 인증? 어떤 데이터 포맷?

신규 (v2.0):
  Frontend (A1.1) → I1.1 (REST/JSON) → S2.2.3 (JWT) → Backend (A2.2)
  해결: 프로토콜, 인증, 포맷 명확화
```

### 1.3 핵심 목표
1. **통신 흐름 가시화**: 시스템 간 통신 프로토콜 명확화
2. **보안 통제 매핑**: 인증/암호화 프로토콜 추적
3. **성능 최적화**: 프로토콜별 성능 특성 파악

---

## 2. Tag 체계

### Tag 구조
```
I + [숫자] + (선택적 서브 카테고리)
예: I1.1 (HTTP REST), I2.1 (gRPC)
```

---

## 3. Tag 상세 정의

### I1: HTTP-based Protocols

**목적**: HTTP/HTTPS 기반 통신

**구성 요소**:
- **I1.1**: RESTful API (HTTP/1.1, HTTP/2)
  - Methods: GET, POST, PUT, DELETE, PATCH
  - Format: JSON, XML
  - Authentication: JWT, OAuth 2.0, API Key

- **I1.2**: GraphQL
  - Query, Mutation, Subscription
  - Format: JSON
  - Real-time: WebSocket

- **I1.3**: WebSocket
  - Bi-directional communication
  - Use Case: Real-time chat, notifications

- **I1.4**: Server-Sent Events (SSE)
  - Uni-directional (Server → Client)
  - Use Case: Live updates, dashboards

**사용 예시**:
```yaml
REST API Communication (I1.1):
  Tags: [I1.1, A3.1, S2.2.3, N7.1]

  Frontend (Zone 5) → API Gateway (Zone 1):
    Protocol: HTTPS (HTTP/2)
    Method: GET /api/users/{id}
    Headers:
      - Authorization: Bearer <JWT>
      - Content-Type: application/json
    Authentication: JWT (S2.2.3)
    Encryption: TLS 1.3 (S3.1)

  API Gateway → Backend Service (Zone 2):
    Protocol: HTTP/1.1
    Method: GET /users/{id}
    Headers:
      - X-User-ID: extracted from JWT
      - X-Request-ID: trace-id
    Service Mesh: mTLS (S3.1, N6.2)

  Response:
    Status: 200 OK
    Format: JSON
    Body:
      {
        "id": 12345,
        "name": "John Doe",
        "email": "j***@example.com"  # Masked (S3.3)
      }
```

**MITRE ATT&CK**: T1071.001 (Web Protocols)

---

### I2: RPC (Remote Procedure Call)

**목적**: 효율적인 서비스 간 통신

**구성 요소**:
- **I2.1**: gRPC
  - Protocol: HTTP/2
  - Format: Protocol Buffers
  - Use Case: Microservices communication

- **I2.2**: Apache Thrift
  - Format: Binary
  - Use Case: Cross-language RPC

**사용 예시**:
```yaml
gRPC Communication (I2.1):
  Tags: [I2.1, A2.2, N6.2, S3.1]

  User Service → Order Service (Zone 2):
    Protocol: gRPC (HTTP/2)
    Method: GetOrdersByUserId
    Request (Protobuf):
      message GetOrdersRequest {
        int64 user_id = 1;
        int32 limit = 2;
      }

    Response (Protobuf):
      message GetOrdersResponse {
        repeated Order orders = 1;
      }

    Features:
      - Streaming: Server-side streaming
      - Encryption: mTLS (S3.1)
      - Load Balancing: Client-side (Envoy)
      - Retry: Exponential backoff

  Performance:
    - Latency: 5ms (vs 50ms for REST)
    - Throughput: 10x higher than REST
    - Payload: 50% smaller (Protobuf vs JSON)
```

**MITRE ATT&CK**: T1071 (Application Layer Protocol)

---

### I3: Message Queue Protocols

**목적**: 비동기 메시징

**구성 요소**:
- **I3.1**: AMQP (Advanced Message Queuing Protocol)
  - RabbitMQ, ActiveMQ
  - Reliable delivery

- **I3.2**: Kafka Protocol
  - Apache Kafka
  - Stream processing

- **I3.3**: MQTT (Message Queuing Telemetry Transport)
  - IoT devices
  - Lightweight

**사용 예시**:
```yaml
Kafka Messaging (I3.2):
  Tags: [I3.2, D4.2, A5.1, R5.1]

  Order Service (Zone 2) → Kafka (Zone 2) → Payment Service (Zone 2):
    Topic: order-created
    Protocol: Kafka Protocol (Binary)
    Format: JSON
    Partition Key: user_id

    Message:
      {
        "order_id": 12345,
        "user_id": 67890,
        "total_amount": 99.99,
        "timestamp": "2025-11-20T10:30:00Z"
      }

    Consumer Groups:
      - payment-service-group: Process payments
      - analytics-service-group: Track metrics
      - notification-service-group: Send emails

    Delivery Guarantee: At-least-once
    Retention: 7 days
```

**MITRE ATT&CK**: T1071 (Application Layer Protocol)

---

### I4: Authentication & Authorization Protocols

**목적**: 인증/인가 프로토콜

**구성 요소**:
- **I4.1**: OAuth 2.0
  - Authorization Code Flow
  - Client Credentials Flow

- **I4.2**: OpenID Connect (OIDC)
  - Identity layer on OAuth 2.0
  - ID Token (JWT)

- **I4.3**: SAML 2.0
  - Enterprise SSO
  - XML-based

- **I4.4**: LDAP/Active Directory
  - Directory services
  - User/Group management

**사용 예시**:
```yaml
OAuth 2.0 Flow (I4.1):
  Tags: [I4.1, S2.1.3, S2.2.3, I1.1]

  Authorization Code Flow:
    1. User → Authorization Server (Keycloak):
       GET /oauth/authorize?
         client_id=web-app&
         redirect_uri=https://app.example.com/callback&
         response_type=code&
         scope=read:users write:orders

    2. Authorization Server → User:
       Redirect to login page

    3. User: Authenticate (username/password + MFA)

    4. Authorization Server → User:
       Redirect: https://app.example.com/callback?code=ABC123

    5. Frontend → Authorization Server:
       POST /oauth/token
       {
         "grant_type": "authorization_code",
         "code": "ABC123",
         "client_id": "web-app",
         "client_secret": "***"
       }

    6. Authorization Server → Frontend:
       {
         "access_token": "eyJhbGc...",
         "token_type": "Bearer",
         "expires_in": 3600,
         "refresh_token": "a1b2c3..."
       }

    7. Frontend → API:
       GET /api/users/profile
       Authorization: Bearer eyJhbGc...
```

**MITRE ATT&CK**: T1078 (Valid Accounts)

---

### I5: Database Protocols

**목적**: 데이터베이스 통신 프로토콜

**구성 요소**:
- **I5.1**: PostgreSQL Wire Protocol
  - Port: 5432
  - Encryption: TLS

- **I5.2**: MySQL Protocol
  - Port: 3306

- **I5.3**: MongoDB Wire Protocol
  - Port: 27017

- **I5.4**: Redis Protocol (RESP)
  - Port: 6379

**사용 예시**:
```yaml
PostgreSQL Connection (I5.1):
  Tags: [I5.1, D1.1, S3.1, T2.1]

  Backend Service (Zone 2) → PostgreSQL (Zone 3):
    Protocol: PostgreSQL Wire Protocol
    Encryption: TLS 1.3 (S3.1)
    Authentication: SCRAM-SHA-256
    Connection Pool: PgBouncer (max 100)

    Query:
      SELECT id, name, email FROM users WHERE id = $1;

    Security:
      - Network ACL: Only from Zone 2
      - TLS Required: sslmode=require
      - Audit Logging: pg_audit (C4.1)
```

---

### I6: File Transfer & Storage Protocols

**목적**: 파일 전송 및 스토리지 접근

**구성 요소**:
- **I6.1**: S3 API
  - AWS S3, MinIO, Ceph
  - RESTful API

- **I6.2**: FTP/SFTP
  - File transfer
  - Secure: SFTP (SSH)

- **I6.3**: NFS/SMB
  - Network File System
  - Windows: SMB/CIFS

**사용 예시**:
```yaml
S3 API (I6.1):
  Tags: [I6.1, R3.2, S3.2, D3.1]

  Backend Service → S3 Bucket:
    Protocol: HTTPS (S3 API)
    Operation: PutObject
    Encryption:
      - In Transit: TLS 1.3 (S3.1)
      - At Rest: SSE-KMS (S3.2)

    Request:
      PUT /bucket/images/avatar-12345.jpg
      Headers:
        - x-amz-server-side-encryption: aws:kms
        - x-amz-server-side-encryption-aws-kms-key-id: key-id

    Access Control:
      - Bucket Policy: Deny public access
      - IAM Role: backend-service-role (S6.2)
```

---

## 4. 통신 흐름 매핑

### Example: Full Stack Communication Flow

```yaml
User (Zone 5) → Frontend (Zone 5) → API Gateway (Zone 1) → Backend (Zone 2) → Database (Zone 3)

1. Frontend → API Gateway:
   - Interface: I1.1 (HTTPS/REST/JSON)
   - Auth: I4.1 (OAuth 2.0 / JWT)
   - Encryption: S3.1 (TLS 1.3)
   - Tags: [I1.1, I4.1, S3.1, N1.2]

2. API Gateway → Backend:
   - Interface: I1.1 (HTTP/REST) or I2.1 (gRPC)
   - Auth: S2.2.3 (JWT validation)
   - Encryption: S3.1 (mTLS via Service Mesh)
   - Tags: [I1.1 or I2.1, S2.2.3, S3.1, N6.2]

3. Backend → Database:
   - Interface: I5.1 (PostgreSQL Wire Protocol)
   - Auth: SCRAM-SHA-256
   - Encryption: S3.1 (TLS)
   - Tags: [I5.1, S3.1, D1.1]

4. Backend → Message Queue:
   - Interface: I3.2 (Kafka Protocol)
   - Auth: SASL/SCRAM
   - Tags: [I3.2, D4.2, A5.1]

5. Backend → S3:
   - Interface: I6.1 (S3 API / HTTPS)
   - Auth: IAM Role (S6.2)
   - Encryption: S3.1 (TLS) + S3.2 (SSE-KMS)
   - Tags: [I6.1, S3.1, S3.2, R3.2]
```

---

## 5. Layer/Zone 연관성

| Interface Tag | Protocol | Layer | Zone |
|--------------|----------|-------|------|
| I1.1 (REST) | HTTPS | L1-L5 | Zone 1-5 |
| I2.1 (gRPC) | HTTP/2 | L2 | Zone 2 |
| I3.2 (Kafka) | Kafka Protocol | L2-L3 | Zone 2-3 |
| I4.1 (OAuth 2.0) | HTTPS | L1 | Zone 1 |
| I5.1 (PostgreSQL) | PostgreSQL Wire | L2-L3 | Zone 2-3 |
| I6.1 (S3 API) | HTTPS | L2-L3 | Zone 2-3 |

---

## 6. MITRE ATT&CK 매핑

| Technique | Interface Tag | 대응 통제 |
|-----------|--------------|----------|
| T1071.001 (Web Protocols) | I1.1, I1.2 | WAF (S1.1), TLS (S3.1) |
| T1071.004 (DNS) | I7.1 | DNS Security, DNSSEC |
| T1090 (Proxy) | I1.1 | Proxy detection, IP reputation |
| T1557 (MITM) | All Interface Tags | TLS/mTLS (S3.1) |

---

## 7. 데이터베이스 스키마 (Atomized Format)

```sql
CREATE TABLE interface_mappings (
    id SERIAL PRIMARY KEY,
    interface_tag VARCHAR(10) NOT NULL,    -- I1.1, I2.1, etc.
    protocol VARCHAR(100) NOT NULL,        -- HTTPS, gRPC, Kafka
    port INT,                              -- 443, 5432, 9092
    format VARCHAR(50),                    -- JSON, Protobuf, Binary
    encryption_tag VARCHAR(10),            -- S3.1 (TLS)
    auth_tag VARCHAR(10),                  -- S2.2.3 (JWT), I4.1 (OAuth)
    source_component_id INT REFERENCES components(id),
    target_component_id INT REFERENCES components(id),
    source_layer VARCHAR(10),
    source_zone VARCHAR(10),
    target_layer VARCHAR(10),
    target_zone VARCHAR(10),
    created_at TIMESTAMP DEFAULT NOW()
);
```

---

## 8. 다음 단계

- **Domain A (Application)**: A3.1과 통합 (API 프로토콜)
- **Domain N (Networking)**: N7.1과 통합 (API Gateway)
- **Domain S (Security)**: S2.2, S3.1과 통합 (인증/암호화)

---

**문서 종료**
