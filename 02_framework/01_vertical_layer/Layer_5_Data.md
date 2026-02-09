# Layer 5: Data Services (데이터 서비스)

## 📋 문서 정보

**Layer**: 5 - Data Services
**영문명**: Data Services
**한글명**: 데이터 서비스
**위치**: 중단 계층
**목적**: 데이터 저장, 처리, 분석
**작성일**: 2025-01-20

---

## 🎯 Layer 정의

### 개요

**Layer 5 (Data Services)**는 **데이터 저장 및 처리**를 담당하는 계층입니다.

```yaml
핵심 역할:
  - 관계형/비관계형 데이터베이스
  - 캐싱
  - 벡터 검색 (AI/ML 지원)
  - Object Storage
  - 백업 및 복구
```

---

## 📦 Data Services 구성요소

### 1. Relational Database (관계형 DB)

**대표 DBMS**:
```yaml
PostgreSQL:
  - 오픈소스
  - ACID 완전 준수
  - pgvector (벡터 검색 확장)

MySQL/MariaDB:
  - 오픈소스
  - 높은 성능

Oracle Database:
  - 엔터프라이즈 (유료)
  - RAC (고가용성)

SQL Server:
  - Microsoft
  - Windows 최적화
```

**Function Tags**:
- Primary: `D1.3` (Relational Storage)
- Tech Stack: `T2.1` (SQL Database)

**v2.0 업데이트**:
- **pgvector**: PostgreSQL에서 벡터 검색 지원 → AI/ML 워크로드 통합

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

---

### 3. Cache (캐시)

**대표 캐시**:
```yaml
In-Memory Cache:
  - Redis (가장 인기)
  - Memcached
  - AWS ElastiCache

Application-Level Cache:
  - Ehcache (Java)
  - Caffeine (Java)
```

**Function Tags**:
- Primary: `D2.1` (In-Memory Caching)
- Secondary: `P1.1` (Performance Optimization)

---

### 4. Vector Database (벡터 DB) - v2.0 신규

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

**Function Tags**:
- Primary: `D5.2` (Vector Search)
- Secondary: `A7.2` (RAG - Retrieval-Augmented Generation)

**Zone 배치**: Zone 3 (Data Zone)

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
```

**Function Tags**:
- Primary: `D4.1` (Object Storage)

---

### 6. Data Warehouse

**대표 서비스**:
```yaml
클라우드:
  - AWS Redshift
  - Google BigQuery
  - Snowflake
  - Azure Synapse Analytics
```

**Function Tags**:
- Primary: `D6.1` (Data Warehouse)

---

## 🔒 Security Zone 배치

### Zone 3 (Data Zone) - 일반적 배치

```yaml
구성요소:
  - PostgreSQL, MySQL (운영 DB)
  - Redis (세션 캐시)
  - S3 (백업, 로그)

보안:
  - Zone 2 (Application)에서만 접근
  - Public IP 비할당
  - Encryption at Rest 필수
  - TLS 암호화 통신
```

---

## 📊 실전 예시

### 예시: AI 기반 추천 시스템

```yaml
Layer 5 (Data):
  PostgreSQL + pgvector:
    - 사용자, 주문 (관계형)
    - 상품 임베딩 벡터 (벡터 검색)

  Redis:
    - 세션 캐시
    - 추천 결과 캐싱

  S3:
    - 상품 이미지
    - 백업 데이터

Layer 0 (External):
  - Pinecone (대체 벡터 DB)
```

---

## ✅ 체크리스트

- [ ] DB 백업 전략 수립 (RPO, RTO)
- [ ] Encryption at Rest 활성화
- [ ] 벡터 DB 인덱스 최적화 (HNSW, IVF)
- [ ] Redis 캐시 히트율 모니터링

---

## 🔗 관련 문서

- [Layer 6: Runtime](Layer_6_Runtime.md)
- [Layer 7: Application & AI](Layer_7_Application_AI.md)

---

**문서 끝**
