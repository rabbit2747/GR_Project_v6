# GR 생태계 마스터플랜 v5.0

> **한 줄 요약**: 모든 IT/보안 지식을 원자화(Atomize)하여 인프라 컨텍스트 기반의 보안 지식 생태계를 구축하고, 이를 Foundation으로 다양한 보안 제품과 서비스를 파생시킨다.

---

## 1. 프로젝트 비전

### 1.1 문제 정의

현재 보안 지식은 **컨텍스트 없이 파편화**되어 있다.

- "SQL Injection은 위험하다" — **어디에서?** WAF 뒤의 L7 Application인가, DMZ의 Public API인가?
- "방화벽을 설치하라" — **어떤 경계에?** Zone 1 Perimeter인가, Zone 2-3 사이의 Data Boundary인가?
- "Redis를 패치하라" — Redis가 **캐시(L6, Z2)**로 쓰이는가, **세션 저장소(L5, Z3)**로 쓰이는가에 따라 보안 정책이 완전히 달라진다.

보안 지식의 가치는 **인프라 컨텍스트(WHERE)**가 부여될 때 비로소 실현된다.

### 1.2 GR이 해결하는 것

**GR(Gotroot)**은 모든 IT 인프라 구성요소에 **3차원 좌표(Layer × Zone × Function)**를 부여하고, 모든 보안 지식(공격, 방어, 취약점, 도구, 규정 등)을 해당 좌표와 연결하는 **보안 지식 인프라**를 구축한다.

결과적으로:
- **모든 인프라 구성요소의 좌표화** — 3D 공간에서 고유한 위치 부여
- **같은 좌표 = 같은 보안 정책** (배포 환경 무관)
- **보안 지식의 인프라 컨텍스트 연결** — 모든 공격/방어/취약점이 "어디에서" 발생하는지 명확화

### 1.3 핵심 목표

| 목표 | 설명 |
|------|------|
| **표준 언어** | 보안 팀, 인프라 팀, AI가 동일한 좌표 체계로 소통 |
| **AI Ground Truth** | LLM 할루시네이션을 방지하는 검증된 보안 지식 데이터셋 |
| **자동 추론** | 좌표 기반 보안 정책 자동 생성 및 CVE 영향도 즉시 분석 |
| **생태계 Foundation** | "Powered by GR"로 다양한 보안 제품의 기반이 되는 인프라 |

---

## 2. 핵심 철학

### 2.1 Foundation, not Product

GR은 **제품이 아니라 기반 인프라**다.

Intel이 CPU를 만들어 "Intel Inside"를 달성한 것처럼, GR은 보안 지식 좌표 체계를 구축하여 **"Powered by GR Data"**를 목표로 한다. GR 위에 진단 도구, IaC 시스템, 교육 플랫폼, 컨설팅 서비스가 올라간다. GR 자체는 어떤 하나의 보안 제품도 아니다.

### 2.2 AI-First Architecture

GR의 **1차 소비자는 AI**이고, 인간은 2차 소비자다.

- 모든 지식은 **산문이 아닌 구조화된 데이터**(YAML)로 저장
- 필드명은 기계가 파싱 가능하도록 설계
- 관계(relation)는 **의미적으로 정확한 타입만** 허용 (`related_to` 금지)
- AI가 추론하기 쉬운 **그래프 구조** 우선

### 2.3 Infrastructure as Anchor

모든 보안 지식은 **인프라 컨텍스트에 연결될 때만 의미가 있다.**

- "SQL Injection" 단독 → 일반론
- "SQL Injection → L7-Z2의 API Server가 Z3-L5의 PostgreSQL을 공격" → 실행 가능한 보안 정보

인프라 atom(`is_infrastructure: true`)은 3D 좌표를 가지며, 지식 atom(`is_infrastructure: false`)은 scope를 통해 인프라에 연결된다.

### 2.4 Everything is Graph

모든 지식은 **노드(atom)와 엣지(relation)로 구성된 그래프**다.

- 단일 atom은 의미 단위의 최소 지식
- atom 간 관계는 **의미적으로 정확한 타입**으로만 연결
- 역관계(inverse)는 저장하지 않고 쿼리 시 계산
- 순환 참조 금지 (`is_a`, `part_of`, `requires` 등)
- 그래프 순회를 통해 공격 경로, 방어 체인, 영향도 분석 수행

