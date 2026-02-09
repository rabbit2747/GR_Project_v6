# NoSQL Database (NoSQL 데이터베이스)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | NoSQL Database |
| **한글명** | NoSQL 데이터베이스 |
| **Layer** | Layer 5 (Data Services) |
| **분류** | Non-Relational Database |
| **Function Tag (Primary)** | D2.1 (Document DB) |
| **Function Tag (Secondary)** | D2.2 (Key-Value), D2.3 (Wide-Column), D2.4 (Graph) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

NoSQL은 **비관계형 데이터 모델을 사용하여 유연하고 확장 가능한 데이터 저장을 제공하는 데이터베이스**입니다.

---

## 🏗️ NoSQL 유형

### 1. Document DB (MongoDB)

**특징**: JSON 문서 저장, 유연한 스키마

**사용 예시**:
```javascript
// MongoDB
db.users.insertOne({
  name: "Alice",
  age: 30,
  address: {
    city: "Seoul",
    country: "Korea"
  },
  tags: ["developer", "blogger"]
});

db.users.find({ age: { $gt: 25 } });
```

**용도**: CMS, 카탈로그, 사용자 프로필

---

### 2. Key-Value (Redis, DynamoDB)

**특징**: 빠른 읽기/쓰기, 간단한 구조

**Redis 예시**:
```python
import redis

r = redis.Redis(host='localhost', port=6379)
r.set('session:123', 'user_data')
r.expire('session:123', 3600)  # 1시간 TTL
value = r.get('session:123')
```

**용도**: 캐시, 세션, 실시간 리더보드

---

### 3. Wide-Column (Cassandra)

**특징**: 높은 쓰기 처리량, 시계열 데이터

**CQL 예시**:
```sql
CREATE TABLE sensor_data (
  sensor_id uuid,
  timestamp timestamp,
  temperature double,
  PRIMARY KEY (sensor_id, timestamp)
);

INSERT INTO sensor_data (sensor_id, timestamp, temperature)
VALUES (uuid(), '2024-01-01 10:00:00', 25.5);
```

**용도**: IoT, 로그, 시계열 데이터

---

### 4. Graph (Neo4j)

**특징**: 관계 중심, 그래프 쿼리

**Cypher 예시**:
```cypher
// 노드 생성
CREATE (u:User {name: 'Alice'})
CREATE (p:Post {title: 'Hello'})

// 관계 생성
MATCH (u:User {name: 'Alice'}), (p:Post {title: 'Hello'})
CREATE (u)-[:WROTE]->(p)

// 친구의 친구 찾기
MATCH (me:User {name: 'Alice'})-[:FRIEND]->(friend)-[:FRIEND]->(fof)
RETURN fof.name
```

**용도**: 소셜 네트워크, 추천 시스템

---

## 📊 NoSQL vs SQL

| 항목 | SQL | NoSQL |
|------|-----|-------|
| **스키마** | 고정 | 유연 |
| **확장** | 수직 (Scale-Up) | 수평 (Scale-Out) |
| **트랜잭션** | ACID | BASE (Eventually Consistent) |
| **쿼리** | SQL (복잡한 조인) | 데이터 모델별 (조인 제한적) |
| **용도** | 트랜잭션, 복잡한 쿼리 | 대용량, 고속, 유연성 |

---

## 🔒 Zone별 배치

| Zone | 배치 | 용도 |
|------|------|------|
| **Zone 3** | Very Common | Document DB, Key-Value DB |

---

## 🔗 관련 문서

- [Layer 5 정의](../00_Layer_5_정의.md)
- [Relational Database](../01_Relational_Database/00_Relational_Database_정의.md)
- [Cache](../03_Cache/00_Cache_정의.md)

---

**문서 끝**
