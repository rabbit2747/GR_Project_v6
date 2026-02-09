# Zone 3: Data (데이터 영역)

## 📋 문서 정보

**Zone**: 3 - Data
**영문명**: Data Zone
**한글명**: 데이터 영역
**위치**: 데이터 저장 및 처리 계층
**신뢰 수준**: High (60%)
**작성일**: 2025-01-20

---

## 🎯 Zone 정의

### 개요

**Zone 3 (Data)**는 **민감한 데이터의 저장 및 처리를 담당하는 고신뢰 영역**입니다.

```yaml
핵심 역할:
  - 데이터 저장 (관계형, 비관계형, 벡터)
  - 데이터 보안 (암호화, 접근 제어)
  - 백업 및 복구
  - 데이터 감사 (Audit Log)
  - 신뢰 수준: 60% (높은 신뢰)
```

### 계층 위치

```yaml
Zone 2 (Application) → Zone 3 (Data)
                          ↑
                    데이터 계층
                    - 최소 권한 접근
                    - 암호화 필수
                    - 외부 직접 접근 금지
```

---

## 📦 Zone 3 구성요소

### 1. Relational Database (관계형 DB)

**대표 DBMS**:
```yaml
PostgreSQL:
  - 오픈소스
  - ACID 완전 준수
  - pgvector (벡터 검색 확장) - v2.0

MySQL/MariaDB:
  - 오픈소스
  - 높은 성능
  - Replication

Oracle Database:
  - 엔터프라이즈 (유료)
  - RAC (고가용성)

SQL Server:
  - Microsoft
  - Windows 최적화
```

**보안 기능**:
```yaml
접근 제어:
  - 계정별 권한 분리 (READ, WRITE, ADMIN)
  - IP Allowlist (Zone 2에서만 접근)
  - SSL/TLS 연결 필수

암호화:
  - Encryption at Rest (디스크 암호화)
  - Encryption in Transit (TLS 1.2+)
  - 컬럼 레벨 암호화 (민감 데이터)

감사:
  - 모든 쿼리 로깅
  - 데이터 변경 이력 (Audit Log)
  - 로그 보존: 1년 이상
```

**Function Tags**:
- Primary: `D1.3` (Relational Storage)
- Tech Stack: `T2.1` (SQL Database)

**Zone 배치**: Zone 3 (Data)

---

### 2. NoSQL Database

**대표 DBMS**:
```yaml
Document Store:
  - MongoDB
  - Couchbase
  - AWS DocumentDB

Key-Value Store:
  - Redis (In-Memory)
  - Amazon DynamoDB
  - Memcached

Wide-Column Store:
  - Apache Cassandra
  - HBase
  - ScyllaDB

Graph Database:
  - Neo4j (관계 분석)
  - Amazon Neptune
  - ArangoDB
```

**Function Tags**:
- Primary: `D2.1` (NoSQL Storage)

**Zone 배치**: Zone 3 (Data)

---

### 3. Vector Database (벡터 DB) - v2.0 신규

**정의**: AI/ML 임베딩 벡터 저장 및 유사도 검색

**대표 벡터 DB**:
```yaml
Specialized Vector DB:
  - Pinecone (SaaS - Layer 0)
  - Weaviate (Self-hosted)
  - Qdrant (Self-hosted)
  - Milvus (Self-hosted)

RDBMS Extension:
  - pgvector (PostgreSQL 확장)
  - MySQL Vector (MySQL 8.0.31+)

NoSQL Extension:
  - MongoDB Atlas Vector Search
  - Redis Vector Similarity Search
```

**기능**:
```yaml
벡터 검색:
  - Cosine Similarity
  - Euclidean Distance
  - Dot Product

인덱싱:
  - HNSW (Hierarchical Navigable Small World)
  - IVF (Inverted File)
  - Annoy

사용 사례:
  - RAG (Retrieval-Augmented Generation)
  - 유사 상품 추천
  - 중복 콘텐츠 탐지
  - 이미지 유사도 검색
```

**Function Tags**:
- Primary: `D5.2` (Vector Search)
- Secondary: `A7.2` (RAG - Retrieval-Augmented Generation)

**Zone 배치**: Zone 3 (Data Zone)

---

### 4. Cache (캐시)

