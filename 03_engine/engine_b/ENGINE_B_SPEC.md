# Engine B: Atomizer Pipeline 사양서 v5.1

> **목적**: 원시 보안/IT 데이터를 GR Ontology용 표준화·분류된 atom으로 변환하는 AI 기반 pipeline.

---

## 1. 개요

Engine B는 **지식 수집 시스템**으로, 원시 데이터(문서, CVE, Sigma 규칙, 벤더 사양서, RFC 등)를 입력받아 GR 스키마를 따르는 독립적이고 분류된 atom으로 변환한다.

```
Raw Data → [Engine B: 4-Layer Pipeline] → Classified Atoms → [Engine A: Storage]
```

### 핵심 원칙

1. **결정론적 분류**: 동일한 입력은 항상 동일한 분류 결과를 산출한다
2. **원자성**: 하나의 atom = 하나의 독립된 지식 단위 (개념 혼합 불가)
3. **속도보다 품질**: 잘못된 atom을 생성하는 것보다 불확실한 입력을 거부하는 것이 낫다
4. **Human-in-the-Loop**: 중요한 결정(새로운 prefix, 스키마 변경)은 사람의 승인을 필요로 한다
5. **Data Flywheel**: 모든 수정 사항이 향후 분류 정확도를 향상시킨다

---

## 2. 4-Layer Pipeline 아키텍처

```
┌─────────────────────────────────────────────────────────┐
│ Layer 1: INGESTION                                       │
│ Raw data collection, parsing, deduplication              │
├─────────────────────────────────────────────────────────┤
│ Layer 2: ANALYSIS                                        │
│ Content analysis, entity extraction, classification      │
├─────────────────────────────────────────────────────────┤
│ Layer 3: ATOMIZATION                                     │
│ Atom construction, relation mapping, coordinate assign   │
├─────────────────────────────────────────────────────────┤
│ Layer 4: VALIDATION                                      │
│ Schema validation, quality checks, storage               │
└─────────────────────────────────────────────────────────┘
```

### Layer 1: 수집 (Ingestion)

**입력 소스**:
| 소스 | 형식 | 규모 | 예시 |
|--------|--------|--------|---------|
| Sigma Rules | YAML | ~3,100개 규칙 | 탐지 시그니처 |
| Atomic Red Team | YAML | ~650개 테스트 | 공격 테스트 절차 |
| GTFOBins | Markdown | ~470개 항목 | Linux 바이너리 악용 |
| LOLBAS | YAML/JSON | ~230개 항목 | Windows 바이너리 악용 |
| OWASP | Markdown | ~290개 항목 | 웹 보안 지식 |
| MITRE ATT&CK | JSON/STIX | ~700개 기술 | 공격 프레임워크 |
| RFC | Text | ~25개 사양 | 프로토콜 표준 |
| CVE/NVD | JSON | 지속 갱신 | 취약점 데이터베이스 |
| Vendor Docs | 다양 | 지속 갱신 | 제품 문서 |

**처리 단계**:
1. **형식 감지**: 소스 형식 식별 (YAML, JSON, Markdown, STIX)
2. **파싱**: 원시 형식에서 구조화된 콘텐츠 추출
3. **중복 제거**: 기존 atom ID와 대조하여 중복 생성 방지
4. **소스 검증**: 소스 신뢰성 및 데이터 최신성 확인
5. **대기열 등록**: 파싱된 콘텐츠를 우선순위와 함께 분류 대기열에 배치

**중복 제거 규칙**:
- 정확한 ID 일치 → 건너뜀 (이미 존재)
- 의미적 유사도 >95% → 사람의 검토를 위해 플래그 지정
- 동일한 CVE/CWE/MITRE ID → 기존 atom에 병합하거나 관계 생성

### Layer 2: 분석 (Analysis)

