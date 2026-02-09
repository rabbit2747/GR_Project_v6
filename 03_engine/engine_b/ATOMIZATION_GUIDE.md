# GR 원자화 가이드 v5.1

> **목적**: 이 문서는 AI 또는 사람이 GR 온톨로지의 atom YAML 파일을 생성할 때 반드시 따라야 하는 절차, 규칙, 품질 기준을 정의한다. 이 가이드를 읽은 후에는 어떤 보안 개념이든 동일한 품질의 atom으로 변환할 수 있어야 한다.

---

## 1. 핵심 원칙

1. **최대 상세화**: 위키 수준의 깊이. 작성할 수 있는 내용이 있다면 반드시 작성한다. "3개만" 같은 임의의 제한 없음.
2. **결정론적**: 같은 입력 → 항상 같은 분류 결과. 주관적 판단 불허.
3. **자기 완결적**: 하나의 atom만 읽어도 해당 개념을 완전히 이해할 수 있어야 한다.
4. **AI-First**: 1차 소비자는 AI다. 모호하지 않고, 구조적이며, 기계가 파싱 가능하게 작성한다.
5. **원자성**: 하나의 atom = 하나의 독립적 개념. 두 개 이상의 개념이 혼합되면 분리한다.

---

## 2. 사전 준비 — 반드시 읽어야 할 파일

원자화를 시작하기 전에 다음 파일들을 **반드시** 읽고 이해해야 한다:

| 파일 | 경로 | 용도 |
|------|------|------|
| **분류 규칙** | `03_engine/engine_b/GR_CLASSIFICATION_RULES.md` | 12단계 분류 프로세스, 서브도메인 카탈로그 |
| **Atom 스키마** | `03_engine/engine_b/atom_schema.yaml` | YAML 구조, 필드 정의, 유효성 규칙 |
| **태그 어휘** | `03_engine/engine_b/atom_tags.yaml` | 통제된 태그 목록 (자유 형식 금지) |
| **마스터플랜** | `01_masterplan/GR_MASTERPLAN.md` | 프로젝트 철학, 비전 |

---

## 3. 원자화 프로세스 (단계별)

### 3.1단계: 입력 분석

입력으로 주어진 개념(예: "SQL Injection", "LockBit", "Wireshark")에 대해:

```
질문 1: 이것은 근본적으로 무엇인가? → Prefix 결정
질문 2: 이 prefix 내에서 어떤 범주인가? → Subdomain 결정 (Section 6 카탈로그 참조)
질문 3: 간결한 설명적 이름은? → NAME 결정
질문 4: 순번은? → ### 결정 (같은 PREFIX-SUBDOMAIN-NAME 조합 내 001부터)
```

### 3.2단계: ID 생성

**형식**: `{PREFIX}-{SUBDOMAIN}-{NAME}-{###}`

```
예시:
  SQL Injection      → ATK-INJECT-SQL-001
  LockBit 랜섬웨어    → MALWARE-RANSOM-LOCKBIT-001
  Wireshark          → TOOL-NETMON-WIRESHARK-001
  WAF 어플라이언스     → INFRA-SEC-WAF-001
  CWE-89             → VUL-INJECT-CWE89-001
  APT28              → ACTOR-APT-APT28-001
```

**규칙**:
- 모든 구성 요소는 대문자, 하이픈 구분
- SUBDOMAIN은 `GR_CLASSIFICATION_RULES.md` Section 6 카탈로그에 정의된 값만 사용
- NAME은 간결하되 식별 가능하게 (SQL, LOCKBIT, WIRESHARK)
- PRI prefix만 서브도메인 없이 `PRI-{NAME}-{###}` 형식

### 3.3단계: YAML 작성

아래 **8개 섹션**을 순서대로 작성한다.

---

## 4. YAML 섹션별 작성 규칙

### 섹션 1: identity (필수)

```yaml
identity:
  id: "ATK-INJECT-SQL-001"          # 필수. 고유 ID.
  name: "SQL Injection"              # 필수. 사람이 읽는 표시 이름.
  normalized_name: "sql_injection"   # 필수. 소문자+밑줄. ^[a-z][a-z0-9_]*$
  aliases:                           # 선택. 가능한 모든 대체 이름/약어를 나열.
    - "SQLi"
    - "SQL Injection Attack"
    - "SQL 삽입 공격"
    - "SQL 인젝션"
```

**aliases 규칙**: 해당 개념의 알려진 모든 이름, 약어, 한국어명, 변형 표기를 빠짐없이 나열한다. 검색성을 위해 가능한 많이.

### 섹션 2: classification (필수)

```yaml
classification:
  is_infrastructure: false    # INFRA-* = true, 나머지 = false. 예외 없음.
  type: "technique"           # 11개 type 중 하나 (아래 표 참조)
  abstraction_level: 2        # 4=원칙, 3=개념, 2=기법, 1=인스턴스
  atom_tags: [WEB, API, INJ, EXEC, CLOUD, WINDOWS, LINUX, MACOS, CONTAINER]
```

**type 결정표**:

| Prefix | 구체적 항목 → type | 범주/분류 → type |
|--------|-------------------|-----------------|
| INFRA- | component / component_tool / component_control | — |
| ATK- | technique | concept |
| DEF- | control_policy | concept |
| VUL- | vulnerability | concept |
| TOOL- | tool_knowledge | concept |
| COMP- | control_policy | concept |
| TECH- | concept | concept |
| ACTOR- | concept | concept |
| MALWARE- | technique | concept |
| DETECT- | pattern | concept |
| PROTO- | protocol | concept |
| PRI- | principle | concept |

