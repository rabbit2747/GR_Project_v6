# Zone 3: Data Zone (데이터 존)

## 📋 Zone 정보

| 속성 | 값 |
|------|-----|
| **Zone명** | Zone 3 - Data Zone |
| **한글명** | 데이터 존 |
| **신뢰 수준** | High |
| **공격 노출도** | Low |
| **버전** | v1.0.0 |

---

## 🎯 정의

Zone 3은 **민감한 데이터를 저장하고 관리하는 최고 보안 영역**입니다.

**핵심 역할**:
- **데이터 저장**: 관계형/비관계형 데이터 저장
- **데이터 보호**: 암호화, 백업, 복제
- **데이터 무결성**: 트랜잭션, 일관성 보장
- **데이터 가용성**: 고가용성, 재해 복구

**보안 원칙**:
- **최소 권한 접근**: Zone 2에서 인증된 애플리케이션만
- **암호화 필수**: 저장/전송 시 모두 암호화
- **감사 추적**: 모든 데이터 접근 및 변경 기록
- **물리적 격리**: 가능한 경우 네트워크 분리

---

## 🏗️ Zone 3 아키텍처

### 논리적 배치

```
┌─────────────────────────────────────────────┐
│         Zone 2 (Application)                │
│           API Servers                       │
└─────────────────────────────────────────────┘
                     ↓ TLS 암호화 쿼리
┌─────────────────────────────────────────────┐
│           Zone 3 (Data)                     │
│                                             │
│  ┌────────────────────────────────────┐    │
│  │   Database Cluster                 │    │
│  │   (Master + 2 Replicas)            │    │
│  │   PostgreSQL / MySQL               │    │
│  └────────────────────────────────────┘    │
│              ↕️ Replication                │
│  ┌────────────────────────────────────┐    │
│  │   NoSQL Database                   │    │
│  │   MongoDB / Cassandra              │    │
│  └────────────────────────────────────┘    │
│                                             │
│  ┌────────────────────────────────────┐    │
│  │   Object Storage                   │    │
│  │   S3 / MinIO                       │    │
│  └────────────────────────────────────┘    │
│              ↕️ 백업                       │
│  ┌────────────────────────────────────┐    │
│  │   Backup Server                    │    │
│  │   (격리된 네트워크)                   │    │
│  └────────────────────────────────────┘    │
└─────────────────────────────────────────────┘
                     ↑ 로그/메트릭
┌─────────────────────────────────────────────┐
│          Zone 0 (Management)                │
│        Monitoring, Backup Mgmt              │
└─────────────────────────────────────────────┘
```

---

## 📊 배치 구성요소

### Very Common (필수 배치)

| 구성요소 | Layer | 목적 | 주요 제품 |
|---------|-------|------|----------|
| **Relational Database** | Layer 5 | 구조화된 데이터 저장 | PostgreSQL, MySQL, Oracle |
| **NoSQL Database** | Layer 5 | 비구조화/반구조화 데이터 | MongoDB, Cassandra, DynamoDB |
| **Object Storage** | Layer 5 | 파일 저장 | AWS S3, MinIO, Azure Blob |

### Common (자주 배치)

| 구성요소 | Layer | 목적 | 주요 제품 |
|---------|-------|------|----------|
| **Cache** | Layer 5 | 데이터 캐싱 | Redis, Memcached |
| **Data Warehouse** | Layer 5 | 분석용 데이터 저장 | Snowflake, Redshift, BigQuery |
| **Backup System** | Layer 5 | 백업 및 복구 | Veeam, AWS Backup, Commvault |

### Rare (특수 배치)

| 구성요소 | Layer | 목적 | 사용 사례 |
|---------|-------|------|----------|
| **Time-Series DB** | Layer 5 | 시계열 데이터 | InfluxDB, TimescaleDB |
| **Graph Database** | Layer 5 | 그래프 데이터 | Neo4j, ArangoDB |
| **Search Engine** | Layer 5 | 전문 검색 | Elasticsearch, Solr |

---

## 🔐 보안 정책

### 네트워크 정책

```yaml
인바운드 규칙:
  허용:
    - Zone 2 → Zone 3: TLS 암호화 Database 연결만
    - Zone 0 → Zone 3: 백업, 모니터링 전용

  차단:
    - Zone 1, 4 → Zone 3: 직접 접근 절대 금지
    - 인터넷 → Zone 3: 모든 프로토콜 차단

아웃바운드 규칙:
  허용:
    - Zone 3 → Zone 2: 쿼리 응답만
    - Zone 3 → Zone 0: 로그/메트릭 전송
    - Zone 3 → 백업 스토리지: 백업 데이터 전송

  제한:
    - Zone 3 → 인터넷: 절대 차단 (업데이트는 Zone 0 경유)
```

