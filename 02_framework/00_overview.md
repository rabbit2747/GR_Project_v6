# GR 3D 분류 체계 — 개요 v5.0

> 모든 인프라 구성요소는 3차원 공간에서 고유한 위치를 차지한다: **Layer (수직 스택) × Zone (수평 신뢰 경계) × Function (기능 역할)**.

---

## 1. 3D Coordinate 체계

GR 3D Framework는 모든 IT 인프라 구성요소에 세 가지 차원에 걸쳐 coordinates를 부여한다:

| 차원 | 축 | 답변하는 질문 | 값 | 정의 위치 |
|------|-----|-------------|-----|----------|
| **Layer** | 수직 | 기술 스택에서 어디에 위치하는가? | L0–L7 + Cross-Layer | `01_vertical_layer/` |
| **Zone** | 수평 | 어떤 신뢰 경계에 속하는가? | Z0A, Z0B, Z1–Z5 | `02_security_zone/` |
| **Function** | 기능 | 어떤 기능을 제공하는가? | 10개 도메인, 280+ 코드 | `03_function/` |

**핵심 불변 원칙**: 동일 coordinates → 동일 보안 정책 적용 (AWS, Azure, 온프레미스, 하이브리드 등 배포 환경에 관계없이).

**기계 판독 가능 정의**: `taxonomy/` 디렉터리에 프로그래밍 방식으로 접근 가능한 YAML 파일 포함.

---

## 2. 좌표화의 핵심 속성

### 2.1 배포 독립성

동일한 논리적 구성요소는 배포 환경에 관계없이 **동일한 coordinates**를 부여받는다:

| 배포 환경 | PostgreSQL Coordinates | 보안 정책 |
|----------|----------------------|----------|
| AWS RDS | L5, Z3, D1.3 | **동일** |
| Azure Database | L5, Z3, D1.3 | **동일** |
| 온프레미스 서버 | L5, Z3, D1.3 | **동일** |
| GCP Cloud SQL | L5, Z3, D1.3 | **동일** |

배포 플랫폼은 3D coordinate의 일부가 아니라 `atom_tags`의 `platform` 속성으로 기록된다.

### 2.2 Archetype 기반 다중 Coordinate 할당

단일 제품이 Archetype 모델을 통해 3D 공간에서 여러 위치를 점유할 수 있다:

**예시: Redis**
| Archetype | Layer | Zone | Function | 보안 프로필 |
|-----------|-------|------|----------|------------|
| Key-Value Store | L5 | Z3 | D1.1 | 데이터 암호화, 백업, 접근 제어 |
| In-Memory Cache | L6 | Z2 | D2.1 | 세션 타임아웃, 캐시 무효화 |
| Session Store | L5 | Z3 | D1.1 | 세션 암호화, PII 보호 |
| Message Broker | L6 | Z2 | D3.1 | 메시지 무결성, 큐 보안 |

각 archetype은 고유한 ID, coordinates, 보안 정책을 가진 **별도의 atom**이다.

---

## 3. Coordinate 예시

### 3.1 E-Commerce 아키텍처 매핑

| 구성요소 | Layer | Zone | Function | 주요 정책 |
|---------|-------|------|----------|----------|
| Cloudflare CDN | L2 | Z1 | D2.2 | DDoS, WAF, Bot Detection |
| ALB (Public) | L2 | Z1 | N1.2 | TLS Termination, Rate Limit |
| API Gateway (Kong) | L2 | Z2 | A1.2 | JWT Validation, Rate Limit |
| Backend API (Node.js) | L7 | Z2 | A1.5 | Input Validation, AuthZ |
| Redis Cache | L6 | Z2 | D2.1 | Session Timeout, No PII |
| PostgreSQL | L5 | Z3 | D1.3 | TDE, Query Audit, Backup |
| Elasticsearch | L5 | Z3 | D5.3 | Index ACL, Audit Log |
| Jenkins CI/CD | L4 | Z4 | P1.1 | Pipeline Security, MFA |
| Vault | Cross | Z4 | P3.1 | HSM Backend, Audit |
| Grafana | Cross | Z4 | M2.2 | SSO, Read-only Default |
| Employee Laptop | L7 | Z5 | — | EDR, MDM, Zero Trust |

