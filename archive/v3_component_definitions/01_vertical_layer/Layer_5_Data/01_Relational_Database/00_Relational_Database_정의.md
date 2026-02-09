# Relational Database (관계형 데이터베이스)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Relational Database |
| **한글명** | 관계형 데이터베이스 |
| **Layer** | Layer 5 (Data Services) |
| **분류** | RDBMS |
| **Function Tag (Primary)** | D1.1 (PostgreSQL) |
| **Function Tag (Secondary)** | D1.2 (MySQL), D1.3 (SQL Server) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

관계형 데이터베이스는 **테이블 기반으로 구조화된 데이터를 저장하고 SQL로 조회하는 데이터베이스**입니다.

### 핵심 특징

- **ACID 트랜잭션**: 원자성, 일관성, 격리성, 지속성
- **스키마**: 명확한 데이터 구조 정의
- **조인**: 테이블 간 관계 연결
- **정규화**: 데이터 중복 최소화

---

## 🏗️ 주요 RDBMS

### 1. PostgreSQL

**특징**:
- 오픈소스
- 고급 기능 (JSON, 전문 검색, GIS)
- 확장성

**가격**: 무료

**연결 예시**:
```python
import psycopg2

conn = psycopg2.connect(
    host="localhost",
    database="mydb",
    user="postgres",
    password="password"
)

cur = conn.cursor()
cur.execute("SELECT * FROM users WHERE age > 18")
rows = cur.fetchall()
```

---

### 2. MySQL

**특징**:
- 가장 널리 사용
- 빠른 성능
- InnoDB 스토리지 엔진

**가격**: 무료 (Community Edition)

**설정**:
```ini
[mysqld]
innodb_buffer_pool_size = 1G
max_connections = 150
query_cache_size = 64M
```

---

### 3. AWS RDS (관리형)

**지원 엔진**: PostgreSQL, MySQL, MariaDB, Oracle, SQL Server

**장점**:
- 자동 백업
- 자동 패치
- Read Replica

**가격**:
```yaml
db.t3.medium (2 vCPU, 4GB):
  - PostgreSQL: $0.068/시간 ($50/월)
  - MySQL: $0.068/시간

db.r5.xlarge (4 vCPU, 32GB):
  - PostgreSQL: $0.336/시간 ($245/월)
```

---

## 📊 성능 최적화

### 1. 인덱싱

```sql
-- B-Tree 인덱스 (기본)
CREATE INDEX idx_users_email ON users(email);

-- 복합 인덱스
CREATE INDEX idx_orders_user_date ON orders(user_id, created_at);

-- 부분 인덱스 (PostgreSQL)
CREATE INDEX idx_active_users ON users(email) WHERE active = true;

-- 인덱스 사용 확인
EXPLAIN SELECT * FROM users WHERE email = 'test@example.com';
```

---

### 2. 쿼리 최적화

```sql
-- ❌ 나쁜 예: N+1 문제
SELECT * FROM orders;
-- 각 order마다 별도 쿼리
SELECT * FROM users WHERE id = ?;

-- ✅ 좋은 예: JOIN 사용
SELECT o.*, u.name, u.email
FROM orders o
JOIN users u ON o.user_id = u.id;

-- ❌ 나쁜 예: SELECT *
SELECT * FROM users;

-- ✅ 좋은 예: 필요한 컬럼만
SELECT id, name, email FROM users;
```

---

## 🔒 고가용성

### Replication

```yaml
Master-Slave:
  Master (쓰기):
    - 모든 쓰기 작업

  Slaves (읽기):
    - 읽기 전용 복제본
    - 부하 분산

설정 (MySQL):
  [mysqld]
  server-id = 1
  log-bin = mysql-bin
  binlog-format = ROW
```

---

## 🔒 Zone별 배치

| Zone | 배치 | 용도 |
|------|------|------|
| **Zone 3** | Very Common | Primary DB, Read Replicas |

---

## 🔗 관련 문서

- [Layer 5 정의](../00_Layer_5_정의.md)
- [NoSQL Database](../02_NoSQL_Database/00_NoSQL_Database_정의.md)
- [Cache](../03_Cache/00_Cache_정의.md)

---

**문서 끝**