**atom_tags 규칙**:
- `atom_tags.yaml`에 정의된 태그만 사용. 자유 형식 태그 절대 금지.
- 최소 2개, 최대 10개.
- 5-질문 방법으로 태그 배정:
  1. 관련된 공격 단계는? (RECON, INITIAL, EXEC, PERSIST, PRIV, EVADE, CRED, DISC, LATERAL, COLLECT, C2, EXFIL, IMPACT)
  2. 어떤 기술 스택인가? (WEB, API, CLOUD, CONTAINER, MOBILE, IOT, AI, NETWORK, DATABASE, OS, FIRMWARE, BLOCKCHAIN, ICS)
  3. 어떤 플랫폼인가? (WINDOWS, LINUX, MACOS, AWS, AZURE, GCP, K8S, DOCKER, ANDROID, IOS, VMWARE)
  4. 어떤 취약점 유형인가? (INJ, XSS, AUTHN, AUTHZ, CRYPTO, CONFIG, DESER, SSRF, XXE, PATH, RACE, OVERFLOW, CSRF, UPLOAD, INFO_LEAK, DOS)
  5. 어떤 방어/프로토콜인가? (WAF, IDS, IPS, SIEM, EDR, DLP, PAM, MFA, HTTP, DNS, SSH, TLS, ...)
- 해당하는 태그가 있으면 모두 포함한다. "3개만" 같은 임의 제한 없음.

### 섹션 3: gr_coordinates (INFRA 전용)

INFRA- atom에만 작성. 나머지 prefix는 이 섹션을 작성하지 않는다.

```yaml
gr_coordinates:
  layer: "L2"       # L0~L7, Cross 중 하나
  zone: "Z1"        # Z0A, Z0B, Z1~Z5 중 하나
  function: "S1.2"  # {Domain}{Category}.{Sequence} 형식. 단일 문자 금지.
```

**Layer 결정 질문**: "배포 스택에서 어디에 위치하는가?"

| Layer | 기준 |
|-------|------|
| L0 | 통제 밖 외부 서비스 |
| L1 | 물리적 하드웨어 |
| L2 | 네트워크 라우팅/필터링 |
| L3 | 컴퓨팅 리소스 (VM, 클라우드) |
| L4 | 배포/라이프사이클 관리 (CI/CD) |
| L5 | 영구 데이터 저장/처리 |
| L6 | 실행 중인 애플리케이션 호스팅 |
| L7 | 비즈니스 로직 / 사용자 인터페이스 |
| Cross | 여러 계층에 걸침 (모니터링, 보안) |

**Zone 결정 질문**: "어떤 신뢰 경계에 있는가?"

| Zone | 기준 |
|------|------|
| Z0A | 완전 외부, 인증 없음 |
| Z0B | 외부이지만 인증됨 (SaaS, 파트너) |
| Z1 | 외부 트래픽에 직접 노출된 우리 인프라 |
| Z2 | 비즈니스 로직 / 애플리케이션 서비스 |
| Z3 | 영구적/민감한 데이터 저장/처리 |
| Z4 | 관리/운영/모니터링 시스템 |
| Z5 | 사용자 단말 (노트북, 모바일) |

### 섹션 4: scope (지식 atom 전용)

INFRA- 이외 모든 prefix에 작성. INFRA- atom은 이 섹션을 작성하지 않는다.

```yaml
scope:
  target_layers: [L5, L6, L7]
  target_zones: [Z1, Z2, Z3]
  target_components:
    - "INFRA-DATA-POSTGRESQL-001"
    - "INFRA-DATA-MYSQL-001"
    - "INFRA-DATA-MSSQL-001"
    - "INFRA-APP-API-001"
```

**규칙**:
- `target_layers` 또는 `target_zones` 중 최소 하나 필수.
- `target_components`는 선택이지만, 알려진 적용 대상이 있다면 **모두** 나열한다.
- 해당하는 모든 Layer와 Zone을 빠짐없이 포함한다. 대상이 5개면 5개, 8개면 8개 전부.

### 섹션 5: definition (필수)

```yaml
definition:
  what: >     # 필수. 500-800자. 이것이 무엇인지 사실적이고 객관적으로.
  why: >      # 권장. 200-500자. 보안 맥락에서 왜 중요한지.
  how: >      # 권장. 300-600자. 어떻게 작동/구현/사용하는지.
  core_concepts:   # 선택. 이 atom을 이해하기 위한 핵심 하위 개념들.
    - key: "개념 이름"
      value: "100-200자 설명"
```

**핵심 작성 원칙**:

1. **what**: 사실만. "best", "should", "might" 같은 주관적 표현 금지. 첫 문장에서 정의를 명확히. 역사, 기원, 변종, 메커니즘을 포함.
2. **why**: 보안 영향도, 피해 규모, 발생 빈도, 산업 표준에서의 위치를 근거로.
3. **how**: 구체적인 절차, 단계, 기술적 메커니즘. 추상적 설명 금지.
4. **core_concepts**: 해당 개념을 이해하는 데 필요한 모든 하위 개념을 나열한다.
   - **임의로 개수를 제한하지 않는다.** 3개든 15개든 필요한 만큼.
   - 공격 기법이면: 모든 변종, 우회 기법, 방어법을 각각 core_concept으로.
   - 도구면: 주요 기능, 모듈, 사용 시나리오를 각각.
   - 악성코드면: 감염 벡터, 통신 프로토콜, 페이로드 유형, 회피 기법을 각각.

### 섹션 6: relations (필수)

```yaml
relations:
  - type: "is_a"
    target: "ATK-INJECT-OVERVIEW-001"
    description: "Injection 공격의 하위 유형"
```

**사용 가능한 관계 유형** (이 목록 외 사용 금지):

| 범주 | 관계 | 방향 | 설명 |
|------|------|------|------|
| 구조적 | `is_a` | 하위→상위 | 분류 체계 |
| 구조적 | `part_of` | 부분→전체 | 구성 관계 |
| 구조적 | `instance_of` | 인스턴스→클래스 | 인스턴스화 |
| 구조적 | `abstracts` | 추상→구체 | 일반화 |
| 인과적 | `causes` | 원인→결과 | 인과 관계 |
| 인과적 | `enables` | 활성화자→대상 | 가능하게 함 |
| 인과적 | `prevents` | 방지자→대상 | 방지 |
| 조건적 | `requires` | 종속자→의존성 | 전제 조건 |
| 조건적 | `conflicts_with` | 대칭 | 충돌 (한 번만 저장) |
| 조건적 | `alternative_to` | 대칭 | 대안 (한 번만 저장) |
| 시간적 | `precedes` | 이전→이후 | 시간 순서 |
| 시간적 | `supersedes` | 신규→기존 | 대체 |
| 적용성 | `applies_to` | 지식→인프라 | 적용 대상 |
| 적용성 | `effective_against` | 방어→공격/취약점 | 효과적 대상 |
| 구현 | `implements` | 구현→명세 | 실현 |
| 인식론적 | `contradicts` | 대칭 | 모순 (한 번만 저장) |
| 인식론적 | `disputes` | 대칭 | 반박 (한 번만 저장) |
| 인식론적 | `refines` | 정제→원본 | 정교화 |

