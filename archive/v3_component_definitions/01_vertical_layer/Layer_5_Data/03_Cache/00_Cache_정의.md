# Cache (캐시)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Cache |
| **한글명** | 캐시 |
| **Layer** | Layer 5 (Data Services) |
| **분류** | In-Memory Data Store |
| **Function Tag (Primary)** | D3.1 (Application Cache) |
| **Function Tag (Secondary)** | D3.2 (Distributed Cache) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

캐시는 **자주 접근하는 데이터를 메모리에 저장하여 빠른 접근을 제공하는 시스템**입니다.

---

## 🏗️ 주요 캐시 시스템

### 1. Redis

**특징**: 인메모리, 다양한 데이터 구조, 영속성 옵션

**사용 예시**:
```python
import redis

r = redis.Redis(host='localhost', port=6379, decode_responses=True)

# String
r.set('user:1:name', 'Alice', ex=3600)  # 1시간 TTL

# Hash
r.hset('user:1', mapping={'name': 'Alice', 'age': 30})

# List (Queue)
r.lpush('jobs', 'job1', 'job2')
job = r.rpop('jobs')

# Sorted Set (Leaderboard)
r.zadd('scores', {'player1': 100, 'player2': 200})
top = r.zrevrange('scores', 0, 9, withscores=True)  # Top 10
```

**가격**:
```yaml
AWS ElastiCache (Redis):
  cache.t3.micro: $0.017/시간 ($12/월)
  cache.r5.large: $0.156/시간 ($114/월)
```

---

### 2. Memcached

**특징**: 간단한 Key-Value, 멀티스레드

**사용 예시**:
```python
import memcache

mc = memcache.Client(['127.0.0.1:11211'])
mc.set('key', 'value', time=3600)
value = mc.get('key')
```

---

## 📊 캐싱 전략

### 1. Cache Aside (Lazy Loading)

```python
def get_user(user_id):
    # 1. 캐시 확인
    user = cache.get(f'user:{user_id}')
    if user:
        return user

    # 2. DB 조회
    user = db.query(f'SELECT * FROM users WHERE id = {user_id}')

    # 3. 캐시 저장
    cache.set(f'user:{user_id}', user, ttl=3600)
    return user
```

**장점**: 필요한 데이터만 캐싱
**단점**: Cache Miss 시 지연

---

### 2. Write Through

```python
def update_user(user_id, data):
    # 1. DB 업데이트
    db.update('users', user_id, data)

    # 2. 캐시 업데이트
    cache.set(f'user:{user_id}', data, ttl=3600)
```

**장점**: 캐시와 DB 일관성
**단점**: 쓰기 지연

---

### 3. Write Behind (Write Back)

```python
def update_user(user_id, data):
    # 1. 캐시에만 쓰기
    cache.set(f'user:{user_id}', data)

    # 2. 큐에 추가 (비동기 DB 쓰기)
    queue.enqueue('db_write', user_id, data)
```

**장점**: 빠른 쓰기
**단점**: 데이터 유실 위험

---

## ⚡ 실무 고려사항

### TTL 설정

```yaml
정적 콘텐츠: 1시간 - 1일
사용자 세션: 30분 - 1시간
API 응답: 1분 - 10분
자주 변경되는 데이터: 10초 - 1분
```

### 캐시 무효화

```python
# 명시적 삭제
cache.delete(f'user:{user_id}')

# 패턴 삭제 (Redis)
for key in r.scan_iter('user:*'):
    r.delete(key)
```

---

## 🔒 Zone별 배치

| Zone | 배치 | 용도 |
|------|------|------|
| **Zone 2** | Common | Application Cache |
| **Zone 3** | Very Common | Distributed Cache (Redis Cluster) |

---

## 🔗 관련 문서

- [Layer 5 정의](../00_Layer_5_정의.md)
- [Relational Database](../01_Relational_Database/00_Relational_Database_정의.md)
- [NoSQL Database](../02_NoSQL_Database/00_NoSQL_Database_정의.md)

---

**문서 끝**
