# Domain D: Data (데이터)

**버전**: v2.0
**최종 수정**: 2025-11-20
**목적**: 데이터 저장, 처리, 백업, Vector DB (AI/ML)

---

## 1. Domain 개요

### 1.1 정의
Data Domain은 **데이터 저장, 검색, 처리, 백업** 기능 집합입니다.

### 1.2 v1.0 → v2.0 변경사항
- Vector Database (D2.2) 추가 (AI/ML 지원)
- Data Streaming (D4.3) 추가
- Total tags: 25 → 30+

### 1.3 핵심 목표
1. **데이터 무결성**: ACID 트랜잭션
2. **성능**: 빠른 읽기/쓰기
3. **가용성**: 복제, 백업
4. **확장성**: Horizontal/Vertical Scaling

---

## 2. Tag 상세 정의

### D1: Relational Database

**구성 요소**:
- **D1.1**: RDBMS (PostgreSQL, MySQL, Oracle)
- **D1.2**: ACID Transactions
- **D1.3**: SQL Query
- **D1.4**: Replication (Master-Slave, Multi-Master)

**Layer/Zone**: L3, Zone 3

**사용 예시**:
```yaml
PostgreSQL (Zone 3):
  Tags: [D1.1, D1.2, S3.2, M2.3]
  Version: 15.4
  Replication: Streaming replication (2 replicas)
  Encryption: AES-256 (S3.2)
  Connection Pool: PgBouncer (max 100)
```

**CVE 예시**: CVE-2024-67890 (PostgreSQL 14.0 SQL Injection)

---

### D2: NoSQL & Vector Database

**구성 요소**:
- **D2.1**: Document Store (MongoDB)
- **D2.2**: Vector Database (v2.0 신규)
  - pgvector (PostgreSQL extension)
  - Weaviate, Pinecone, Milvus
  - Use Case: RAG, Semantic Search

- **D2.3**: Key-Value Store (Redis, DynamoDB)
- **D2.4**: Time-Series DB (InfluxDB, TimescaleDB)

**Layer/Zone**: L3, Zone 3

**사용 예시** (pgvector):
```sql
-- Vector Search (D2.2)
CREATE TABLE documents (
    id SERIAL PRIMARY KEY,
    content TEXT,
    embedding vector(1536)  -- OpenAI embedding
);

CREATE INDEX ON documents USING ivfflat (embedding vector_cosine_ops);

-- Query: Find similar documents
SELECT content FROM documents
ORDER BY embedding <-> $1  -- Cosine similarity
LIMIT 5;
```

**MITRE ATT&CK**: T1565 (Data Manipulation)

---

### D3: Cache & Session Store

**구성 요소**:
- **D3.1**: In-Memory Cache (Redis, Memcached)
- **D3.2**: Session Store (Redis, DynamoDB)
- **D3.3**: Pub/Sub Messaging (Redis Pub/Sub)

**Layer/Zone**: L3, Zone 3

**사용 예시**:
```yaml
Redis Cluster (Zone 3):
  Tags: [D3.1, D3.2, D3.3, M7.3]
  Nodes: 6 (3 master, 3 replica)
  Eviction Policy: LRU
  Persistence: RDB + AOF
  Use Cases:
    - Session storage (D3.2)
    - Cache (D3.1): TTL 5 minutes
    - Pub/Sub (D3.3): Real-time notifications
```

---

### D4: Data Processing & Streaming

**구성 요소**:
- **D4.1**: Batch Processing (Spark, Hadoop)
- **D4.2**: Message Queue (Kafka, RabbitMQ)
- **D4.3**: Stream Processing (v2.0 신규)
  - Kafka Streams, Apache Flink
  - Real-time analytics

**Layer/Zone**: L2-L3, Zone 2-3

**사용 예시**:
```yaml
Kafka Cluster (Zone 2-3):
  Tags: [D4.2, D4.3, M7.3]
  Brokers: 3
  Topics:
    - user-events (Partitions: 10, Retention: 7 days)
    - payment-events (Partitions: 5, Retention: 30 days)
  Stream Processing:
    - Real-time fraud detection (D4.3)
    - User behavior analytics
```

---

### D5: Backup & Disaster Recovery

**구성 요소**:
- **D5.1**: Database Backup (pg_dump, mysqldump)
- **D5.2**: Point-in-Time Recovery (PITR)
- **D5.3**: Disaster Recovery (DR)
  - RTO (Recovery Time Objective): <1h
  - RPO (Recovery Point Objective): <15m

**Layer/Zone**: L3-L4, Zone 3-4

**사용 예시**:
```yaml
Backup Strategy:
  Database: PostgreSQL (Zone 3)
  Tags: [D5.1, D5.2, D5.3, S8.1]

  Backup Schedule:
    - Full Backup: Daily 2:00 AM UTC
    - Incremental: Every 6 hours
    - WAL Archiving: Continuous (PITR)

  Storage:
    - Primary: S3 (encrypted, S3.2)
    - DR Site: Cross-region replication
    - Retention: 30 days

  Recovery:
    - RTO: 30 minutes
    - RPO: 5 minutes (WAL archiving)
```

---

## 3. Layer/Zone 연관성

| Layer | Data Tags | 구성 요소 |
|-------|-----------|----------|
| L2 | D4.2 | Kafka, RabbitMQ |
| L3 | D1.1, D2.2, D3.1 | PostgreSQL, pgvector, Redis |
| L4 | D5.1, D5.3 | Backup, DR |

### Zone별 Data 보안

```
Zone 3 (Data):
  - Trust: 80%
  - Controls: Encryption at Rest (S3.2), Network ACL
  - Access: Only from Zone 2 (Application)

Zone 4 (Management):
  - Trust: 90%
  - Controls: Backup (D5.1), Audit (S8.1)
  - Access: VPN only (N5.2)
```

---

## 4. CVE 매핑

| CVE ID | Database | Tech Stack Tag | Severity |
|--------|----------|---------------|----------|
| CVE-2024-67890 | PostgreSQL 14.0 | T2.1 | Critical |
| CVE-2024-11111 | MongoDB <6.0.0 | T2.2 | High |
| CVE-2024-22222 | Redis <7.0.0 | T2.3 | Medium |

---

## 5. MITRE ATT&CK 매핑

| Technique | Data Tag | 탐지/차단 |
|-----------|----------|----------|
| T1565 (Data Manipulation) | D1.2, S8.1 | ACID, Audit Logging |
| T1486 (Data Encrypted for Impact) | D5.2, S3.2 | PITR, Backup |
| T1530 (Data from Cloud Storage) | D5.1, S3.2 | Encryption, Access Control |

---

## 6. 다음 단계

- **Domain A (Application)**: D1.1과 연동 (DB 접근)
- **Domain T (Tech Stack)**: D1.1, D2.2와 연동 (DB 버전)
- **Domain M (Monitoring)**: D1.1과 연동 (DB metrics)

---

**문서 종료**
