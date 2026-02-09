# GR (Gotroot) Project v5.0

> **한 줄 요약**: 모든 IT 인프라 구성요소에 3D 좌표(Layer × Zone × Function)를 부여하고, 모든 보안 지식을 해당 좌표와 연결된 쿼리 가능한 그래프로 원자화하는 사이버보안 지식 온톨로지.

---

## GR이란?

GR은 **보안 지식 인프라**다 — 제품이 아니라, 다른 제품들이 그 위에 구축되는 기반(Foundation)이다.

**핵심 아이디어**: 보안 지식은 인프라 컨텍스트(WHERE)와 연결될 때만 의미가 있다. "SQL Injection은 위험하다"는 말은 "Z2 Service Zone의 L7 Application이 Z3 Data Zone의 L5 Data를 대상으로 쿼리할 때 발생한다"는 것을 알아야 비로소 실행 가능해진다.

**GR이 제공하는 것**:
1. **3D 좌표 체계**: 모든 인프라 구성요소에 좌표 부여 — Layer(배포 스택 위치), Zone(신뢰 경계), Function(기능 역할)
2. **지식 원자화**: 모든 IT/보안 지식을 자기 완결적인 최소 단위(atom)로 분해하여 구조화된 YAML로 저장
3. **지식 그래프**: atom 간 의미적으로 정확한 관계로 연결 — 공격 경로 분석, 정책 상속, 영향도 평가 가능
4. **좌표 기반 추론**: 동일 좌표 = 동일 보안 정책, 배포 환경과 무관

---

## AI Agent를 위한 안내

AI agent로서 GR 데이터를 다루는 경우, 다음 순서로 문서를 읽을 것:

1. **`03_engine/engine_b/GR_CLASSIFICATION_RULES.md`** — 결정론적 분류 규칙 (최우선 권한)
2. **`03_engine/engine_b/atom_schema.yaml`** — atom 데이터 구조
3. **`03_engine/engine_b/atom_tags.yaml`** — 통제된 태그 어휘
4. **`02_framework/00_overview.md`** — 3D 좌표 체계 개요 (Layer, Zone, Function 정의)
5. **`01_masterplan/GR_MASTERPLAN.md`** — 프로젝트 비전과 철학 (컨텍스트)

**Agent 필수 규칙**:
- `related_to` 관계는 **사용 금지** — 구체적인 관계 타입만 사용할 것
- `is_infrastructure`는 prefix로 결정: `INFRA-*` = true, 그 외 = false
- INFRA atom만 `gr_coordinates`를 가짐; 나머지는 `scope`를 가짐
- `function` 필드는 계층적 코드 사용 (예: `S1.2`), 단일 문자 사용 금지
- 역관계(inverse relation)는 저장하지 않음 — 쿼리 시 계산
- atom당 통제된 어휘에서 최소 2개의 `atom_tags` 필수

**Agent 불변 원칙** (절대 변경 금지):
- 3D 좌표 체계의 철학과 뼈대는 **명시적 지시 없이 변경 불가**
- **좌표가 먼저, 의미는 나중에** — 의미를 먼저 찾고 좌표를 만들려 하면 프레임워크가 왜곡됨
- AI가 논리적으로 보이는 파생 개념(거리 공식, 자동 정책 등)을 **임의로 추가하지 말 것**
- 기존 Layer/Zone/Function 정의를 임의로 수정하지 말 것
- 확장(새 사례, 상세화)은 권장하지만, 기존 구조를 깨는 변경은 금지

---

## 프로젝트 구조