**관계 작성 규칙**:

1. **`related_to` 절대 금지** — 모호하고 무한 확장 가능.
2. **정방향만 저장** — 역방향은 쿼리 시 계산. (예: `is_a`만 저장, `has_subtype`은 저장하지 않음)
3. **대칭 관계**(`conflicts_with`, `alternative_to`, `contradicts`, `disputes`)는 한 번만 저장.
4. **순환 참조 금지** — `is_a`, `part_of`, `requires` 체인에서.
5. **최소 1개 관계 필수** — atom은 반드시 그래프에 연결되어야 한다.
6. **알려진 관계는 모두 작성한다.** 5개든 20개든 임의로 제한하지 않는다.
   - 공격 기법 → `requires`(전제 취약점), `enables`(후속 공격), `applies_to`(대상 인프라) 모두 작성
   - 방어 기법 → `prevents`(차단하는 공격), `implements`(구현하는 정책), `requires`(의존하는 인프라) 모두 작성
   - 도구 → `enables`(가능하게 하는 공격/방어), `applies_to`(대상 시스템) 모두 작성

**참조 대상 atom이 아직 생성되지 않은 경우**: target에 예상 ID를 적고, 해당 atom은 나중에 생성한다. "프론티어 참조"로 간주되며 허용된다.

### 섹션 7: security_profile (선택, 보안 관련 atom)

```yaml
security_profile:
  # MITRE 매핑 (ATK, MALWARE, DETECT 등)
  mitre_mapping:
    technique_id: "T1190"
    tactic: ["Initial Access"]
    sub_techniques: ["T1190.001"]

  # CVE 매핑 (VUL atom)
  cve_mapping:
    cve_id: "CVE-2024-XXXX"
    cvss_score: 9.8
    cwe_id: "CWE-89"

  # 공격 컨텍스트 (ATK atom)
  attack_context:
    target_layers: [L5, L7]
    target_zones: [Z1, Z2, Z3]
    attack_path: "Z0A(Attacker) → Z1(Web Server) → Z2(App Server) → Z3(Database)"

  # 방어 컨텍스트 (DEF, INFRA 보안 장비)
  defense_context:
    effectiveness: "high"    # high / medium / low
    d3fend_mapping: "D3-NTA"
```

- MITRE ATT&CK 매핑이 가능한 모든 atom에 `mitre_mapping`을 작성한다.
- CWE/CVE 매핑이 가능한 모든 atom에 `cve_mapping`을 작성한다.
- D3FEND 매핑이 가능한 방어 atom에 `defense_context`를 작성한다.
- `attack_path`는 GR 좌표를 이용하여 공격 흐름을 표현한다.

### 섹션 8: metadata (필수)

```yaml
metadata:
  created: "2026-02-06"
  version: "1.0"
  confidence: "high"             # high(검증, 다수 출처) / medium(단일 출처) / low(추론)
  trust_source: "primary"        # primary(공식) / secondary(참고) / derived(추론)
  sources:
    - "출처 1"
    - "출처 2"
  search_keywords:
    - keyword1
    - keyword2
  embedding_text: >
    벡터 임베딩용 50-200단어 요약.
```

**규칙**:
- `sources`: 최소 1개. 가능한 공식 출처(MITRE, OWASP, NIST, CWE, RFC 등)를 우선. 있는 만큼 모두.
- `search_keywords`: 최소 5개. 사용자가 검색할 수 있는 모든 관련 키워드. 약어, 한국어, 영어 포함. 있는 만큼 모두.
- `embedding_text`: 영문 작성. 시맨틱 검색에 최적화. 해당 atom의 핵심 정보를 빠짐없이 요약. 가능한 200단어에 가깝게.

---

## 5. Prefix별 특수 규칙

### ATK (공격 기법)
- `core_concepts`에 모든 알려진 변종, 우회 기법, 페이로드 유형을 개별 항목으로.
- `relations`에서 `requires`(필요 취약점), `enables`(후속 행동), `applies_to`(대상 인프라) 모두 작성.
- MITRE ATT&CK 매핑이 가능하면 반드시 `security_profile.mitre_mapping` 작성.
- `how`에 실제 공격 절차를 단계별로 기술.

### MALWARE (악성코드)
- `core_concepts`에 감염 벡터, C2 프로토콜, 페이로드 유형, 회피 기법, 변종 계보를 개별 항목으로.
- 여러 기능을 가진 malware는 **주된 기능**으로 subdomain 결정. (예: Emotet → LOADER)
- 다른 기능들은 `core_concepts`와 `relations`에서 설명.
- 알려진 APT 그룹과의 관계를 `relations`에 기록. (예: `enables` → ACTOR-APT-LAZARUS-001)

### TOOL (도구)
- `core_concepts`에 주요 기능/모듈, 사용 시나리오, 주요 명령어를 개별 항목으로.
- `relations`에서 `enables`(지원하는 공격/방어 활동), `applies_to`(대상 시스템) 작성.
- 오펜시브 도구와 디펜시브 도구의 subdomain 구분 주의.

### DEF (방어)
- `core_concepts`에 구현 방법, 설정 항목, 베스트 프랙티스를 개별 항목으로.
- `relations`에서 `prevents`(차단하는 공격), `implements`(구현하는 상위 정책) 작성.
- 효과성과 한계를 `definition.how`에 명시.

### VUL (취약점)
- CWE 매핑이 가능하면 반드시 작성.
- `core_concepts`에 발생 조건, 영향 범위, 탐지 방법, 패치/완화책을 개별 항목으로.
- `relations`에서 어떤 ATK가 이 취약점을 이용하는지, 어떤 DEF가 방어하는지 작성.