### 인증 정책

```yaml
Database 계정 관리:
  - 애플리케이션별 전용 계정
  - 최소 권한: 읽기/쓰기/삭제 분리
  - 특권 계정: DBA만 접근, 2FA 필수

연결 암호화:
  - TLS 1.3 필수
  - 클라이언트 인증서: 프로덕션 환경
  - Connection String: Vault에 암호화 저장

패스워드 정책:
  - 길이: 최소 20자
  - 복잡도: 대소문자, 숫자, 특수문자
  - 주기: 90일마다 변경
  - 재사용: 최근 5개 금지
```

### 로깅 정책

```yaml
로그 수집 범위:
  - 모든 쿼리 (SELECT, INSERT, UPDATE, DELETE)
  - DDL 변경 (CREATE, ALTER, DROP)
  - 접근 시도 (성공/실패)
  - 권한 변경
  - 데이터 변경 이력 (Audit Log)

로그 보존 기간:
  - 쿼리 로그: 1년
  - 감사 로그 (Audit): 3-7년 (규제 산업)
  - 변경 이력: 영구 보존 (법적 요구사항)

로그 보호:
  - 변조 방지: WORM (Write Once Read Many) 스토리지
  - 암호화: 저장 시 암호화
  - 접근 제한: 보안팀, 감사팀만
```

### 데이터 취급

```yaml
저장 시 암호화 (Encryption at Rest):
  - 알고리즘: AES-256-GCM
  - 키 관리: Hardware Security Module (HSM)
  - 범위: Database, Object Storage, Backup

전송 시 암호화 (Encryption in Transit):
  - 프로토콜: TLS 1.3
  - 알고리즘: ECDHE-RSA-AES256-GCM-SHA384
  - 인증서: 자체 PKI

애플리케이션 레벨 암호화:
  - PII (개인식별정보): 컬럼 레벨 암호화
  - 카드 정보 (PCI-DSS): Tokenization
  - 의료 정보 (HIPAA): 추가 보호

데이터 마스킹:
  - 프로덕션 → 개발 환경: 민감 데이터 마스킹
  - 로그: PII 자동 마스킹
  - 백업: 암호화 + 격리 저장
```

---

## 🚪 Zone 경계 통제

### Zone 2 → Zone 3 (인바운드)

```yaml
통제 메커니즘: Database Firewall + Connection Pool

접근 검증:
  1. 송신 IP 화이트리스트 확인
  2. 애플리케이션 계정 검증
  3. TLS 인증서 검증
  4. 쿼리 타입 검증 (DDL 차단)

쿼리 제한:
  - 실행 시간: 최대 30초
  - 결과 크기: 최대 10MB
  - 복잡도: JOIN 3단계 이하
  - Connection Pool: 최대 50개

로깅:
  - 모든 쿼리 기록
  - Slow Query (>1초)
  - 실패한 쿼리
```

### Zone 3 → 백업 스토리지 (아웃바운드)

```yaml
통제 메커니즘: 전용 백업 네트워크

백업 정책:
  - 빈도: 일일 Full Backup + 매시간 증분
  - 암호화: AES-256 (백업 전 암호화)
  - 압축: 50-70% 압축률
  - 검증: 백업 완료 후 무결성 검증

복구 정책:
  - RTO (Recovery Time Objective): 4시간
  - RPO (Recovery Point Objective): 1시간
  - 테스트: 분기별 복구 테스트
```

---

## 💡 실전 배치 예시

### 예시 1: Startup (소규모)

```yaml
Zone 3 구성:
  - Database: PostgreSQL (1 Master, 1 Replica)
  - Cache: Redis (1대, ElastiCache)
  - Object Storage: AWS S3 (Standard)
  - Backup: AWS Backup (자동)

데이터:
  - Database: ~100GB
  - Object Storage: ~1TB
  - Daily Backup: ~150GB

비용:
  - RDS PostgreSQL (db.t3.medium): ~$150/월
  - ElastiCache (t3.small): ~$30/월
  - S3: ~$23/월
  - AWS Backup: ~$50/월
  - 총: ~$253/월

특징:
  - 관리형 서비스 (RDS, S3)
  - 자동 백업 및 복제
  - 간단한 운영

보안 수준: ⭐⭐⭐⚪⚪
```