**대표 서비스**:
```yaml
In-Memory Cache:
  - Redis (가장 인기)
  - Memcached
  - AWS ElastiCache

사용 패턴:
  - 세션 저장 (Session Store)
  - API 응답 캐싱
  - DB 쿼리 결과 캐싱
  - Rate Limiting 카운터
```

**Function Tags**:
- Primary: `D2.1` (In-Memory Caching)
- Secondary: `P1.1` (Performance Optimization)

**Zone 배치**: Zone 3 (Data) - 일반적 배치

---

### 5. Object Storage

**대표 서비스**:
```yaml
클라우드:
  - AWS S3
  - Google Cloud Storage
  - Azure Blob Storage

Self-Hosted:
  - MinIO (S3 호환)
  - Ceph

용도:
  - 파일 업로드 (이미지, PDF, 동영상)
  - 백업 데이터
  - 로그 아카이빙
  - ML 모델 저장
```

**Function Tags**:
- Primary: `D4.1` (Object Storage)

**Zone 배치**: Zone 3 (Data)

---

### 6. Data Warehouse

**대표 서비스**:
```yaml
클라우드:
  - AWS Redshift
  - Google BigQuery
  - Snowflake
  - Azure Synapse Analytics

용도:
  - OLAP (분석)
  - 비즈니스 인텔리전스 (BI)
  - 데이터 마이닝
  - 대시보드 (Tableau, Looker)
```

**Function Tags**:
- Primary: `D6.1` (Data Warehouse)

**Zone 배치**: Zone 3 (Data)

---

## 🔐 Zone 3 보안 정책

### 신뢰 수준

```yaml
신뢰 수준: High (60%)
  - 최소 권한 원칙 (Least Privilege)
  - 데이터 암호화 필수
  - 외부 직접 접근 절대 금지

기본 원칙:
  - Defense in Depth (다층 방어)
  - Encryption Everywhere (저장/전송 모두 암호화)
  - Audit Everything (모든 접근 로깅)
  - Backup Regularly (정기 백업)
```

### 네트워크 정책

```yaml
인바운드:
  허용:
    - Zone 2 (Application) → Zone 3: TLS (인증된 연결만)
  차단:
    - Zone 0-A/0-B → Zone 3: 외부 직접 접근 절대 금지
    - Zone 1 → Zone 3: Perimeter에서 직접 접근 금지
    - Zone 5 → Zone 3: Endpoint에서 직접 접근 금지

아웃바운드:
  허용:
    - Zone 3 → Zone 4: Syslog, Metrics (로그/메트릭)
    - Zone 3 → Zone 2: Query Result (쿼리 응답)
  차단:
    - Zone 3 → Zone 0-A/0-B: 외부 직접 통신 금지
    - Zone 3 → Zone 1: 직접 통신 금지
```

---

## 🔄 Zone 3 데이터 흐름

### 일반 데이터 쿼리

```
API Server (Zone 2)
    ↓ SELECT * FROM users WHERE id = ? (TLS 연결)
PostgreSQL (Zone 3)
    ↓ 쿼리 실행, 로그 기록
    ↑ Query Result (암호화 전송)
API Server (Zone 2)
```

### Vector Search & RAG (v2.0)

```
API Server (Zone 2) ← 사용자 질문 수신
    ↓ Embedding 생성 (OpenAI API - Zone 0-B)
    ↓ Vector [0.1, 0.3, ..., 0.9]
Vector DB (Zone 3: pgvector)
    ↓ Cosine Similarity 검색
    ↑ 유사 문서 Top 5 반환
API Server (Zone 2) ← RAG Context 구성
    ↓ LLM 추론 요청 (Zone 0-B or Zone 2)
    ↑ LLM Response
사용자 (Zone 5)
```

### 백업 프로세스

```
Database (Zone 3)
    ↓ 매일 02:00 AM (Automated Backup)
S3 (Zone 3: Object Storage)
    ↓ Encryption at Rest (AES-256)
    ↓ Lifecycle Policy (90일 후 Glacier)
Glacier (Zone 3: Cold Storage)
```

---

## 🚫 Zone 3 접근 제어

### 허용되는 연결

| 출발 Zone | 목적 Zone | 프로토콜 | 용도 |
|----------|----------|---------|------|
| Zone 2 | Zone 3 | TLS | Database 쿼리, 캐시 접근 |
| Zone 3 | Zone 4 | Syslog, Metrics | 로그/메트릭 전송 |
| Zone 3 | Zone 2 | TLS | 쿼리 응답, 캐시 응답 |