### INFRA (인프라)
- 반드시 `gr_coordinates` 작성 (scope 금지).
- 하나의 제품이 여러 역할(Archetype)을 수행하면 **역할별로 별도 atom** 생성.
  - 예: Redis 캐시 → `INFRA-DATA-REDIS-CACHE-001` (L6, Z2)
  - 예: Redis 세션 저장소 → `INFRA-DATA-REDIS-SESSION-001` (L5, Z3)
- `core_concepts`에 주요 보안 설정, 알려진 취약점 영역, 배포 고려사항을 나열.

### ACTOR (행위자)
- `core_concepts`에 알려진 활동 이력, 주요 캠페인, 사용 도구, TTP를 개별 항목으로.
- 위협 그룹(APT, CRIME)은 국가/지역, 활동 기간, 동기를 `definition`에 포함.
- 보안 벤더/연구기관(VENDOR, RESEARCH)은 주요 제품/서비스, 기여를 `definition`에 포함.

### DETECT (탐지)
- `core_concepts`에 탐지 로직, 오탐/미탐 요인, 튜닝 방법을 개별 항목으로.
- `relations`에서 `effective_against`(탐지 대상 공격/악성코드) 작성.

### PROTO (프로토콜)
- `core_concepts`에 헤더 구조, 핸드셰이크, 보안 확장, 알려진 취약점을 개별 항목으로.
- RFC 번호를 `sources`에 반드시 포함.

### COMP (컴플라이언스)
- `core_concepts`에 주요 조항, 적용 범위, 벌칙, 인증 절차를 개별 항목으로.
- `relations`에서 `requires`(준수에 필요한 DEF atom) 작성.

### PRI (원칙)
- `abstraction_level: 4` 고정.
- `scope`의 target_layers와 target_zones는 대부분 전체 범위 (모든 L, 모든 Z).
- ID 형식: `PRI-{NAME}-{###}` (서브도메인 없음).

### TECH (기술 개념)
- `core_concepts`에 기술적 세부사항, 적용 영역, 보안 함의를 개별 항목으로.
- 다른 prefix와 경계가 모호할 때: 기법이면 ATK/DEF, 제품이면 TOOL, 규정이면 COMP. TECH는 순수 기술 개념에만.

---

## 6. 품질 체크리스트

atom YAML 작성 후 다음을 **모두** 확인한다:

### 필수 검증 (하나라도 실패 시 atom 생성 불가)

- [ ] `id`가 `{PREFIX}-{SUBDOMAIN}-{NAME}-{###}` 형식인가?
- [ ] `id`의 SUBDOMAIN이 `GR_CLASSIFICATION_RULES.md` Section 6 카탈로그에 존재하는가?
- [ ] `is_infrastructure`가 prefix에 맞게 설정되었는가? (INFRA=true, 나머지=false)
- [ ] `type`이 해당 prefix에 유효한 값인가?
- [ ] `atom_tags`가 2~10개이고, 모두 `atom_tags.yaml`에 정의된 값인가?
- [ ] INFRA atom에 `gr_coordinates`가 있는가? (scope 없어야 함)
- [ ] 비INFRA atom에 `scope`가 있는가? (gr_coordinates 없어야 함)
- [ ] `scope`에서 target_layers 또는 target_zones 중 하나 이상 채워졌는가?
- [ ] `definition.what`이 100자 이상인가?
- [ ] `relations`가 최소 1개 있는가?
- [ ] `relations`에 `related_to`가 없는가?
- [ ] `metadata.sources`가 최소 1개 있는가?
- [ ] `metadata.search_keywords`가 최소 5개 있는가?
- [ ] `metadata.embedding_text`가 50단어 이상인가?

### 품질 검증 (가능한 모두 통과해야 함)

- [ ] `aliases`에 알려진 모든 대체 이름이 포함되었는가?
- [ ] `core_concepts`에 해당 개념의 모든 핵심 하위 개념이 포함되었는가?
- [ ] `relations`에 알려진 모든 관계가 작성되었는가?
- [ ] `scope.target_components`에 알려진 모든 대상 인프라가 나열되었는가?
- [ ] `security_profile`에서 MITRE/CWE/CVE/D3FEND 매핑이 가능한 것은 모두 작성했는가?
- [ ] `sources`에 공식 출처(MITRE, OWASP, NIST, RFC, CWE)가 포함되었는가?
- [ ] `what`, `why`, `how` 모두 작성되었는가?
- [ ] 주관적 표현("best", "should", "might")이 없는가?
- [ ] `embedding_text`가 200단어에 가까운가?

---

## 7. 금지 사항 (절대 규칙)

| 금지 항목 | 사유 |
|-----------|------|
| `related_to` 관계 사용 | 너무 모호하고 무한 확장 가능 |
| 역방향 관계 저장 | 중복. 쿼리 시 계산. |
| 자유 형식 atom_tags | `atom_tags.yaml`에 없는 태그 사용 금지 |
| INFRA atom에 scope 사용 | `gr_coordinates`를 사용해야 함 |
| 비INFRA atom에 gr_coordinates 사용 | `scope`를 사용해야 함 |
| 순환 참조 | `is_a`, `part_of`, `requires` 체인 |
| 단일 문자 Function 코드 | `S1.2` 형식을 사용. `S` 단독 사용 금지 |
| 임의적 개수 제한 | core_concepts, relations, aliases, sources 등에 "3개만" 같은 제한 금지 |
| 혼합 개념 | 하나의 atom에 두 개 이상의 독립 개념 금지. 분리하여 별도 atom 생성. |
| 주관적 표현 | "best practice", "should be used", "might cause" 등 금지 |

---

## 8. 완전한 Atom 예시

아래 두 예시는 실제 atom YAML의 완성 형태를 보여준다. 하나는 **인프라 atom** (gr_coordinates 사용), 다른 하나는 **지식 atom** (scope 사용)이다. 모든 atom은 이 수준의 상세함을 목표로 한다.

### 예시 1: 인프라 Atom — INFRA-SEC-WAF-001