### 예시 2: Mid-size Company (중견기업)

```yaml
Zone 3 구성:
  - Database: PostgreSQL Cluster (1 Master, 2 Replica, Self-hosted)
  - NoSQL: MongoDB ReplicaSet (3 Nodes)
  - Cache: Redis Cluster (3 Master, 3 Replica)
  - Object Storage: MinIO (Self-hosted)
  - Backup: Veeam (전용 백업 서버)

데이터:
  - Database: ~1TB
  - NoSQL: ~500GB
  - Object Storage: ~10TB
  - Daily Backup: ~1.5TB

비용:
  - Database Servers (r5.2xlarge × 3): ~$1,500/월
  - MongoDB Servers (r5.xlarge × 3): ~$750/월
  - Redis Servers (r5.large × 6): ~$900/월
  - MinIO Servers (i3.2xlarge × 4): ~$2,000/월
  - Backup Server (r5.xlarge): ~$250/월
  - 총: ~$5,400/월

특징:
  - 자체 구축 (Full Control)
  - HA (High Availability)
  - 정기 백업 테스트

보안 수준: ⭐⭐⭐⭐⚪
```

### 예시 3: Enterprise (대기업)

```yaml
Zone 3 구성:
  - Database: Oracle RAC (4 Nodes, Active-Active)
  - NoSQL: Cassandra (12 Nodes, Multi-DC)
  - Cache: Redis Enterprise (Multi-AZ, 12 Nodes)
  - Object Storage: NetApp StorageGRID (Petabyte Scale)
  - Data Warehouse: Snowflake (Cloud)
  - Backup: Commvault (Multi-Site)

데이터:
  - Database: ~50TB
  - NoSQL: ~100TB
  - Object Storage: ~500TB
  - Data Warehouse: ~200TB
  - Daily Backup: ~50TB

비용:
  - Oracle RAC: ~$20,000/월 (라이센스 포함)
  - Cassandra Cluster: ~$10,000/월
  - Redis Enterprise: ~$5,000/월
  - StorageGRID: ~$15,000/월
  - Snowflake: ~$10,000/월
  - Commvault: ~$5,000/월
  - 총: ~$65,000/월

특징:
  - 엔터프라이즈급 HA
  - Multi-Region Replication
  - 99.99% 가용성
  - 24/7 DBA 팀

보안 수준: ⭐⭐⭐⭐⭐
```

---

## 🔄 Zone 3 데이터 흐름

### 읽기 작업 (Read)

```
API Server (Zone 2)
    ↓ SELECT Query
Database Replica (Zone 3) ← Read-Only
    ↓ Query Execution
Index Scan → Data Retrieval
    ↑ Result Set
API Server ← 응답 (100ms)
```

### 쓰기 작업 (Write)

```
API Server (Zone 2)
    ↓ INSERT/UPDATE Query
Database Master (Zone 3) ← Write
    ↓ Transaction Start
Write-Ahead Log (WAL) ← 로그 기록
    ↓ Commit
Replica 1, 2 ← 비동기 복제
    ↓ Replication Lag (10-100ms)
API Server ← 응답 (200 OK)
```

### 백업 작업 (Backup)

```
Backup Server (Zone 3)
    ↓ Backup Trigger (01:00 AM)
Database Master ← PITR 백업 시작
    ↓ pg_basebackup
Backup Storage (격리) ← 암호화 전송
    ↓ 완료
Zone 0 (Monitoring) ← 백업 성공 알림
```

---

## 🚨 Zone 3 인시던트 대응

### 시나리오 1: Database 장애

```yaml
탐지:
  - Master Database Down (헬스 체크 실패)
  - Replica Lag 급증
  - 쿼리 응답 없음

대응:
  1. 자동: Replica 승격 (Failover)
  2. 자동: 애플리케이션 연결 재설정
  3. 수동: 장애 원인 분석
  4. 수동: Master 복구 또는 재구축

복구:
  - Replica를 새 Master로 승격
  - 구 Master를 Replica로 재구축
  - 데이터 일관성 검증

평균 대응 시간: 5-15분 (자동 Failover)
```

### 시나리오 2: 데이터 손상 (Data Corruption)

