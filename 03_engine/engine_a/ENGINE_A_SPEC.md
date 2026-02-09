# Engine A: Orchestrator 사양 v5.0

> **목적**: GR 3-DB 하이브리드 시스템에 대한 단일 접근점. 쿼리를 최적의 데이터베이스로 라우팅하고, 교차 DB 작업을 오케스트레이션하며, 통합된 결과를 반환한다.

---

## 1. 개요

Engine A는 GR Ontology의 **"사서(Librarian)"** 역할을 한다. 어떤 데이터가 어디에 존재하는지 파악하고, 모든 쿼리를 가장 효율적인 데이터베이스로 라우팅하며, 어떤 데이터베이스가 관여했는지와 무관하게 통합된 응답을 반환한다.

```
Client Request → [Engine A: Query Router] → PostgreSQL / Neo4j / Pinecone
                                                     ↓
                           Unified Response ← [Engine A: Result Merger]
```

### 핵심 원칙

1. **단일 진입점**: GR 데이터에 대한 모든 접근은 Engine A를 통해 이루어진다. 직접적인 DB 접근은 허용하지 않는다.
2. **비용 인식 라우팅**: 쿼리에 정확하게 응답할 수 있는 가장 저렴한 DB를 선택한다.
3. **SSOT 적용**: PostgreSQL이 항상 원본 데이터의 출처이다. 충돌 발생 시 PostgreSQL 기준으로 해결한다.
4. **투명한 Multi-DB**: 클라이언트는 어떤 DB가 쿼리를 처리했는지 알 필요가 없다.

---

## 2. 3-DB 아키텍처

### 2.1 데이터베이스 역할

| 데이터베이스 | 역할 | 저장 데이터 | 최적화 대상 |
|----------|------|-------------|---------------|
| **PostgreSQL** | 마스터 / SSOT | 모든 atom 데이터 (전체 스키마) | 구조화 쿼리, ACID 트랜잭션, 정확한 조회 |
| **Neo4j** | 그래프 엔진 | atom 노드 + 모든 관계 | 관계 탐색, 경로 탐색, 영향 분석 |
| **Pinecone** | 벡터 저장소 | atom 임베딩 + 메타데이터 | 의미적 유사도, RAG, 자연어 쿼리 |

### 2.2 데이터 흐름

```
Engine B (Atomizer) → PostgreSQL (master write)
                          ↓ (sync)
                    ┌─────┴─────┐
                    ↓           ↓
                  Neo4j      Pinecone
              (relations)   (embeddings)
```

**동기화 규칙**:
- PostgreSQL → Neo4j: atom 생성/업데이트 시 노드 + 관계 동기화 (준실시간)
- PostgreSQL → Pinecone: atom 생성/업데이트 시 임베딩 생성 및 벡터 upsert (비동기, 5분 이내)
- 방향은 항상 **단방향**: PostgreSQL → 나머지. 역방향은 절대 불가.
- 충돌 발생 시: PostgreSQL 버전이 우선한다. 전체 재동기화를 실행하여 오래된 데이터를 덮어쓴다.

### 2.3 데이터 분배

| 데이터 요소 | PostgreSQL | Neo4j | Pinecone |
|-------------|------------|-------|----------|
| atom 식별자 (id, name) | ✅ Primary | ✅ 노드 속성 | ✅ 메타데이터 |
| 분류 (type, tags) | ✅ Primary | ✅ 노드 속성 | ✅ 메타데이터 필터 |
| 좌표 (layer, zone, function) | ✅ Primary | ✅ 노드 속성 | ✅ 메타데이터 필터 |
| 정의 (what, why, how) | ✅ Primary | ❌ | ✅ 임베딩 소스 |
| 관계 | ✅ Primary | ✅ Edge (최적화됨) | ❌ |
| 보안 프로파일 | ✅ Primary | ✅ Edge 속성 | ❌ |
| 메타데이터 | ✅ Primary | ⚠️ 부분 집합 | ⚠️ 부분 집합 |
| 임베딩 벡터 | ❌ | ❌ | ✅ Primary |

---

## 3. Query Router

### 3.1 쿼리 유형 및 라우팅

| 쿼리 유형 | Primary DB | Fallback | 비용 | 지연 시간 |
|-----------|------------|----------|------|---------|
| **정확한 조회** (ID 기반) | PostgreSQL | — | $0 | <50ms |
| **구조화 필터** (type, tags, layer, zone 기반) | PostgreSQL | — | $0 | <100ms |
| **관계 탐색** (공격 경로, 의존성) | Neo4j | PostgreSQL (느림) | 낮음 | <200ms |
| **경로 탐색** (최단 경로, 영향 분석) | Neo4j | — | 낮음 | <500ms |
| **의미 검색** (자연어 쿼리) | Pinecone | — | 중간 | <300ms |
| **RAG 쿼리** (AI 지원 응답) | Pinecone → LLM | — | 높음 | <2s |
| **좌표 쿼리** (L5, Z3에 해당하는 모든 atom) | PostgreSQL | — | $0 | <100ms |
| **집계 통계** (건수, 커버리지) | PostgreSQL | — | $0 | <200ms |