**콘텐츠 분석**:
1. **엔티티 추출**: 핵심 엔티티 식별 (제품, 기술, 취약점, 프로토콜)
2. **도메인 분류**: 콘텐츠가 속하는 GR 도메인 결정
3. **Prefix 결정**: 12단계 분류 규칙 적용 (`GR_CLASSIFICATION_RULES.md` 참조)
4. **유형 할당**: 11가지 유형 분류 결정
5. **추상화 수준**: 콘텐츠가 Instance(1), Technique(2), Concept(3), Principle(4) 중 어디에 해당하는지 평가

**분류 Pipeline**:
```
Content → Entity Extraction → Prefix Determination → Type Assignment
                                                           ↓
                              is_infrastructure Decision ← 4-Question Test
                                        ↓
                    [true] → Coordinate Assignment (Layer, Zone, Function)
                    [false] → Scope Assignment (target layers, zones)
```

**동적 Few-Shot 학습**:
- 각 분류 결정 시 이전에 분류된 유사한 atom 3~5개를 예시로 검색
- 이 예시들을 LLM 분류 프롬프트의 컨텍스트로 활용
- 신뢰도 임계값: ≥85%이면 자동 분류, <85%이면 사람 검토 대기열로 전송

### Layer 3: 원자화 (Atomization)

**Atom 구성**:
1. **ID 생성**: `{PREFIX}-{SUBDOMAIN}-{NAME}-{###}` 형식에 따라 atom ID 생성
2. **스키마 채우기**: `atom_schema.yaml`에 따라 모든 필수 필드 작성
3. **정의 작성**:
   - `what`: atom이 무엇인지 설명하는 1~3단락 (500~800자)
   - `why`: 보안 맥락에서 왜 중요한지
   - `how`: 어떻게 작동하거나 구현되는지
4. **관계 매핑**: 기존 atom과의 관계 식별
   - atom당 최소 1개의 관계 필수
   - 정규 방향만 저장 (역방향 관계 저장하지 않음)
   - `related_to`는 **금지** — 구체적인 관계 유형만 사용
5. **좌표/범위 할당**:
   - 인프라 atom → `gr_coordinates` (Layer, Zone, Function)
   - 지식 atom → `scope` (적용 가능한 layer, zone, component)
6. **태그 할당**: 통제 어휘에서 atom_tags 적용 (최소 2개)
7. **검색 키워드 생성**: 발견 가능성을 위한 검색 키워드 5개 이상 생성
8. **Embedding 텍스트 생성**: vector embedding을 위한 50~200단어 요약 작성

**관계 탐색 알고리즘**:
```
For each new atom:
  1. Find atoms with same prefix → check for is_a, part_of relationships
  2. Find atoms at same coordinates → check for applies_to, effective_against
  3. Find atoms in related domains → check for enables, prevents, requires
  4. Find atoms with overlapping tags → check for alternative_to, conflicts_with
  5. Validate: no circular references in is_a/part_of/requires chains
```

### Layer 4: 검증 (Validation)

**검증 체크리스트** (모든 항목을 통과해야 함):

| # | 검사 항목 | 심각도 |
|---|-------|----------|
| 1 | ID prefix가 디렉터리 매핑과 일치 | CRITICAL |
| 2 | `is_infrastructure`가 prefix 규칙과 일치 | CRITICAL |
| 3 | `type`이 해당 prefix에 유효 | CRITICAL |
| 4 | `atom_tags`에 통제 어휘의 태그 2개 이상 존재 | HIGH |
| 5 | `gr_coordinates`는 INFRA-* atom에만 존재 | CRITICAL |
| 6 | `scope`는 비-INFRA atom에만 존재 | CRITICAL |
| 7 | `normalized_name`이 소문자와 밑줄 형식 | MEDIUM |
| 8 | `definition.what`이 비어있지 않음 | HIGH |
| 9 | 신뢰 소스와 신뢰 수준이 유효 | MEDIUM |
| 10 | 검색 키워드 5개 이상 존재 | MEDIUM |
| 11 | 관계에 `related_to` 없음 | CRITICAL |
| 12 | 역방향 관계가 저장되지 않음 | CRITICAL |
| 13 | 참조된 모든 atom ID가 존재 (또는 frontier로 표시) | HIGH |
| 14 | is_a/part_of/requires에 순환 참조 없음 | CRITICAL |
| 15 | Function 코드가 계층적 형식 사용 (단일 문자 아님) | HIGH |
| 16 | 폐기된 유형 (control, tool) 미사용 | HIGH |
| 17 | atom_schema.yaml에 대한 스키마 검증 통과 | CRITICAL |
| 18 | Embedding 텍스트가 비어있지 않음 | MEDIUM |