### 절대 차단되는 연결

| 출발 Zone | 목적 Zone | 이유 |
|----------|----------|------|
| Zone 0-A/0-B | Zone 3 | 외부에서 직접 Database 접근 절대 금지 |
| Zone 1 | Zone 3 | Perimeter에서 직접 Data Zone 접근 금지 |
| Zone 5 | Zone 3 | Endpoint에서 직접 Database 접근 금지 |
| Zone 3 | Zone 0-A/0-B | Database에서 외부 직접 통신 금지 |

---

## 📊 실전 예시

### 예시 1: 사용자 데이터 조회

```yaml
시나리오: API에서 사용자 정보 조회

흐름:
  1. API Server (Zone 2) ← JWT 검증 ✅
  2. SQL 쿼리 생성:
     SELECT id, email, name FROM users WHERE id = $1
  3. PostgreSQL (Zone 3) 연결:
     - Connection Pool (최대 20 커넥션)
     - TLS 1.2+ 암호화
     - 쿼리 로그 기록
  4. 쿼리 실행:
     - Execution Time: 5ms
     - Result: { id: 123, email: "user@example.com", name: "홍길동" }
  5. API Server (Zone 2) ← 결과 수신
  6. 응답 반환 (Zone 5)

보안:
  - ORM 사용 (SQL Injection 방어)
  - 최소 권한 계정 (READ only)
  - 쿼리 로그 보존 (1년)
```

### 예시 2: 민감 데이터 저장 (PII)

```yaml
시나리오: 사용자 주민번호 저장

흐름:
  1. API Server (Zone 2) ← 주민번호 수신
  2. 컬럼 레벨 암호화:
     - AES-256
     - Key: AWS KMS (Zone 4)
     - 암호화된 값: "E3B0C44298FC1C149..."
  3. PostgreSQL (Zone 3) 저장:
     INSERT INTO users (id, ssn_encrypted) VALUES ($1, $2)
  4. Audit Log 기록:
     - 사용자: api_user
     - 작업: INSERT
     - 테이블: users
     - 시간: 2025-01-20 14:30:00

조회 시:
  1. API Server (Zone 2) ← 관리자 요청 (특별 권한 필요)
  2. PostgreSQL (Zone 3) 조회:
     SELECT id, ssn_encrypted FROM users WHERE id = $1
  3. API Server (Zone 2) ← 암호화된 값 수신
  4. 복호화:
     - AWS KMS (Zone 4) 호출
     - 원본 주민번호 반환
  5. 마스킹 후 응답: "123456-*******"

보안:
  - 평문 주민번호 절대 저장 금지 ✅
  - 복호화 권한 최소화 (관리자만)
  - Audit Log 필수
```

### 예시 3: Vector Search (RAG)

```yaml
시나리오: AI 챗봇 RAG 시스템

흐름:
  1. API Server (Zone 2) ← 사용자 질문: "배송 정책이 어떻게 돼?"
  2. Embedding 생성:
     - OpenAI API (Zone 0-B) 호출
     - Vector: [0.12, 0.34, ..., 0.78] (1536 차원)
  3. Vector DB (Zone 3: pgvector) 검색:
     SELECT content, embedding <=> $1 AS distance
     FROM knowledge_base
     ORDER BY distance ASC
     LIMIT 5
  4. 결과 반환:
     - "배송은 영업일 기준 2-3일 소요됩니다."
     - "무료 배송은 3만원 이상 구매 시..."
     - Distance: 0.15, 0.23, 0.31, 0.45, 0.52
  5. API Server (Zone 2) ← RAG Context 구성
  6. LLM 추론:
     - Prompt: System + Context + User Question
     - OpenAI API (Zone 0-B) or Self-hosted (Zone 2)
  7. 응답: "배송은 영업일 기준 2-3일 소요되며..."

성능:
  - Vector Search 응답 시간: <100ms
  - HNSW 인덱스 사용
  - Cache Hit율: 40% (유사 질문 캐싱)
```

---

## 🔒 데이터 취급 원칙

### 데이터 분류