**자동 생성 정책 수**: 약 156개 (Layer 42개 + Zone 58개 + 경계 36개 + 제품별 20개)

---

## 4. 확장성과 불변 원칙

### 4.1 불변 (변경 불가)

다음은 프레임워크의 **철학과 뼈대**이며, 명시적 결정 없이는 절대 변경되지 않는다:

- **3차원 좌표 체계 자체**: Layer × Zone × Function 3개 차원 구조
- **Layer 정의** (L0–L7 + Cross) — 변경 시 주요 버전 업그레이드 필요
- **Zone 정의** (Z0A–Z5) — 변경 시 주요 버전 업그레이드 필요
- **기존 Function 코드** — 한번 할당되면 코드의 의미는 절대 변경되지 않음
- **좌표화 우선 원칙**: 좌표가 먼저, 의미/정책은 나중에
- **12-Prefix ID 체계**: INFRA, ATK, DEF, VUL, TOOL, COMP, TECH, ACTOR, MALWARE, DETECT, PROTO, PRI
- **is_infrastructure 이진 분류**: prefix로 결정 (INFRA-* = true)

### 4.2 확장 가능 (지속적 구체화)

다음은 **재귀적으로 계속 확장·구체화**해야 하는 영역이다:

- **Function 코드**: 부 버전에서 새 코드 추가 가능
- **각 차원의 설명·특성·구성요소·위협 모델**: 실제 인프라를 분류하면서 지속적으로 상세화
- **경계 사례 판단 가이드**: 새로운 모호한 사례가 발견될 때마다 추가
- **Zone 경계 통제 상세**: 새로운 통제 메커니즘이 등장할 때마다 보강
- **Taxonomy YAML**: 마크다운 문서의 확장에 맞추어 동기화
- **Atom 데이터**: 30,000 atom 목표까지 지속 축적

### 4.3 확장 원칙

```
현재 상태 = 뼈대 + 철학 (완성본이 아님)

확장 방향:
  1. 새 구성요소 좌표화 → 모호한 사례 발견 → 판단 가이드 추가
  2. 판단 가이드 추가 → 분류 규칙 정밀화 → Taxonomy 업데이트
  3. Taxonomy 업데이트 → 새 Atom 생성 시 활용 → 새로운 경계 사례 발견
  → 1번으로 돌아감 (재귀적 반복)

제약:
  - 확장 시 기존 철학/뼈대(4.1)를 절대 위반하지 않을 것
  - 새 개념 추가 시 기존 좌표 체계와 충돌하지 않을 것
  - AI가 파생 개념(거리 공식 등)을 임의로 추가하지 않을 것
```

---

## 5. 디렉터리 구조

```
02_framework/
├── 00_overview.md                    ← 현재 파일 (총론, 추론 규칙, 유일한 메인 문서)
├── 01_vertical_layer/               # 차원 1: 배포 Layer
│   ├── deployment_layers.md          #   L0–L7 + Cross-Layer 정의 (v5 요약)
│   ├── 00_차원1_개요.md              #   차원 1 상세 개요
│   └── Layer_*.md                    #   Layer별 개요 파일 (10개)
├── 02_security_zone/                # 차원 2: Security Zone
│   ├── 00_차원2_개요.md              #   차원 2 상세 개요
│   └── Zone_*.md                     #   Zone별 정의 파일 (7개)
├── 03_function/                     # 차원 3: Function 코드
│   ├── 00_차원3_개요.md              #   차원 3 상세 개요
│   └── Domain_*.md                   #   10개 도메인 정의 (M,N,S,A,D,R,C,P,T,I)
└── taxonomy/                        # 기계 판독 가능한 정의
    ├── layers.yaml                   #   Layer 분류 체계 (YAML)
    ├── zones.yaml                    #   Zone 분류 체계 (YAML)
    └── functions.yaml                #   Function 코드 계층 (YAML)
```

---

*Document Version: v5.0 | Last Updated: 2026-02-06*