**실패 처리**:
- CRITICAL 실패 → atom 거부, 수정 대기열로 전송
- HIGH 실패 → atom에 검토 플래그 지정, 경고와 함께 저장 가능
- MEDIUM 실패 → 메타데이터에 품질 노트와 함께 atom 저장

**품질 지표**:
- 분류 정확도 목표: ≥95%
- 스키마 준수: CRITICAL 검사 항목 100%
- 관계 완전성: atom당 최소 1개 관계
- 태그 준수: 통제 어휘에서 최소 2개 태그

---

## 3. Data Flywheel 전략

Data Flywheel은 Engine B의 지속적 개선 메커니즘이다:

```
Classify Atoms → Human Reviews → Corrections Feed Back
       ↑                                    ↓
  Better Examples ← Improved Few-Shot ← Correction Database
```

### Flywheel 구성 요소

1. **Correction Database**: 모든 사람의 수정 사항(재분류, 유형 변경, 관계 수정)을 저장
2. **동적 Few-Shot 선택**: 새로운 atom 분류 시 가장 유사한 수정 사례를 검색
3. **신뢰도 보정**: 실제 정확도 대비 예측 정확도를 추적하여 신뢰도 임계값 개선
4. **주기적 재처리**: 신뢰도 임계값 이하로 분류된 atom을 일괄 재처리
5. **품질 대시보드**: 분류 정확도, 빈번한 오류, 개선 추이 추적

### Frontier 개념

atom이 아직 존재하지 않는 다른 atom을 참조할 경우, 이는 **frontier 참조**가 된다:
- 해당 참조는 `_frontier` 플래그와 함께 저장
- Frontier atom은 확장 계획에서 추적
- 누락된 atom이 최종적으로 생성되면 frontier 참조가 해소됨
- Frontier 커버리지 지표: `resolved_references / total_references`

---

## 4. Multi-Agent 아키텍처

대량 수집 시 Engine B는 여러 전문 에이전트를 병렬로 운영할 수 있다:

| 에이전트 역할 | 담당 업무 | 병렬 처리 단위 |
|-----------|----------------|-------------|
| Ingestion Agent | 소스 파싱, 중복 제거 | 소스 유형별 |
| Classification Agent | Prefix + 유형 결정 | atom별 |
| Coordinate Agent | Layer/Zone/Function 할당 | INFRA atom별 |
| Relation Agent | 관계 탐색 및 매핑 | atom별 |
| Validation Agent | 스키마 및 품질 검사 | atom별 |

**조정 방식**: 에이전트들은 메시지 큐를 통해 통신한다. 각 atom은 pipeline을 순차적으로 통과하지만(ingestion → classification → coordination/scope → relation → validation), 각 단계에서 여러 atom이 병렬로 처리된다.

---

## 5. 통합 지점

### 입력 통합
- **원시 데이터 디렉터리**: `04_db/rawdata/` — 유형별로 정리된 소스 파일
- **확장 계획**: `expansion_plan.yaml` — 생성 예정인 atom 목록
- **수동 제출**: 운영자의 새 atom 요청

### 출력 통합
- **Atom 저장소**: `04_db/atom_data/{PREFIX}/` — 분류된 atom YAML 파일
- **Engine A**: atom이 Engine A를 통해 3-DB 시스템에 로드됨
- **품질 보고서**: 분류 정확도 및 pipeline 상태 지표

### 피드백 통합
- **사람 검토 대기열**: 사람의 판단을 기다리는 불확실한 분류
- **수정 로그**: flywheel 개선을 위한 모든 사람의 수정 기록
- **Frontier 추적기**: atom 생성을 기다리는 누락 참조

---

*Document Version: v5.1 | Last Updated: 2026-02-06*