### 2.5 Single Source of Truth (SSOT)

하나의 사실은 **정확히 한 곳에만** 존재한다.

- PostgreSQL이 마스터 DB이며 모든 atom의 정본(canonical) 저장소
- Neo4j와 Pinecone은 PostgreSQL에서 동기화된 파생 뷰
- atom YAML 파일은 PostgreSQL에 적재되기 전의 소스 형태
- 중복 저장 금지: 같은 정보가 두 atom에 존재하면 하나를 `part_of`로 참조

### 2.6 Pragmatism First

학술적 완벽함보다 **실용적 적용 가능성**을 우선한다.

- 관계 타입은 50개가 아닌 **15개 내외**로 제한 (일관성 확보)
- 분류 규칙은 **결정론적(deterministic)**: 같은 입력 → 항상 같은 분류 결과
- 모호함이 발생하면 **규칙이 불완전한 것**이며, 규칙을 수정해야 한다
- 확장은 필요할 때만, 기존 체계를 깨지 않는 범위에서

---

## 3. 정보 원자화 (Information Atomization)

### 3.1 개념

**정보 원자화**란 모든 IT/보안 지식을 **자기 완결적인 최소 단위(atom)**로 분해하는 것이다.

각 atom은:
- **고유 ID**를 가진다 (예: `INFRA-NET-WAF-001`, `ATK-INJECT-SQL-001`)
- **표준 스키마**를 따른다 (identity, classification, definition, relations, properties, metadata)
- **독립적으로 의미가 완결**된다 (다른 atom 없이도 "이것이 무엇인가"를 설명)
- **관계를 통해 지식 그래프**를 형성한다 (is_a, part_of, enables, prevents 등)

### 3.2 왜 원자화인가?

| 기존 방식 | GR 원자화 |
|-----------|-----------|
| 긴 문서에 여러 개념 혼재 | 하나의 atom = 하나의 개념 |
| 검색으로 찾기 어려움 | ID와 태그로 정확한 검색 |
| AI가 파싱하기 어려움 | 구조화된 YAML로 즉시 파싱 |
| 지식 간 관계 불명확 | 명시적 관계 타입으로 그래프 형성 |
| 업데이트 시 전체 문서 수정 | 해당 atom만 업데이트 |
| 중복 발생 | SSOT 원칙으로 중복 제거 |

### 3.3 이분법: Infrastructure vs Knowledge

모든 atom은 **정확히 두 범주 중 하나**에 속한다:

| 속성 | Infrastructure Atom | Knowledge Atom |
|------|-------------------|----------------|
| `is_infrastructure` | `true` | `false` |
| 3D 좌표 | `gr_coordinates` (Layer, Zone, Function) | 없음 |
| 범위 | 없음 | `scope` (적용 대상 Layer/Zone) |
| ID 접두사 | `INFRA-*` | 그 외 모든 접두사 |
| 의미 | 실제 인프라 구성요소 | 지식, 개념, 기법, 정책 |

**4-Question Test** (하나라도 Yes → `is_infrastructure: true`):
1. 네트워크 주소(IP, hostname)를 가질 수 있는가?
2. 프로세스(PID)로 실행될 수 있는가?
3. 물리적 형태(하드웨어)를 가질 수 있는가?
4. 시스템 리소스(CPU, 메모리, 디스크)를 소비하는가?

### 3.4 12-Prefix ID 체계

모든 atom의 ID는 12개 접두사 중 하나로 시작한다:

| 접두사 | 분류 | is_infrastructure | 기본 type | 예시 |
|--------|------|-------------------|-----------|------|
| `INFRA-` | 인프라 구성요소 | `true` | component | WAF, PostgreSQL, K8s |
| `ATK-` | 공격 기법 | `false` | technique | SQL Injection, Phishing |
| `DEF-` | 방어 기법/통제 | `false` | control_policy | 입력 검증, WAF 규칙 |
| `VUL-` | 취약점 | `false` | vulnerability | CWE-89, 인증 우회 |
| `TOOL-` | 도구 지식 | `false` | tool_knowledge | Metasploit 가이드, Nmap |
| `COMP-` | 규정/컴플라이언스 | `false` | control_policy | NIST CSF, ISO 27001 |
| `TECH-` | 기술 개념 | `false` | concept | Zero Trust, 마이크로서비스 |
| `ACTOR-` | 위협 행위자 | `false` | concept | APT 그룹, 내부자 위협 |
| `MALWARE-` | 악성코드 | `false` | technique | 랜섬웨어, 트로이목마 |
| `DETECT-` | 탐지 규칙/시그니처 | `false` | pattern | Sigma 규칙, YARA 규칙 |
| `PROTO-` | 프로토콜 | `false` | protocol | HTTP/2, TLS 1.3, OAuth |
| `PRI-` | 원칙/철학 | `false` | principle | 최소 권한, 심층 방어 |