```yaml
탐지:
  - Checksum 오류
  - 쿼리 실패 (데이터 불일치)
  - 애플리케이션 에러

대응:
  1. 긴급: 영향받은 Database 격리
  2. 분석: 손상 범위 파악
  3. 복구: PITR (Point-in-Time Recovery)
  4. 검증: 데이터 무결성 확인

복구 옵션:
  - 최근 백업 복구
  - WAL (Write-Ahead Log) 재생
  - 손상된 테이블만 복구

평균 대응 시간: 1-4시간
```

### 시나리오 3: 랜섬웨어 공격

```yaml
탐지:
  - 비정상적 파일 암호화
  - 대량 데이터 변경
  - 랜섬웨어 메시지

대응:
  1. 즉시: 모든 Database 네트워크 격리
  2. 즉시: 백업 스토리지 격리 (재감염 방지)
  3. 분석: 감염 경로 파악
  4. 복구: 격리된 백업에서 복구

예방:
  - Immutable Backup (변경 불가능)
  - Air-Gapped Backup (물리적 격리)
  - 정기 복구 테스트

평균 대응 시간: 4-24시간
```

---

## 📊 Zone 3 모니터링 메트릭

### 핵심 메트릭 (KPI)

```yaml
성능 메트릭:
  - Query Latency (ms): p50, p95, p99
  - Throughput (queries/sec)
  - Slow Queries (>1s): count
  - Connection Pool Usage (%)

가용성 메트릭:
  - Uptime (%)
  - Replication Lag (ms)
  - Failover Count
  - Backup Success Rate (%)

리소스 메트릭:
  - CPU Usage (%)
  - Memory Usage (%)
  - Disk Usage (%)
  - IOPS (Input/Output Operations per Second)

데이터 메트릭:
  - Database Size (GB)
  - Table Size Top 10
  - Index Hit Rate (%)
  - Transaction Rate (TPS)
```

### Grafana 대시보드 예시

```yaml
Dashboard 1: Database 성능
  - Query Latency (p50, p95, p99)
  - Throughput (qps)
  - Slow Queries (>1s)
  - Connection Pool Usage

Dashboard 2: Replication
  - Master Status (up/down)
  - Replica Lag (ms)
  - Replication Errors
  - Sync State

Dashboard 3: 리소스
  - CPU/Memory Usage
  - Disk I/O
  - IOPS
  - Network Throughput

Dashboard 4: 백업
  - Backup Status (success/failed)
  - Backup Size (GB)
  - Backup Duration (min)
  - Last Successful Backup
```

---

## 🔧 Zone 3 최적화 기법

### Database 최적화

```yaml
쿼리 최적화:
  - 인덱스 전략: B-Tree, Hash, GiST
  - Explain Plan 분석
  - Materialized View 활용

파티셔닝:
  - Range Partitioning: 날짜 기반
  - Hash Partitioning: ID 기반
  - List Partitioning: 카테고리 기반

Connection Pool:
  - Min: 10 connections
  - Max: 100 connections
  - Idle Timeout: 10분
```

### Replication 최적화

```yaml
비동기 복제:
  - 성능 우선
  - Replication Lag 허용 (10-100ms)
  - 읽기 부하 분산

동기 복제:
  - 데이터 일관성 우선
  - Quorum (과반수) 방식
  - 성능 희생

PITR (Point-in-Time Recovery):
  - WAL Archiving 활성화
  - 15분 단위 복구 가능
  - 7일 보존
```

### 백업 최적화

```yaml
백업 전략:
  - Full Backup: 주 1회 (일요일)
  - Incremental Backup: 일 1회
  - WAL Archiving: 실시간

백업 압축:
  - gzip: 50-60% 압축률
  - zstd: 60-70% 압축률 (더 빠름)

백업 검증:
  - 자동: Checksum 검증
  - 수동: 분기별 복구 테스트
  - 메트릭: 복구 소요 시간 측정
```

---

## 🔗 관련 문서

- [Security Zone 개요](../00_Security_Zone_개요.md)
- [Zone 2: Application Zone](../Zone_2_Application/00_Zone_2_정의.md)
- [Zone 4: Endpoint Zone](../Zone_4_Endpoint/00_Zone_4_정의.md)
- [Relational Database 구성요소](../../01_차원1_Deployment_Layer/Layer_5_Data/01_Relational_Database/00_Relational_Database_정의.md)
- [NoSQL Database 구성요소](../../01_차원1_Deployment_Layer/Layer_5_Data/02_NoSQL_Database/00_NoSQL_Database_정의.md)
- [Object Storage 구성요소](../../01_차원1_Deployment_Layer/Layer_5_Data/04_Object_Storage/00_Object_Storage_정의.md)

---

**문서 끝**