```yaml
# ============================================================
# GR Atom: INFRA-SEC-WAF-001
# Type: Infrastructure (gr_coordinates 사용)
# ============================================================

identity:
  id: "INFRA-SEC-WAF-001"
  name: "Web Application Firewall"
  normalized_name: "web_application_firewall"
  aliases:
    - "WAF"
    - "Web App Firewall"
    - "웹 애플리케이션 방화벽"
    - "Application Layer Firewall"
    - "Layer 7 Firewall"

classification:
  is_infrastructure: true      # INFRA- prefix → 항상 true
  type: "component_control"    # 보안 통제 장비
  abstraction_level: 2         # 구체적인 기술 구현체
  atom_tags:
    - WEB
    - HTTP
    - WAF
    - INJ
    - XSS
    - API

gr_coordinates:                # INFRA atom 전용. scope 사용 불가.
  layer: "L2"                  # 네트워크 라우팅/필터링 계층
  zone: "Z1"                   # 외부 트래픽에 직접 노출된 인프라
  function: "S1.2"             # Security > Network Security

definition:
  what: >
    Web Application Firewall(WAF)은 HTTP/HTTPS 트래픽을 분석하여 웹 애플리케이션을
    대상으로 하는 공격을 탐지하고 차단하는 보안 장비다. 전통적인 네트워크 방화벽이
    L3/L4 수준에서 IP와 포트를 기반으로 필터링하는 것과 달리, WAF는 L7(애플리케이션 계층)에서
    HTTP 요청/응답의 내용을 심층 분석한다. 1990년대 후반 웹 애플리케이션의 보안 필요성이
    대두되면서 등장했으며, 현재는 클라우드 기반 WAF(AWS WAF, Cloudflare WAF 등)와
    하드웨어 어플라이언스(F5 BIG-IP ASM, Imperva SecureSphere 등) 형태로 운영된다.
    OWASP ModSecurity Core Rule Set(CRS)이 오픈소스 규칙의 사실상 표준이다.

  why: >
    OWASP Top 10 공격의 대부분(SQL Injection, XSS, SSRF 등)은 웹 애플리케이션 계층에서
    발생하며, WAF는 이들에 대한 1차 방어선이다. PCI DSS 6.6 요구사항에서 웹 애플리케이션
    방화벽 또는 코드 리뷰를 명시적으로 요구하고 있어 컴플라이언스 측면에서도 필수적이다.
    특히 레거시 애플리케이션의 취약점을 코드 수정 없이 가상 패칭할 수 있다는 점에서
    운영상 큰 가치를 가진다.

  how: >
    WAF는 인바운드 HTTP 요청을 가로채어 사전 정의된 규칙 세트와 대조한다. 탐지 방식은
    크게 세 가지다: (1) 시그니처 기반 — 알려진 공격 패턴(정규식)과 매칭,
    (2) 이상 탐지 기반 — 정상 트래픽 프로파일과의 편차 탐지,
    (3) ML 기반 — 머신러닝 모델로 정상/비정상 분류.
    동작 모드는 Transparent(탐지만), Blocking(차단), Learning(학습) 모드가 있다.
    배포 위치에 따라 Reverse Proxy, Transparent Bridge, Cloud-based 아키텍처로 나뉜다.

  core_concepts:
    - key: "Positive Security Model"
      value: "허용된 패턴만 통과시키는 화이트리스트 방식. 알려지지 않은 공격에도 효과적이나 설정이 복잡하다."
    - key: "Negative Security Model"
      value: "알려진 공격 패턴을 차단하는 블랙리스트 방식. 설정이 쉽지만 제로데이 공격에 취약하다."
    - key: "Virtual Patching"
      value: "애플리케이션 코드를 수정하지 않고 WAF 규칙으로 취약점을 임시 차단하는 기법. 패치 적용까지의 시간 확보에 유용하다."
    - key: "ModSecurity CRS"
      value: "OWASP가 관리하는 오픈소스 WAF 규칙 세트. SQL Injection, XSS 등 주요 공격에 대한 포괄적인 시그니처를 제공한다."
    - key: "WAF Bypass"
      value: "인코딩 변환, 페이로드 분할, HTTP Parameter Pollution 등을 이용하여 WAF 규칙을 우회하는 기법들의 총칭."
    - key: "Rate Limiting"
      value: "단위 시간당 요청 수를 제한하여 DDoS, 브루트포스 등의 공격을 완화하는 WAF의 부가 기능."

relations:
  - type: "is_a"
    target: "INFRA-SEC-OVERVIEW-001"
    description: "보안 인프라 구성요소의 하위 유형"
  - type: "prevents"
    target: "ATK-INJECT-SQL-001"
    description: "SQL Injection 공격을 탐지하고 차단"
  - type: "prevents"
    target: "ATK-WEB-XSS-001"
    description: "Cross-Site Scripting 공격을 탐지하고 차단"
  - type: "prevents"
    target: "ATK-WEB-SSRF-001"
    description: "Server-Side Request Forgery 공격을 차단"
  - type: "prevents"
    target: "ATK-WEB-CSRF-001"
    description: "Cross-Site Request Forgery 공격을 차단"
  - type: "implements"
    target: "DEF-APPDEF-WAF-RULES-001"
    description: "WAF 규칙 정책을 실현하는 인프라"
  - type: "implements"
    target: "COMP-PCI-DSS-001"
    description: "PCI DSS 6.6 요구사항 구현"
  - type: "requires"
    target: "INFRA-NET-LB-001"
    description: "Reverse Proxy 배포 시 로드밸런서와 연동 필요"

security_profile:
  defense_context:
    effectiveness: "high"
    d3fend_mapping: "D3-NTA"

metadata:
  created: "2026-02-06"
  version: "1.0"
  confidence: "high"
  trust_source: "primary"
  sources:
    - "OWASP Web Application Firewall (https://owasp.org/www-community/Web_Application_Firewall)"
    - "OWASP ModSecurity Core Rule Set (https://coreruleset.org/)"
    - "PCI DSS v4.0 Requirement 6.4"
    - "NIST SP 800-41 Rev.1 — Guidelines on Firewalls and Firewall Policy"
  search_keywords:
    - WAF
    - web application firewall
    - 웹 방화벽
    - ModSecurity
    - virtual patching
    - application layer firewall
    - OWASP CRS
    - layer 7 firewall
    - reverse proxy security
    - PCI DSS 6.6
  embedding_text: >
    A Web Application Firewall (WAF) is a security appliance that monitors, filters,
    and blocks HTTP/HTTPS traffic to and from web applications. Operating at Layer 7
    of the OSI model, WAF analyzes the content of HTTP requests and responses to detect
    attacks such as SQL Injection, Cross-Site Scripting (XSS), Server-Side Request Forgery
    (SSRF), and other OWASP Top 10 vulnerabilities. WAFs can operate using negative
    security models (blacklisting known attack patterns via signatures like OWASP
    ModSecurity Core Rule Set), positive security models (whitelisting allowed patterns),
    or machine learning-based anomaly detection. Deployment architectures include reverse
    proxy, transparent bridge, and cloud-based configurations. Key capabilities include
    virtual patching (blocking vulnerabilities without code changes), rate limiting
    for DDoS mitigation, and bot detection. WAF is explicitly required by PCI DSS
    Requirement 6.6 as an alternative to code review for protecting payment card data.
    Major implementations include AWS WAF, Cloudflare WAF, F5 BIG-IP ASM, and Imperva
    SecureSphere. WAF bypass techniques using encoding tricks, payload fragmentation,
    and HTTP Parameter Pollution remain an active area of offensive security research.
```