### 3.5 11 Type 체계

**Infrastructure Types** (INFRA-* 전용):
- `component`: 핵심 인프라 구성요소 (서버, DB, 라우터)
- `component_tool`: 운영/보안 도구가 인프라로 배포된 형태 (SIEM 인스턴스, EDR 에이전트)
- `component_control`: 보안 통제가 인프라로 배포된 형태 (WAF 어플라이언스, IDS/IPS)

**Knowledge Types**:
- `concept`: 추상적 개념/분류 (Zero Trust, 네트워크 공격)
- `technique`: 실행 가능한 공격/방어 기법 (SQL Injection, 패치 관리)
- `vulnerability`: 약점/취약점 (CWE-89, 인증 우회)
- `principle`: 보안 원칙/철학 (최소 권한, 심층 방어)
- `pattern`: 시그니처/탐지 패턴 (SQLi 페이로드, Sigma 규칙)
- `protocol`: 통신 표준/프로토콜 (HTTP, TLS, OAuth)
- `tool_knowledge`: 도구 사용 지식 (Metasploit 활용법)
- `control_policy`: 정책/절차/규정 (접근 제어 정책, NIST CSF)

### 3.6 Archetype 개념

하나의 **제품(Product)**은 여러 **역할(Archetype)**을 수행할 수 있다.

예시: Redis
- **Archetype 1**: Key-Value Store → L5(Data), Z3(Data Zone), D1.1
- **Archetype 2**: In-Memory Cache → L6(Runtime), Z2(Service Zone), D2.1
- **Archetype 3**: Session Store → L5(Data), Z3(Data Zone), D1.1

각 Archetype는 **별도의 atom**으로 생성되며, 각각 고유한 3D 좌표를 갖는다. 같은 Redis이지만 역할에 따라 보안 정책이 완전히 달라지기 때문이다.

### 3.7 Abstraction Level

모든 atom에는 추상화 수준이 부여된다:

| Level | 이름 | 설명 | 예시 |
|-------|------|------|------|
| 4 | Principle | 가장 추상적, 철학/원칙 | 최소 권한, 심층 방어 |
| 3 | Concept | 분류/범주 | Injection, 네트워크 보안 |
| 2 | Technique | 실행 가능한 기법/도구 | SQL Injection, WAF |
| 1 | Instance | 가장 구체적, 특정 사례 | `' OR 1=1--` 페이로드, CVE-2024-XXXX |

---

## 4. 3D 좌표 체계 개요

> 상세 사양은 `02_framework/GR_3D_FRAMEWORK.md` 참조

### 4.1 개념

GR 3D 좌표 체계는 모든 인프라 구성요소에 **세 가지 차원의 좌표**를 부여한다:

```
[Layer(수직) × Zone(수평) × Function(기능)]
```

- **Layer**: 기술 스택에서의 수직적 위치 (L0~L7 + Cross-Layer)
- **Zone**: 보안 신뢰 경계에서의 수평적 위치 (Z0A~Z5)
- **Function**: 수행하는 기능적 역할 (10개 도메인, 280+ 코드)

### 4.2 좌표화의 핵심 가치

1. **좌표화 (Classification)**: 모든 인프라 구성요소에 3D 좌표를 부여하여 고유한 위치를 정의
2. **배포 독립성**: AWS, Azure, On-Premise 어디에 배포하든 좌표는 동일
3. **보안 지식 연결**: 좌표가 부여된 인프라에 공격/방어/취약점 지식을 컨텍스트와 함께 연결
4. **기능 분석 → 좌표 자동 결정**: 제품의 기능을 분석하면 Layer, Zone, Function이 결정됨

---

## 5. 기술 아키텍처

### 5.1 3-DB 하이브리드 전략