```yaml
Public (공개):
  - 상품 정보, 블로그 글
  - 암호화: 불필요
  - 백업: 일주일

Internal (내부):
  - 주문 정보, 사용자 활동 로그
  - 암호화: Encryption at Rest
  - 백업: 일일

Confidential (기밀):
  - 사용자 이메일, 전화번호
  - 암호화: Encryption at Rest + in Transit
  - 백업: 일일 + 주간

Restricted (제한):
  - 주민번호, 카드 번호
  - 암호화: 컬럼 레벨 암호화 (AES-256)
  - 백업: 일일 + 주간 + 월간
  - 접근: 최소 권한 (관리자만)
```

### 백업 정책

```yaml
백업 주기:
  - 일일 백업: 매일 02:00 AM
  - 주간 백업: 매주 일요일
  - 월간 백업: 매월 1일

보존 기간:
  - 일일 백업: 30일
  - 주간 백업: 12주
  - 월간 백업: 12개월

백업 위치:
  - Primary: S3 (Zone 3)
  - Secondary: S3 다른 리전 (재해 복구)
  - Cold Storage: Glacier (90일 후)

복구 테스트:
  - 분기별 복구 테스트 필수
  - RPO (Recovery Point Objective): 24시간
  - RTO (Recovery Time Objective): 4시간
```

---

## 📋 로깅 및 모니터링

### 로그 수집

```yaml
수집 항목:
  - 모든 쿼리 로그 (SELECT, INSERT, UPDATE, DELETE)
  - 데이터 변경 이력 (Audit Log)
  - 접근 시도 로그 (성공, 실패)
  - 백업/복구 로그

보존:
  - 쿼리 로그: 1년
  - Audit Log: 2년 이상
  - 접근 실패: 2년 (보안 사고 대비)

전송:
  - SIEM (Zone 4): 실시간
  - S3 (Zone 3): 일일 배치
```

### 메트릭 수집

```yaml
Database Metrics:
  - 연결 수 (Current Connections)
  - 쿼리 응답 시간 (P50, P95, P99)
  - 디스크 사용량 (Disk Usage)
  - Replication Lag (복제 지연)

Cache Metrics:
  - Hit Rate (>80% 목표)
  - Memory Usage (<80%)
  - Eviction Rate

Vector DB Metrics (v2.0):
  - Search Latency (<100ms)
  - Index Size
  - Query Throughput (QPS)
```

---

## ✅ 체크리스트

### 보안

- [ ] Encryption at Rest 활성화
- [ ] TLS 1.2+ 연결 강제
- [ ] 계정별 권한 분리 (Least Privilege)
- [ ] IP Allowlist 설정 (Zone 2만 허용)
- [ ] 컬럼 레벨 암호화 (PII 데이터)

### 백업

- [ ] 일일 백업 자동화
- [ ] 백업 보존 정책 (30일 이상)
- [ ] 다중 리전 백업 (재해 복구)
- [ ] 분기별 복구 테스트
- [ ] RPO/RTO 정의 (24시간/4시간)

### 성능

- [ ] Connection Pooling 설정
- [ ] 쿼리 최적화 (Index, Explain Plan)
- [ ] Redis 캐싱 (Hit율 >80%)
- [ ] Replication 설정 (읽기 부하 분산)

### AI/ML (v2.0)

- [ ] Vector DB 인덱스 최적화 (HNSW, IVF)
- [ ] Vector Search 응답 시간 <100ms
- [ ] Embedding 암호화 저장
- [ ] Vector DB 백업 정책

### 모니터링

- [ ] Database 메트릭 수집 (Prometheus)
- [ ] Slow Query 알람 (>1초)
- [ ] 디스크 사용량 알람 (>80%)
- [ ] Audit Log 실시간 분석 (SIEM)

---

## 🔗 관련 문서

- [차원 2: Security Zone 개요](./00_차원2_개요.md)
- [Zone 2: Application Zone](./Zone_2_Application.md)
- [Zone 4: Management Zone](./Zone_4_Management.md)
- [Layer 5: Data Services](../01_차원1_Deployment_Layer/Layer_5_Data.md)

---

## 📞 변경 이력

**v2.0 (2025-01-20)** - Vector DB 추가:
- ✅ Vector Database 분류 (pgvector, Weaviate, Qdrant)
- ✅ RAG 시스템 데이터 흐름
- ✅ Vector Search 성능 최적화
- ✅ Embedding 암호화 정책

**v1.0** - 초기 작성:
- Zone 3 기본 정의
- Relational/NoSQL DB
- 백업 및 보안 정책

---

**문서 끝**