### 3.2 라우팅 알고리즘

```
1. 쿼리 의도 파싱
2. 쿼리 유형 판별 (정확, 필터, 그래프, 의미, 하이브리드)
3. PostgreSQL 단독으로 응답 가능한지 확인 (가장 저렴)
   → YES: PostgreSQL로 라우팅
   → NO: 계속 진행
4. 관계 탐색이 필요한지 확인
   → YES: Neo4j로 라우팅
5. 의미적 이해가 필요한지 확인
   → YES: Pinecone으로 라우팅
6. 쿼리가 여러 유형에 걸치는 경우:
   → 각 DB에 대한 하위 쿼리를 병렬로 실행
   → Engine A에서 결과 병합
```

### 3.3 비용 인식 라우팅 우선순위

```
Priority 1: PostgreSQL (무료, 구조화 데이터에 가장 빠름)
Priority 2: Neo4j (저비용, 그래프 연산에 필수)
Priority 3: Pinecone (쿼리당 비용 발생, 의미 검색 필요 시에만 사용)
Priority 4: LLM (최고 비용, AI 추론이 필요한 경우에만 사용)
```

**80/20 원칙**: 운영 쿼리의 약 80%는 PostgreSQL 단독으로 응답할 수 있어야 한다 (구조화 조회, 좌표 쿼리, 집계 통계). 약 20%만 Neo4j 또는 Pinecone이 필요해야 한다.

---

## 4. 핵심 작업

### 4.1 Atom CRUD

**생성(Create)**:
```
Client → Engine A → 스키마 기준 유효성 검증 → PostgreSQL에 쓰기
                                                     ↓
                                          Neo4j + Pinecone에 비동기 동기화
                                                     ↓
                                          atom ID와 함께 성공 반환
```

**읽기(Read)**:
```
Client → Engine A → 최적 DB로 라우팅 → atom 데이터 반환
```

**수정(Update)**:
```
Client → Engine A → 변경 사항 유효성 검증 → PostgreSQL 업데이트
                                             ↓
                                  Neo4j + Pinecone에 연쇄 동기화
                                             ↓
                                  수정된 atom 반환
```

**삭제(Delete)** (소프트 삭제만 허용):
```
Client → Engine A → PostgreSQL에서 삭제 표시 → Neo4j + Pinecone에 연쇄 적용
```

### 4.2 좌표 쿼리

**"좌표 (L5, Z3)에 무엇이 존재하는가?"**
```sql
-- Routes to PostgreSQL
SELECT * FROM atoms
WHERE layer = 'L5' AND zone = 'Z3' AND is_infrastructure = true;
```

**"(L5, Z3)에 적용되는 보안 정책은?"**
```
-- Step 1: PostgreSQL - 해당 좌표의 모든 atom 조회
-- Step 2: Neo4j - 'applies_to' 및 'effective_against' 관계 탐색
-- Step 3: 병합 후 정책 집합 반환
```

### 4.3 그래프 작업

**공격 경로 분석**:
```cypher
-- Routes to Neo4j
MATCH path = (source:Atom {zone: 'Z0A'})-[:enables|causes*1..5]->(target:Atom {zone: 'Z3'})
RETURN path ORDER BY length(path)
```

**영향 분석** (구성 요소가 침해된 경우):
```cypher
-- Routes to Neo4j
MATCH (compromised:Atom {id: $atom_id})-[:enables|causes*1..3]->(affected)
RETURN affected, length(path) as distance
```

**의존성 체인**:
```cypher
-- Routes to Neo4j
MATCH (atom:Atom {id: $atom_id})-[:requires*1..5]->(dependency)
RETURN dependency ORDER BY length(path)
```

### 4.4 의미 작업

**"SQL Injection과 유사한 atom 찾기"**:
```
-- Routes to Pinecone
1. 쿼리 텍스트에 대한 임베딩 생성
2. Pinecone에서 상위 K개의 최근접 이웃 검색
3. PostgreSQL에서 전체 데이터로 결과 보강
4. 순위가 매겨진 결과 반환
```