| DB | 역할 | 저장 대상 | 강점 |
|----|------|-----------|------|
| **PostgreSQL** | 마스터/SSOT | 모든 atom의 정본 데이터 | ACID, 구조적 쿼리, 불변 사실 |
| **Neo4j** | 그래프 순회 | atom 간 관계, 공격 경로 | 관계 탐색, 경로 분석, 영향도 |
| **Pinecone** | 벡터/의미 검색 | atom 임베딩, 설명 벡터 | 유사도 검색, RAG |

**동기화 원칙**: PostgreSQL → Neo4j, Pinecone (단방향). PostgreSQL이 항상 정본이며, Neo4j와 Pinecone은 파생 뷰.

### 5.2 2-Tier 원자화 전략

| Tier | 저장소 | 내용 | 특성 |
|------|--------|------|------|
| **Tier 1: Product Master** | PostgreSQL | 제품 불변 사실 (이름, 벤더, CPE, 라이선스, 버전) | 사실 기반, 변경 드문 |
| **Tier 2: Component Archetype** | Neo4j + Pinecone | 제품의 역할별 atom (각각 고유 3D 좌표) | 역할 기반, 맥락 의존적 |

목표: 10,000 제품 × 평균 3 Archetype = **30,000 지식 노드**

### 5.3 Engine 구조

> 상세 사양은 `03_engine/` 참조

**Engine A (Orchestrator / "사서")**: 3개 DB에 대한 단일 접근점. 쿼리 유형에 따라 최적 DB를 라우팅하고, 결과를 통합하여 반환.

**Engine B (Atomizer / 분류 엔진)**: 4-Layer AI 파이프라인으로 원시 데이터를 atom으로 변환. 수집 → 분석 → 분류 → 검증의 자동화된 프로세스.

### 5.4 LLM 전략

| 단계 | 전략 | 비용 |
|------|------|------|
| Phase 0-2 | 외부 LLM API (GPT-4, Claude) | ~$1,000/년 |
| Phase 2+ (고객 배포) | 80% Direct Query (AI 불필요) + 20% AI-Assisted | 가변 |
| Phase 3 | 자체 Fine-tuned LLM (30,000+ 데이터 학습) | 초기 $50K |

**핵심**: 대부분의 쿼리는 구조화된 DB 검색으로 해결 (AI 불필요, 비용 $0, 100% 정확). AI는 유사도 검색, 자연어 질의, 추론이 필요한 경우에만 사용.

---

## 6. GR 생태계 구조

### 6.1 4-Layer 생태계

```
┌──────────────────────────────────────────┐
│  Layer 4: Products (SaaS 서비스)          │  ← 수익 창출
│  자동 진단 / GR IaC / 교육 / 컨설팅       │
├──────────────────────────────────────────┤
│  Layer 3: AI/RAG Intelligence            │  ← API 과금
│  추론 엔진 (Engine A + LLM)              │
├──────────────────────────────────────────┤
│  Layer 2: GR Framework (문법)             │  ← 오픈 표준
│  3D 좌표 체계 + 분류 규칙 + 스키마        │
├──────────────────────────────────────────┤
│  Layer 1: GR DB (Foundation)             │  ← 무료/제한적
│  30,000 atom 지식 그래프                  │
└──────────────────────────────────────────┘
```

### 6.2 MITRE ATT&CK 통합

MITRE는 **HOW**(공격 기법)를 제공하고, GR은 **WHERE**(인프라 위치)를 제공한다.

통합 결과: "어떤 공격 기법(MITRE)이 어떤 인프라 위치(GR 좌표)에서, 어떤 방어(GR DEF atom)로 대응되는가"

- ATK atom에 MITRE 매핑 (technique_id, tactic, sub_techniques)
- GR 확장: target_layers, target_zones, target_components, attack_path
- D3FEND 매핑으로 방어 atom에 효과성 점수 부여

### 6.3 GR Atlas

> 상세 사양은 `05_atlas/GR_ATLAS_SPEC.md` 참조

GR Atlas는 **"Feature, not Product"** — 독립 제품이 아니라 모든 GR 기반 제품에 공유되는 시각화 컴포넌트.

인프라를 지도처럼 보여주며, Layer × Zone 격자 위에 구성요소들이 배치되고, 공격 흐름, 취약점, 방어 체인이 시각화된다.

---

## 7. 개발 로드맵

### Phase 0: Foundation (현재)
- 프레임워크 설계 확정 (v5 문서 체계)
- 500+ 핵심 atom 구축
- 3D 좌표 체계 확정
- 분류 규칙 결정론적 확정
- 예상 비용: $15K