### 예시 2: 지식 Atom — ATK-INJECT-SQL-001

```yaml
# ============================================================
# GR Atom: ATK-INJECT-SQL-001
# Type: Knowledge (scope 사용)
# ============================================================

identity:
  id: "ATK-INJECT-SQL-001"
  name: "SQL Injection"
  normalized_name: "sql_injection"
  aliases:
    - "SQLi"
    - "SQL Injection Attack"
    - "SQL 삽입 공격"
    - "SQL 인젝션"
    - "Structured Query Language Injection"

classification:
  is_infrastructure: false     # ATK- prefix → 항상 false
  type: "technique"            # 구체적인 공격 기법
  abstraction_level: 2         # 기법 수준
  atom_tags:
    - WEB
    - API
    - INJ
    - EXEC
    - CLOUD
    - WINDOWS
    - LINUX
    - MACOS
    - CONTAINER

scope:                         # 비INFRA atom 전용. gr_coordinates 사용 불가.
  target_layers:
    - L5                       # 데이터 저장/처리 계층
    - L6                       # 애플리케이션 호스팅 계층
    - L7                       # 비즈니스 로직 계층
  target_zones:
    - Z1                       # 외부 노출 인프라
    - Z2                       # 애플리케이션 서비스
    - Z3                       # 데이터 저장소
  target_components:
    - "INFRA-DATA-POSTGRESQL-001"
    - "INFRA-DATA-MYSQL-001"
    - "INFRA-DATA-MSSQL-001"
    - "INFRA-DATA-ORACLE-001"
    - "INFRA-DATA-SQLITE-001"
    - "INFRA-DATA-MARIADB-001"
    - "INFRA-DATA-MONGODB-001"
    - "INFRA-APP-TOMCAT-001"
    - "INFRA-APP-IIS-001"
    - "INFRA-APP-NGINX-001"
    - "INFRA-APP-API-001"
    - "INFRA-COMPUTE-EC2-001"

definition:
  what: >
    SQL Injection은 사용자 입력값을 통해 백엔드 데이터베이스에 임의의 SQL 쿼리를
    삽입·실행하는 공격 기법이다. 1998년 Phrack Magazine #54에서 Rain Forest Puppy가
    최초 공개한 이래 현재까지 가장 빈번하고 치명적인 웹 애플리케이션 공격으로 분류된다.
    공격자는 웹 폼, URL 파라미터, HTTP 헤더, 쿠키 등 애플리케이션이 SQL 쿼리에
    포함시키는 모든 입력 지점을 공격 벡터로 활용한다. 성공 시 데이터 유출, 데이터 조작,
    인증 우회, 원격 코드 실행(xp_cmdshell 등)까지 가능하다. OWASP Top 10에서
    2013/2017년 A1, 2021년 A03(Injection 범주)으로 지속 선정되었으며,
    CWE-89로 분류된다.

  why: >
    SQL Injection은 OWASP Top 10의 상위를 20년 이상 차지해온 가장 위험한 웹 취약점이다.
    성공 시 전체 데이터베이스의 기밀 데이터 유출, 데이터 무결성 파괴, 시스템 완전 장악이
    가능하다. Heartland Payment Systems(2008, 1.3억 카드 정보 유출),
    Sony Pictures(2011), TalkTalk(2015) 등 대규모 침해 사고의 근본 원인이었다.
    자동화 도구(sqlmap 등)의 발전으로 비전문가도 쉽게 공격할 수 있어 위험도가 높다.

  how: >
    공격 절차: (1) 입력 지점 식별 — 웹 폼, URL 파라미터, API 엔드포인트에서 DB와
    상호작용하는 지점을 탐색한다. (2) 취약점 확인 — 작은따옴표('), 세미콜론(;),
    주석(--) 등을 삽입하여 에러 발생 여부를 확인한다. (3) DB 구조 파악 —
    information_schema 테이블 또는 에러 메시지를 통해 테이블명, 컬럼명을 추출한다.
    (4) 데이터 추출 — UNION SELECT, 조건부 응답(Blind), 시간 지연(Time-based) 등으로
    실제 데이터를 추출한다. (5) 권한 상승 — DB 관리자 계정 탈취, OS 명령 실행
    (xp_cmdshell, INTO OUTFILE 등)을 시도한다. (6) 지속적 접근 — 백도어 계정 생성,
    웹셸 업로드 등으로 영구 접근을 확보한다.

  core_concepts:
    - key: "Union-Based SQL Injection"
      value: "UNION SELECT 구문을 이용하여 원래 쿼리에 추가 결과 집합을 병합하는 기법. 결과가 화면에 표시되는 경우에 사용 가능하며, 컬럼 수와 데이터 타입을 맞춰야 한다."
    - key: "Boolean-Based Blind SQL Injection"
      value: "참/거짓 조건에 따른 응답 차이를 이용하여 한 비트씩 정보를 추출하는 기법. 에러 메시지나 결과가 직접 표시되지 않을 때 사용한다. 자동화 없이는 매우 느리다."
    - key: "Time-Based Blind SQL Injection"
      value: "SLEEP(), WAITFOR DELAY, pg_sleep() 등 시간 지연 함수를 이용하여 조건부로 응답 시간 차이를 만들어 정보를 추출하는 기법. Boolean Blind보다 느리지만 응답 내용이 완전히 동일할 때도 사용 가능하다."
    - key: "Error-Based SQL Injection"
      value: "의도적으로 SQL 에러를 발생시켜 에러 메시지에 포함된 데이터베이스 정보를 추출하는 기법. extractvalue(), updatexml() (MySQL), CAST/CONVERT 에러 (MSSQL) 등 DB별 특화 기법이 있다."
    - key: "Out-of-Band SQL Injection"
      value: "DNS 조회(UTL_HTTP, xp_dirtree), HTTP 요청(UTL_HTTP) 등 대역 외 채널을 통해 데이터를 외부로 전송하는 기법. 인바운드 응답 분석이 불가능할 때 사용한다."
    - key: "Second-Order SQL Injection"
      value: "첫 입력 시에는 안전하게 저장되지만, 이후 다른 기능에서 해당 값이 쿼리에 사용될 때 실행되는 지연 공격 기법. 입력 시점과 실행 시점이 분리되어 탐지가 어렵다."
    - key: "Stacked Queries"
      value: "세미콜론(;)으로 구분하여 여러 SQL 문을 한 번에 실행하는 기법. INSERT, UPDATE, DELETE, DROP 등 임의 쿼리 실행이 가능하여 파괴력이 가장 크다. MSSQL, PostgreSQL에서 지원하며 MySQL에서는 기본 비활성."
    - key: "Parameterized Query (Prepared Statement)"
      value: "SQL 구문과 사용자 입력을 구조적으로 분리하여 SQL Injection을 근본적으로 방지하는 방어 기법. 모든 주요 언어/프레임워크에서 지원하며, SQL Injection의 가장 효과적인 방어책이다."
    - key: "WAF Bypass Techniques"
      value: "인코딩 변환(URL, Unicode, Hex), 대소문자 혼합, 주석 삽입(/**/), HPP(HTTP Parameter Pollution), 청크 전송 인코딩 등을 이용하여 WAF의 SQL Injection 탐지 규칙을 우회하는 기법들."

relations:
  # 구조적 관계
  - type: "is_a"
    target: "ATK-INJECT-OVERVIEW-001"
    description: "Injection 공격의 하위 유형"
  - type: "is_a"
    target: "ATK-MITRE-T1190-001"
    description: "MITRE ATT&CK T1190 Exploit Public-Facing Application의 인스턴스"

  # 인과적 관계
  - type: "causes"
    target: "VUL-INJECT-CWE89-001"
    description: "CWE-89 취약점을 악용하여 발생"
  - type: "enables"
    target: "ATK-PRIV-DBADMIN-001"
    description: "DB 관리자 권한 탈취 가능"
  - type: "enables"
    target: "ATK-EXEC-OSCMD-001"
    description: "xp_cmdshell 등을 통한 OS 명령 실행 가능"
  - type: "enables"
    target: "ATK-EXFIL-DATA-001"
    description: "대량 데이터 유출 가능"

  # 조건적 관계
  - type: "requires"
    target: "VUL-INJECT-CWE89-001"
    description: "사용자 입력이 SQL 쿼리에 직접 포함되는 취약점 필요"
  - type: "requires"
    target: "INFRA-DATA-RDBMS-001"
    description: "SQL을 사용하는 관계형 데이터베이스가 백엔드에 존재해야 함"
  - type: "alternative_to"
    target: "ATK-INJECT-NOSQL-001"
    description: "NoSQL 환경에서는 NoSQL Injection이 대안"

  # 적용성 관계
  - type: "applies_to"
    target: "INFRA-DATA-POSTGRESQL-001"
    description: "PostgreSQL 데이터베이스에 적용 가능"
  - type: "applies_to"
    target: "INFRA-DATA-MYSQL-001"
    description: "MySQL/MariaDB 데이터베이스에 적용 가능"
  - type: "applies_to"
    target: "INFRA-DATA-MSSQL-001"
    description: "Microsoft SQL Server에 적용 가능 (xp_cmdshell로 OS 명령 실행까지)"
  - type: "applies_to"
    target: "INFRA-DATA-ORACLE-001"
    description: "Oracle Database에 적용 가능 (UTL_HTTP로 OOB 가능)"

security_profile:
  mitre_mapping:
    technique_id: "T1190"
    tactic:
      - "Initial Access"
    sub_techniques: []
  cve_mapping:
    cwe_id: "CWE-89"
  attack_context:
    attack_path: "Z0A(Attacker) → Z1(Web Server) → Z2(App Server) → Z3(Database)"

metadata:
  created: "2026-02-06"
  version: "1.0"
  confidence: "high"
  trust_source: "primary"
  sources:
    - "OWASP SQL Injection (https://owasp.org/www-community/attacks/SQL_Injection)"
    - "MITRE ATT&CK T1190 (https://attack.mitre.org/techniques/T1190/)"
    - "CWE-89: Improper Neutralization of Special Elements used in an SQL Command (https://cwe.mitre.org/data/definitions/89.html)"
    - "NIST NVD — SQL Injection related CVEs"
    - "Phrack Magazine #54 — Rain Forest Puppy (1998)"
    - "sqlmap Official Documentation (https://sqlmap.org/)"
  search_keywords:
    - SQL injection
    - SQLi
    - SQL 삽입
    - SQL 인젝션
    - blind SQL injection
    - union injection
    - parameterized query
    - prepared statement
    - sqlmap
    - CWE-89
    - OWASP injection
    - database attack
  embedding_text: >
    SQL Injection (SQLi) is a code injection technique that exploits vulnerabilities
    in web applications by inserting malicious SQL statements into input fields that
    are incorporated into backend database queries. First publicly documented by
    Rain Forest Puppy in Phrack Magazine #54 (1998), SQL Injection remains one of
    the most prevalent and dangerous web application attacks, consistently ranking
    in the OWASP Top 10 (A1 in 2013/2017, A03 in 2021). Attack variants include
    Union-based (appending UNION SELECT to merge result sets), Boolean-based blind
    (inferring data bit-by-bit from true/false response differences), Time-based blind
    (using SLEEP/WAITFOR DELAY for conditional time delays), Error-based (extracting
    data from error messages), Out-of-Band (exfiltrating via DNS/HTTP side channels),
    Second-Order (stored payloads triggered later), and Stacked Queries (executing
    multiple statements via semicolons). Successful exploitation can lead to complete
    database compromise, authentication bypass, data exfiltration, and remote code
    execution via functions like xp_cmdshell (MSSQL) or INTO OUTFILE (MySQL). The
    primary defense is parameterized queries (prepared statements) that structurally
    separate SQL syntax from user input. Additional mitigations include input validation,
    Web Application Firewalls (WAF), least-privilege database accounts, and stored
    procedures. WAF bypass techniques using encoding tricks, comment injection, and
    HTTP Parameter Pollution remain active research areas. The vulnerability is
    classified as CWE-89 and mapped to MITRE ATT&CK T1190.
```