```
GR_Project_v5/
│
├── README.md                              ← 현재 문서
│
├── 01_masterplan/
│   └── GR_MASTERPLAN.md                  # 비전, 철학, 온톨로지 개념,
│                                          # 생태계 아키텍처, 로드맵, 사업 개요
│
├── 02_framework/
│   ├── 00_overview.md                    # Framework 개요, 추론 규칙, 예시 (유일한 메인 문서)
│   ├── 01_vertical_layer/               # 차원 1: 배포 Layer (L0-L7+Cross)
│   │   ├── deployment_layers.md          #   Layer 정의 요약 (v5)
│   │   ├── 00_차원1_개요.md              #   차원 1 개요
│   │   └── Layer_*.md                    #   Layer별 개요 (10개 파일)
│   ├── 02_security_zone/                # 차원 2: Security Zone (Z0A-Z5)
│   │   ├── 00_차원2_개요.md              #   차원 2 개요
│   │   └── Zone_*.md                     #   Zone별 정의 (7개 파일)
│   ├── 03_function/                     # 차원 3: Function 코드 (10개 도메인)
│   │   ├── 00_차원3_개요.md              #   차원 3 개요
│   │   └── Domain_*.md                   #   도메인별 정의 (M,N,S,A,D,R,C,P,T,I)
│   └── taxonomy/                        # 기계 판독 가능한 정의
│       ├── layers.yaml                   #   Layer 분류 체계 (YAML)
│       ├── zones.yaml                    #   Zone 분류 체계 (YAML)
│       └── functions.yaml                #   Function 코드 분류 체계 (YAML)
│
├── 03_engine/
│   ├── engine_a/
│   │   └── ENGINE_A_SPEC.md              # Orchestrator: 3-DB 라우팅, 쿼리 API,
│   │                                      # 동기화 전략, 비용 인식 라우팅
│   └── engine_b/
│       ├── ENGINE_B_SPEC.md              # Atomizer: 4-Layer AI 파이프라인,
│       │                                  # 데이터 플라이휠, 멀티 에이전트 아키텍처
│       ├── GR_CLASSIFICATION_RULES.md    # 결정론적 12단계 분류 규칙,
│       │                                  # prefix-type 매핑, 관계 규칙
│       ├── atom_schema.yaml              # atom 데이터 구조 (identity, classification,
│       │                                  # coordinates, scope, definition, relations, metadata)
│       └── atom_tags.yaml                # 통제된 태그 어휘 (8개 카테고리, 120+ 태그)
│
├── 04_db/
│   ├── rawdata/                          # 원시 소스 데이터 (Sigma, MITRE, GTFOBins 등)
│   │   ├── structured/                   #   전처리된 구조화 데이터 (4,834개 파일)
│   │   └── vulnerability_catalog/        #   취약점 카탈로그 (CWE, OWASP, CVE 매핑)
│   ├── atom_data/                        # prefix별로 분류된 atom
│   │   ├── INFRA/                        #   인프라 구성요소
│   │   ├── ATK/                          #   공격 기법
│   │   ├── DEF/                          #   방어 기법
│   │   ├── VUL/                          #   취약점
│   │   ├── TOOL/                         #   도구 지식
│   │   ├── COMP/                         #   규정/컴플라이언스
│   │   ├── TECH/                         #   기술 개념
│   │   ├── ACTOR/                        #   위협 행위자
│   │   ├── MALWARE/                      #   악성 소프트웨어
│   │   ├── DETECT/                       #   탐지 규칙/시그니처
│   │   ├── PROTO/                        #   프로토콜
│   │   └── PRI/                          #   원칙/철학
│   └── schema/                           # 데이터베이스 스키마 정의 (SQL, ER 다이어그램)
│
├── 05_atlas/
│   └── GR_ATLAS_SPEC.md                 # 시각화 명세 ("Feature, not Product")
│                                          # 인터랙티브 인프라 보안 맵
│
├── 06_business/
│   └── GR_BUSINESS.md                   # 비즈니스 모델, 4개 제품 라인, 수익 전략
│
└── archive/                              # 이전 버전 참고 자료
```

---

## 핵심 개념 빠른 참조

| 개념 | 정의 |
|------|------|
| **Atom** | 최소 지식 단위 — 자기 완결적이며, 스키마를 준수하고, 고유하게 식별됨 |
| **3D 좌표** | (Layer, Zone, Function) — GR 공간에서 인프라의 위치 |
| **12 Prefix** | INFRA, ATK, DEF, VUL, TOOL, COMP, TECH, ACTOR, MALWARE, DETECT, PROTO, PRI |
| **11 Type** | 3개 인프라 (component, component_tool, component_control) + 8개 지식 타입 |
| **is_infrastructure** | 이진값: true (좌표 부여) 또는 false (scope 부여) |
| **Archetype** | 하나의 제품, 다수의 역할 — 각 역할은 고유 좌표를 가진 별도의 atom |
| **Engine A** | Orchestrator / "Librarian" — 3개 데이터베이스에 걸쳐 쿼리 라우팅 |
| **Engine B** | Atomizer — 원시 데이터를 분류된 atom으로 변환 |
| **GR Atlas** | 공유 시각화 컴포넌트 — 인프라를 인터랙티브 맵으로 표현 |
| **Foundation** | GR은 다른 제품의 기반이며, 독립 제품이 아님 |

---

## 3-DB 아키텍처

| 데이터베이스 | 용도 | 쿼리 유형 |
|-------------|------|----------|
| **PostgreSQL** | 마스터/SSOT — 모든 atom 데이터 | 정확한 조회, 구조화된 필터, 집계 |
| **Neo4j** | 그래프 엔진 — 관계 및 경로 | 공격 경로, 영향도 분석, 의존성 |
| **Pinecone** | 벡터 저장소 — 의미 검색 | 유사도 검색, RAG 쿼리 |

---

## 문서 버전 이력

| Version | Date | Changes |
|---------|------|---------|
| v5.0 | 2026-02-06 | 전면 재작성: 통합 파일 시스템, 모순 해결, 12-prefix 체계, 결정론적 분류 규칙 |
| v4.0 | — | Agent 중심 시대: 결정론적 분류 중심 |
| v3.x | — | 통합 시대: 스키마 혁신, is_infrastructure 이진화 |
| v2.0 | — | 스키마 시대: 최초 작동 코드, 파이프라인 설계 |
| v1.0 | — | 비전 시대: 철학, 3D 좌표 개념 탄생 |

---

*Document Version: v5.0 | Last Updated: 2026-02-06*