### Phase 1: MVP
- 자동 진단 도구 프로토타입
- 2,000 atom 달성
- Engine A 기본 구현 (PostgreSQL 단일)
- Engine B 파이프라인 구현
- 첫 유료 고객 확보
- 예상 비용: $100K

### Phase 2: Expansion
- 4개 제품 라인 런칭
- 10,000 atom 달성
- 3-DB 하이브리드 완성
- RAG 엔진 통합
- 예상 비용: $500K

### Phase 3: Ecosystem
- 파트너 생태계 구축 ("Powered by GR")
- 30,000+ atom
- 자체 Fine-tuned LLM
- API 이코노미 (B2B2B)

### 인프라 비용 (Phase 1 기준)

| 항목 | 월 비용 |
|------|---------|
| PostgreSQL (RDS) | ~$100 |
| Neo4j (AuraDB) | ~$65 |
| Pinecone (Standard) | ~$70 |
| OpenAI/Claude API | ~$85 |
| 기타 인프라 | ~$100 |
| **합계** | **~$420/월 ($5,040/년)** |

---

## 8. 경쟁 우위 (Competitive Moat)

1. **사전 매핑된 지식 베이스**: 30,000 노드, 복제에 2년+ 소요
2. **3D 좌표 체계**: 특허 가능한 고유 분류 시스템
3. **AI Ground Truth**: 할루시네이션 방지를 위한 검증된 데이터셋
4. **네트워크 효과**: 매핑된 제품이 많을수록 AI가 더 똑똑해짐
5. **API 이코노미**: "Powered by GR Data"로 B2B2B 수익 모델

---

## 9. 비즈니스 전략 개요

> 상세 내용은 `06_business/GR_BUSINESS.md` 참조

### 수익 모델

| Tier | 대상 | 내용 | 가격 |
|------|------|------|------|
| Free | 커뮤니티 | 프레임워크 사양 + 제한적 DB API | 무료 |
| Premium | B2B | 전체 DB 접근 + AI 추론 엔진 | $500/월 |
| Products | Enterprise | 자동 진단, GR IaC, 교육, 컨설팅 | $5K-$100K/년 |

### 4개 제품 시너지

```
진단(문제 발견) → 솔루션(문제 해결) → IaC(인프라 구축) → 교육(역량 강화) → 진단(반복)
```

---

## 부록: 파일 시스템 맵

```
GR_Project_v5/
├── README.md                          # AI 진입점, 프로젝트 개요
├── 01_masterplan/
│   └── GR_MASTERPLAN.md              # 본 문서 (비전, 철학, 전략)
├── 02_framework/
│   └── GR_3D_FRAMEWORK.md           # 3D 좌표 체계 완전 사양
├── 03_engine/
│   ├── engine_a/
│   │   └── ENGINE_A_SPEC.md          # Orchestrator 사양
│   └── engine_b/
│       ├── ENGINE_B_SPEC.md          # Atomizer Pipeline 사양
│       ├── GR_CLASSIFICATION_RULES.md # 결정론적 분류 규칙
│       ├── atom_schema.yaml          # Atom 스키마 v5.0
│       └── atom_tags.yaml            # 통제된 태그 어휘
├── 04_db/
│   ├── rawdata/                      # 원시 데이터 (Sigma, MITRE 등)
│   └── atomdata/                     # 원자화된 데이터
│       ├── INFRA/                    # 인프라 구성요소
│       ├── ATK/                      # 공격 기법
│       ├── DEF/                      # 방어 기법
│       ├── VUL/                      # 취약점
│       ├── TOOL/                     # 도구 지식
│       ├── COMP/                     # 컴플라이언스
│       ├── TECH/                     # 기술 개념
│       ├── ACTOR/                    # 위협 행위자
│       ├── MALWARE/                  # 악성코드
│       ├── DETECT/                   # 탐지 규칙
│       ├── PROTO/                    # 프로토콜
│       └── PRI/                      # 원칙/철학
├── 05_atlas/
│   └── GR_ATLAS_SPEC.md             # Atlas 시각화 사양
├── 06_business/
│   └── GR_BUSINESS.md               # 비즈니스 모델 상세
└── archive/                          # 이전 버전 참고 자료
```

---

*문서 버전: v5.0 | 최종 수정: 2026-02-06*
