# GR Atlas 사양서 v5.0

> **"기능이지, 제품이 아니다"** — GR Atlas는 독립형 제품이 아니라, 모든 GR 기반 제품에 내장되는 공유 시각화 컴포넌트이다.

---

## 1. 개요

GR Atlas는 GR Ontology에 대한 **시각적 인터페이스**이다. 인프라를 인터랙티브 맵으로 렌더링하며, 구성은 다음과 같다:
- **X축**은 Security Zone을 나타낸다 (Z0A → Z5)
- **Y축**은 Deployment Layer를 나타낸다 (L0 → L7)
- **Node**는 3D 좌표에 배치된 인프라 atom이다
- **Edge**는 atom 간의 관계이다 (공격 경로, 의존성, 방어)

### 핵심 원칙

Atlas는 데이터를 생성하거나 해석하지 않는다 — Engine A가 제공하는 것을 **시각화**한다. Atlas는 데이터 계층이 아니라 렌더링 계층이다.

```
Engine A (data) → Atlas (visualization) → User (interaction) → Engine A (queries)
```

---

## 2. 시각적 아키텍처

### 2.1 Grid 레이아웃

```
        Z0A    Z0B    Z1     Z2     Z3     Z4     Z5
       (Ext)  (Part) (Peri) (Svc)  (Data) (Mgmt) (End)
  L7  │      │      │ Web  │ API  │      │      │ Laptop│
  L6  │      │      │      │ K8s  │      │      │      │
  L5  │      │      │      │      │ PgSQL│      │      │
  L4  │      │      │      │      │      │Jenkins│      │
  L3  │      │      │ EC2  │      │      │      │      │
  L2  │      │      │ ALB  │ Kong │      │      │      │
  L1  │      │      │      │      │      │ Rack │      │
  L0  │ User │ API  │      │      │      │      │      │
Cross │      │      │      │      │      │Grafana│      │
```

### 2.2 Node 표현

각 인프라 atom은 해당 좌표에 node로 렌더링된다:

| Node 유형 | 시각적 표현 | 색상 |
|-----------|------------|------|
| `component` | 원형 | 파란색 |
| `component_tool` | 다이아몬드 | 초록색 |
| `component_control` | 방패 | 주황색 |

Node 크기는 관계 수에 비례한다 (연결이 많을수록 크게 표시).

### 2.3 Edge 표현

atom 간의 관계는 방향성 edge로 렌더링된다:

| 관계 범주 | 선 스타일 | 색상 |
|----------|----------|------|
| 구조적 (is_a, part_of) | 실선 | 회색 |
| 인과적 (causes, enables) | 실선 | 빨간색 |
| 방지 (prevents) | 점선 | 초록색 |
| 의존성 (requires) | 점선(dotted) | 파란색 |
| 공격 흐름 | 두꺼운 애니메이션 | 빨간색 펄스 |
| 방어 체인 | 두꺼운 애니메이션 | 초록색 펄스 |

---

## 3. 인터랙티브 기능

### 3.1 Zoom 단계

| 단계 | 뷰 | 표시 내용 |
|------|-----|----------|
| **Overview** | 전체 grid | Zone/Layer 경계, node 클러스터, 상위 수준 흐름 |
| **Zone** | 단일 zone 상세 | zone 내 모든 atom, zone 간 연결 |
| **Component** | 단일 atom 상세 | 전체 atom 정보, 모든 관계, 보안 프로필 |

### 3.2 Overlay

사용자는 시각화 overlay를 토글할 수 있다:

| Overlay | 표시 내용 | 활용 사례 |
|---------|----------|----------|
| **Attack Paths** | Z0A에서 내부 zone으로 향하는 빨간색 흐름 | 위협 시각화 |
| **Defense Coverage** | 보호되는 컴포넌트에 표시되는 초록색 방패 | 보안 공백 분석 |
| **Vulnerability Heat** | CVSS 점수 밀도 기반 히트맵 | 위험 우선순위 지정 |
| **Trust Boundaries** | 신뢰 비율(%)이 표시된 zone 경계선 | 아키텍처 검토 |
| **Data Flow** | 데이터 이동을 나타내는 방향 화살표 | 컴플라이언스 감사 |
| **Blast Radius** | 침해 시 영향받는 atom 강조 표시 | 인시던트 대응 |

### 3.3 인터랙션 모드