> **예시 비교 포인트**:
> - **INFRA atom**은 `gr_coordinates`를 사용하고 `scope`를 사용하지 않는다.
> - **지식 atom**은 `scope`를 사용하고 `gr_coordinates`를 사용하지 않는다.
> - `core_concepts`, `relations`, `target_components` 등은 알려진 내용을 **모두** 나열한다. 임의로 3개로 제한하지 않는다.
> - `embedding_text`는 200단어에 가깝게 작성하여 벡터 검색 품질을 높인다.
> - `aliases`는 영어, 한국어, 약어 등 가능한 모든 변형을 포함한다.

---

## 9. AI 원자화 프롬프트 템플릿

아래 프롬프트를 AI에게 제공하여 원자화를 수행할 수 있다.

### 프롬프트 A: 단일 Atom 생성

```
당신은 GR 온톨로지의 원자화 전문가입니다.

아래 참조 파일들을 읽고 이해한 후, 주어진 개념을 atom YAML로 변환하세요:
- 분류 규칙: 03_engine/engine_b/GR_CLASSIFICATION_RULES.md
- 스키마: 03_engine/engine_b/atom_schema.yaml
- 태그 어휘: 03_engine/engine_b/atom_tags.yaml
- 원자화 가이드: 03_engine/engine_b/ATOMIZATION_GUIDE.md

[원자화 대상 개념]:
{concept_name}

[출력]:
위키 수준의 상세한 atom YAML 파일 1개.
- 8개 섹션 모두 작성
- core_concepts, relations, aliases, sources 등 작성할 내용이 있다면 개수 제한 없이 모두 작성
- 품질 체크리스트 전체 항목 통과 필수
- Section 8의 완전한 예시를 참고하여 동일한 수준의 상세함으로 작성
- YAML 파일을 04_db/atom_data/{PREFIX}/ 디렉토리에 저장
```

