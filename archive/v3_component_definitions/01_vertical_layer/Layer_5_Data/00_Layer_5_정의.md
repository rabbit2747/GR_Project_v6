# Layer 5: Data Services (데이터 서비스)

## 📋 Layer 정보

| 속성 | 값 |
|------|-----|
| **Layer 번호** | 5 |
| **한글명** | 데이터 서비스 |
| **영문명** | Data Services |
| **변경 빈도** | Medium (월 단위) |
| **복잡도** | High |
| **다이어그램 위치** | 중단 (Layer 4 위) |

---

## 🎯 정의

Layer 5는 **데이터 저장, 관리, 처리를 담당하는 서비스 계층**입니다.

### 핵심 역할

1. **데이터 저장**
   - 관계형 데이터베이스
   - NoSQL 데이터베이스
   - 객체 스토리지

2. **데이터 접근**
   - 캐싱 (빠른 접근)
   - 인덱싱
   - 쿼리 최적화

3. **데이터 관리**
   - 백업 및 복구
   - 데이터 웨어하우스
   - 분석 및 리포팅

---

## 🏗️ 주요 구성요소

Layer 5는 다음 6개 주요 구성요소로 분류됩니다:

| 번호 | 구성요소 | 설명 | 문서 링크 |
|------|---------|------|-----------|
| 1 | **Relational Database** | 관계형 데이터베이스 (PostgreSQL, MySQL) | [상세 문서](01_Relational_Database/00_Relational_Database_정의.md) |
| 2 | **NoSQL Database** | NoSQL 데이터베이스 (MongoDB, Redis, DynamoDB) | [상세 문서](02_NoSQL_Database/00_NoSQL_Database_정의.md) |
| 3 | **Cache** | 캐싱 시스템 (Redis, Memcached) | [상세 문서](03_Cache/00_Cache_정의.md) |
| 4 | **Object Storage** | 객체 스토리지 (S3, MinIO) | [상세 문서](04_Object_Storage/00_Object_Storage_정의.md) |
| 5 | **Data Warehouse** | 데이터 웨어하우스 (Redshift, BigQuery) | [상세 문서](05_Data_Warehouse/00_Data_Warehouse_정의.md) |
| 6 | **Backup** | 백업 시스템 | [상세 문서](06_Backup/00_Backup_정의.md) |

---

## 🔒 Zone별 배치 개요

| Zone | 배치 빈도 | 주요 구성요소 |
|------|----------|-----------------|
| **Zone 3** | Very Common | Relational DB, NoSQL DB, Cache |
| **Zone 4** | Common | Backup System, Management Tools |

---

## 📊 Layer 특성

### 변경 관리

- **변경 빈도**: 월 단위
- **변경 유형**: 스키마 변경, 인덱스 추가, 용량 확장, 백업 정책 변경
- **영향도**: 높음 (데이터 무결성 영향)

### 의존성

**하위 Layer 의존**:
- Layer 1 (Physical Infrastructure - 스토리지)
- Layer 2 (Network Infrastructure)
- Layer 3 (Computing Infrastructure)

**상위 Layer 지원**:
- Layer 6 (Runtime)
- Layer 7 (Application)

---

## ⚡ 실무 고려사항

### 1. 데이터베이스 선택 기준

```yaml
관계형 DB (PostgreSQL, MySQL):
  용도: 트랜잭션, 복잡한 쿼리, 데이터 무결성
  특징: ACID 보장, 조인, 외래키
  예시: 금융, ERP, 주문 시스템

NoSQL Document (MongoDB):
  용도: 유연한 스키마, 계층 구조 데이터
  특징: JSON 문서, 스키마리스
  예시: CMS, 카탈로그, 프로필

NoSQL Key-Value (Redis, DynamoDB):
  용도: 빠른 읽기/쓰기, 세션 관리
  특징: 낮은 지연시간, 높은 처리량
  예시: 캐시, 세션, 리더보드

NoSQL Wide-Column (Cassandra):
  용도: 시계열 데이터, 대용량 쓰기
  특징: 높은 확장성, 분산 아키텍처
  예시: IoT, 로그, 센서 데이터

NoSQL Graph (Neo4j):
  용도: 관계 중심 데이터
  특징: 그래프 쿼리, 관계 탐색
  예시: 소셜 네트워크, 추천 시스템
```

---

### 2. 데이터 계층 아키텍처

```yaml
Layer 구조:
  Application Layer:
    - 비즈니스 로직
    - API

  Caching Layer (Layer 5):
    - Redis, Memcached
    - CDN (정적 콘텐츠)
    - Application Cache

  Database Layer (Layer 5):
    - Primary DB (읽기/쓰기)
    - Read Replicas (읽기 전용)
    - Sharding (수평 분할)

  Backup Layer (Layer 5):
    - 정기 백업
    - Point-in-Time Recovery
    - 재해 복구
```

---

### 3. 성능 최적화

```yaml
인덱싱:
  - 쿼리 패턴 분석
  - 적절한 인덱스 생성
  - 복합 인덱스 활용

캐싱:
  - Cache Aside 패턴
  - Write Through
  - TTL 설정

쿼리 최적화:
  - N+1 문제 해결
  - Eager Loading
  - 페이징

연결 풀링:
  - Connection Pool 사용
  - 적절한 풀 크기 설정
```

---

### 4. 보안

```yaml
접근 제어:
  - 최소 권한 원칙
  - IAM 역할 기반
  - VPC 네트워크 격리

암호화:
  - At-Rest: 디스크 암호화
  - In-Transit: TLS/SSL
  - Application Level: 필드 암호화

감사:
  - 쿼리 로그
  - 접근 로그
  - 변경 이력
```

---

### 5. 고가용성

```yaml
Replication:
  - Master-Slave
  - Multi-Master
  - Cross-Region

Failover:
  - 자동 장애 조치
  - Health Check
  - 빠른 복구 (RTO/RPO)

Backup:
  - 정기 백업 (일/주)
  - Point-in-Time Recovery
  - Cross-Region 백업
```

---

## 🔗 관련 문서

- [차원 1 개요](../00_차원1_개요.md)
- [Layer 4: Platform Services](../Layer_4_Platform/00_Layer_4_정의.md)
- [Layer 6: Runtime](../Layer_6_Runtime/00_Layer_6_정의.md)

---

**문서 끝**