| 모드 | 동작 | 결과 |
|------|------|------|
| **Explore** | node 클릭 | atom 상세 정보, 관계, 보안 프로필 표시 |
| **Trace** | 두 node 클릭 | 두 node 간 모든 경로 표시 |
| **Simulate** | node에서 "침해" 선택 | blast radius 표시 (영향 분석) |
| **Compare** | 두 배포 환경 선택 | 좌표 비교를 나란히 표시 |
| **Filter** | 태그, 유형 또는 좌표 선택 | 일치하는 atom 강조, 나머지 흐리게 표시 |

---

## 4. 데이터 통합

### 4.1 Atlas API 요구사항 (Engine A 기반)

Atlas는 다음 Engine A endpoint를 사용한다:

```
GET /api/v1/coordinates/{layer}/{zone}    # Atoms at coordinates
GET /api/v1/atoms/{id}/relations          # Atom relations
GET /api/v1/graph/path?from=...&to=...   # Path between atoms
GET /api/v1/graph/impact/{id}             # Impact/blast radius
GET /api/v1/atoms?type=...&tags=...      # Filtered atom list
GET /api/v1/stats                         # Coverage statistics
```

### 4.2 실시간 vs. 정적

| 모드 | 데이터 소스 | 갱신 주기 | 활용 사례 |
|------|-----------|----------|----------|
| **Static** | Engine A의 캐시된 스냅샷 | 수동 새로고침 | 문서화, 보고서 |
| **Live** | Engine A API 직접 호출 | 실시간 | 능동적 모니터링, 인시던트 대응 |

---

## 5. 활용 사례

### 5.1 보안 아키텍처 검토
1. Overview 수준에서 인프라 맵 로드
2. Trust Boundaries overlay 토글
3. 예상 외 zone에 위치한 컴포넌트 식별
4. 드릴다운하여 좌표 할당 확인

### 5.2 신규 제품 통합
1. 맵에 새 컴포넌트 추가 (좌표 할당)
2. 동일 좌표의 기존 컴포넌트 확인
3. 인접 컴포넌트로부터 보안 정책 자동 상속
4. 새로운 데이터 흐름 및 의존성 시각화

### 5.3 CVE 영향 분석
1. 특정 컴포넌트에 대한 CVE 알림 수신
2. Atlas에서 해당 atom 선택
3. Blast Radius overlay 토글
4. 영향받는 모든 하위 컴포넌트 확인
5. Zone 신뢰 수준에 따라 조치 우선순위 결정

### 5.4 컴플라이언스 감사
1. Data Flow overlay 토글
2. Z3 (Data)에서 Z0B (Partner)까지 민감 데이터 추적
3. 각 경계에서 암호화 및 접근 제어 검증
4. 컴플라이언스 증빙 보고서 생성

### 5.5 인시던트 대응
1. 침해된 컴포넌트 식별
2. 침해 시뮬레이션 → blast radius 확인
3. 침해 node에서 핵심 자산(Z3, Z4)까지의 모든 경로 식별
4. 식별된 경로 차단을 통한 격리 계획 수립

---

## 6. 임베딩 전략

Atlas는 공유 컴포넌트로서 GR 기반 제품에 내장된다:

| 제품 | Atlas 활용 |
|------|-----------|
| **GR Diagnosis** | 인프라 맵에 취약점 위치 표시 |
| **GR IaC** | Infrastructure-as-Code 토폴로지 시각화 |
| **GR Education** | 실제 아키텍처 예시를 활용한 인터랙티브 학습 |
| **GR Consulting** | 고객 인프라 평가 시각화 |

각 제품은 자체 데이터 컨텍스트를 Atlas에 전달한다. Atlas는 제품별 overlay와 인터랙션을 적용하여 동일한 grid를 렌더링한다.

---

## 7. 기술 고려사항

### Frontend
- 인터랙티브 grid: Canvas 기반 (1000개 이상 node에서 성능 우수) 또는 SVG (소규모 배포용)
- Framework 비의존적: React, Vue 또는 바닐라 HTML에 내장 가능
- 반응형: 데스크톱 (주 대상) 및 태블릿 (보조 대상) 지원

### 성능 목표
- 초기 렌더링: 500개 node 기준 2초 미만
- Pan/Zoom: 60fps
- Node 클릭 응답: 100ms 미만
- 경로 계산 표시: 500ms 미만

---

*Document Version: v5.0 | Last Updated: 2026-02-06*