### 프롬프트 B: 배치 Atom 생성

```
당신은 GR 온톨로지의 원자화 전문가입니다.

아래 참조 파일들을 읽고 이해한 후, 주어진 개념 목록을 atom YAML로 변환하세요:
- 분류 규칙: 03_engine/engine_b/GR_CLASSIFICATION_RULES.md
- 스키마: 03_engine/engine_b/atom_schema.yaml
- 태그 어휘: 03_engine/engine_b/atom_tags.yaml
- 원자화 가이드: 03_engine/engine_b/ATOMIZATION_GUIDE.md

[분류 정보]:
Prefix: {PREFIX}
Subdomain: {SUBDOMAIN}

[원자화 대상 목록]:
- {item1}
- {item2}
- {item3}
...

[출력]:
각 항목에 대해 위키 수준의 상세한 atom YAML 파일을 생성하세요.
- 각 YAML은 8개 섹션 모두 포함
- core_concepts, relations, aliases, sources 등 작성할 내용이 있다면 개수 제한 없이 모두 작성
- 품질 체크리스트 전체 항목 통과 필수
- Section 8의 완전한 예시를 참고하여 동일한 수준의 상세함으로 작성
- 각 YAML 파일을 04_db/atom_data/{PREFIX}/ 디렉토리에 {ID}.yaml 이름으로 저장
- 완료 후 생성된 atom 목록과 ID를 요약 보고
```

### 프롬프트 C: 기존 Atom 보강

```
당신은 GR 온톨로지의 원자화 전문가입니다.

아래 파일의 기존 atom을 검토하고 보강하세요:
- 원자화 가이드: 03_engine/engine_b/ATOMIZATION_GUIDE.md
- 대상 atom: {yaml_file_path}

[검토 항목]:
1. 품질 체크리스트 14개 필수 항목 전부 통과하는가?
2. core_concepts가 충분히 상세한가? 빠진 하위 개념이 없는가?
3. relations에 추가해야 할 관계가 있는가?
4. scope.target_components에 추가해야 할 인프라가 있는가?
5. aliases, sources, search_keywords에 추가할 항목이 있는가?

[출력]:
보강된 atom YAML 파일. 변경 사항을 주석으로 표시.
```

---

## 10. 파일 저장 규칙

### 디렉토리 구조

```
04_db/atom_data/
├── ATK/
│   ├── ATK-INJECT-SQL-001.yaml
│   ├── ATK-INJECT-COMMAND-001.yaml
│   ├── ATK-MITRE-T1059-001.yaml
│   └── ...
├── MALWARE/
│   ├── MALWARE-RANSOM-LOCKBIT-001.yaml
│   └── ...
├── TOOL/
│   ├── TOOL-NETMON-WIRESHARK-001.yaml
│   └── ...
└── [각 prefix 디렉토리]
```

### 파일명 규칙

- 파일명 = atom ID + `.yaml`
- 예: `ATK-INJECT-SQL-001.yaml`, `INFRA-SEC-WAF-001.yaml`
- 대문자, 하이픈 구분
- 하나의 YAML 파일에 하나의 atom만

---

*문서 버전: v5.1 | 최종 업데이트: 2026-02-06*