**RAG 쿼리** — "Zone 3에서 PostgreSQL 인스턴스를 어떻게 보호해야 하는가?":
```
-- Routes to Pinecone → LLM
1. 질문에 대한 임베딩 생성
2. Pinecone에서 관련성 높은 상위 10개 atom 검색
3. PostgreSQL에서 전체 atom 데이터 조회
4. atom 컨텍스트를 포함한 LLM 프롬프트 구성
5. atom 인용이 포함된 AI 생성 응답 반환
```

---

## 5. 동기화 및 일관성

### 5.1 동기화 전략

| 소스 | 대상 | 방식 | 지연 시간 | 보장 수준 |
|--------|--------|--------|---------|-----------|
| PostgreSQL | Neo4j | 이벤트 기반 (CDC) | <1초 | 최종 일관성 |
| PostgreSQL | Pinecone | 배치 + 이벤트 기반 | <5분 | 최종 일관성 |

### 5.2 일관성 모델

- **PostgreSQL**: 강한 일관성 (ACID). 항상 권위 있는 출처이다.
- **Neo4j**: 최종 일관성. 대량 쓰기 시 <1초의 지연이 발생할 수 있다.
- **Pinecone**: 최종 일관성. 새로운 atom에 대해 <5분의 지연이 발생할 수 있다.

**충돌 해결**: Neo4j 또는 Pinecone 데이터가 PostgreSQL과 모순되는 경우, PostgreSQL이 우선한다. 해당 atom에 대해 전체 재동기화를 실행한다.

### 5.3 스냅샷 및 타임라인

- **일간 스냅샷**: 전체 PostgreSQL 백업 + Neo4j 내보내기 + Pinecone 인덱스 백업
- **타임라인 지원**: PostgreSQL이 롤백을 위한 버전 이력(atom_version 테이블)을 저장
- **복구**: PostgreSQL 스냅샷에서 복원 후, Neo4j + Pinecone에 전체 재동기화 수행

---

## 6. API 설계

### 6.1 핵심 엔드포인트

```
# Atom CRUD
GET    /api/v1/atoms/{id}                    # ID로 atom 조회
POST   /api/v1/atoms                          # atom 생성
PUT    /api/v1/atoms/{id}                    # atom 수정
DELETE /api/v1/atoms/{id}                    # atom 소프트 삭제

# 쿼리
GET    /api/v1/atoms?type=...&tags=...       # atom 필터링
GET    /api/v1/coordinates/{layer}/{zone}     # 좌표별 atom 조회
GET    /api/v1/search?q=...                   # 의미 검색
POST   /api/v1/query/rag                      # RAG 쿼리

# 그래프
GET    /api/v1/atoms/{id}/relations           # atom 관계 조회
GET    /api/v1/graph/path?from=...&to=...    # atom 간 경로 탐색
GET    /api/v1/graph/impact/{id}              # 영향 분석

# 관리
GET    /api/v1/stats                          # 시스템 통계
POST   /api/v1/sync                           # 전체 재동기화 트리거
GET    /api/v1/health                         # 상태 확인
```

### 6.2 응답 형식

모든 응답은 통합된 형식을 따른다:

```json
{
  "status": "success",
  "data": { ... },
  "meta": {
    "source_db": "postgresql",
    "query_time_ms": 45,
    "total_results": 1
  }
}
```

---

## 7. 성능 목표

| 지표 | 목표치 | 비고 |
|--------|--------|-------|
| 정확한 조회 | <50ms | PostgreSQL 단독 |
| 구조화 필터 | <100ms | PostgreSQL 단독 |
| 그래프 탐색 (깊이 ≤3) | <200ms | Neo4j |
| 그래프 탐색 (깊이 4-5) | <500ms | Neo4j |
| 의미 검색 (상위 10개) | <300ms | Pinecone |
| RAG 쿼리 | <2s | Pinecone + LLM |
| atom 생성 | <500ms | PostgreSQL + 비동기 동기화 |
| 전체 재동기화 | <30분 | 30K atom 기준 |

---

## 8. 확장 전략

### Phase 1 (MVP: <5,000 atom)
- 단일 PostgreSQL 인스턴스 (RDS)
- Neo4j AuraDB Free/Standard
- Pinecone Standard (단일 인덱스)
- 예상 비용: ~$235/월

### Phase 2 (성장: 5,000-30,000 atom)
- PostgreSQL 읽기 복제본 추가
- Neo4j AuraDB Professional
- Pinecone Standard (다중 네임스페이스)
- 예상 비용: ~$500/월

### Phase 3 (확장: 30,000+ atom)
- PostgreSQL 파티셔닝 + 읽기 복제본
- Neo4j Enterprise (또는 AuraDB Enterprise)
- Pinecone Enterprise
- 연결 풀링 + 쿼리 캐싱 레이어
- 예상 비용: ~$1,500/월

---

*Document Version: v5.0 | Last Updated: 2026-02-06*
