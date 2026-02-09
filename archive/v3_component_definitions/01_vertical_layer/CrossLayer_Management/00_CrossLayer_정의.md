# Cross-Layer: Management & Security (관리 및 보안)

## 📋 Layer 정보

| 속성 | 값 |
|------|-----|
| **Layer 번호** | Cross-Layer |
| **한글명** | 관리 및 보안 |
| **영문명** | Management & Security |
| **특성** | 모든 Layer에 적용되는 횡단 관심사 |
| **복잡도** | High |

---

## 🎯 정의

Cross-Layer는 **모든 인프라 계층에 걸쳐 적용되는 관리 및 보안 기능**을 제공합니다.

---

## 🏗️ 주요 구성요소

| 번호 | 구성요소 | 설명 | 문서 링크 |
|------|---------|------|-----------|
| 1 | **Monitoring** | 모니터링 및 가시성 | [상세 문서](01_Monitoring/00_Monitoring_정의.md) |
| 2 | **IAM** | 신원 및 접근 관리 | [상세 문서](02_IAM/00_IAM_정의.md) |
| 3 | **Secrets Management** | 비밀 정보 관리 | [상세 문서](03_Secrets_Management/00_Secrets_Management_정의.md) |
| 4 | **SIEM** | 보안 정보 및 이벤트 관리 | [상세 문서](04_SIEM/00_SIEM_정의.md) |
| 5 | **ITSM** | IT 서비스 관리 | [상세 문서](05_ITSM/00_ITSM_정의.md) |
| 6 | **Testing** | 테스트 및 품질 보증 | [상세 문서](06_Testing/00_Testing_정의.md) |

---

## 🔒 Zone별 배치 개요

| Zone | 배치 빈도 | 주요 구성요소 |
|------|----------|------------------|
| **Zone 0** | Common | Secrets Management, IAM |
| **Zone 1-4** | Very Common | Monitoring, SIEM |
| **All Zones** | Very Common | Testing |

---

## 📊 Cross-Layer 통합 패턴

```yaml
Observability (관찰성):
  - Monitoring: 메트릭 수집
  - Logging: 로그 수집 및 분석
  - Tracing: 분산 추적

Security (보안):
  - IAM: 인증 및 인가
  - Secrets: 비밀 정보 보호
  - SIEM: 보안 이벤트 감지

Operations (운영):
  - ITSM: 티켓 및 변경 관리
  - Testing: 품질 보증
  - Automation: 자동화 워크플로우
```

---

## 🌐 수평 기능 배치 결정 트리

### 의사결정 프레임워크

Cross-Layer 구성요소를 배치할 때 다음 4가지 질문에 순차적으로 답하세요:

#### 1단계: 역할 (Role) 파악

**질문**: "이 구성요소의 주된 역할은 무엇인가?"

```yaml
관찰/감시 (Observe):
  - 시스템 상태 모니터링
  - 보안 이벤트 탐지
  - 성능 메트릭 수집
  → Monitoring, SIEM

접근 제어 (Control):
  - 인증 및 인가
  - 비밀 정보 관리
  - 정책 집행
  → IAM, Secrets Management

운영 지원 (Support):
  - 티켓 관리
  - 품질 보증
  - 변경 관리
  → ITSM, Testing
```

#### 2단계: 제공 범위 (Scope) 결정

**질문**: "몇 개 Layer에 서비스를 제공하는가?"

```yaml
All Layers (전체):
  - 모든 계층에 영향
  - 범용 기능
  → Cross-Layer 분류 확정

특정 Layer만 (부분):
  - 1-2개 Layer 집중
  - 전문화된 기능
  → 해당 Layer에 배치

2-3개 Layer (중간):
  - 가장 의존도 높은 Layer 선택
  - 또는 Cross-Layer로 분류
  → 사용 빈도로 결정
```

#### 3단계: 적용 대상 (Target) 식별

**질문**: "어디에 Agent/Client/Module을 배포하는가?"

```yaml
모든 곳 (Everywhere):
  - 모든 Zone에 Agent 배포
  - 전방위 데이터 수집
  → Monitoring Agent, SIEM Forwarder

중앙 집중 (Centralized):
  - Zone 0에만 서버 배포
  - 클라이언트는 API 호출
  → IAM Server, Vault Server

특정 Zone (Targeted):
  - 특정 Zone에 집중 배포
  - 용도에 따른 선택적 배치
  → Testing (Zone 2, 3 주력)
```

#### 4단계: 지배 영역 (Domain) 확인

**질문**: "데이터/정책을 어디서 관리하는가?"

```yaml
중앙 집중형 (Centralized):
  - 정책을 중앙에서 단일 관리
  - 일관성 우선
  → Zone 0 배치
  → IAM, Secrets, SIEM

분산형 (Distributed):
  - 각 Zone에서 독립 관리
  - 자율성 우선
  → 해당 Zone 배치
  → Testing (팀별)

하이브리드 (Hybrid):
  - 정책은 중앙, 실행은 분산
  - 확장성 + 일관성
  → Cross-Layer
  → Monitoring
```

---

### 결정 매트릭스

| 구성요소 | 역할 | 범위 | 적용 대상 | 지배 영역 | 최종 배치 |
|---------|------|------|----------|----------|----------|
| **Monitoring** | 관찰/감시 | All Layers | All Zones (Agent) | 하이브리드 | Cross-Layer + Zone 0 Server |
| **IAM** | 접근 제어 | All Layers | All Zones (Client) | 중앙 집중 | Cross-Layer + Zone 0 Server |
| **Secrets** | 접근 제어 | Layer 4-7 | Zone 2-3 (Client) | 중앙 집중 | Cross-Layer + Zone 0 Vault |
| **SIEM** | 관찰/감시 | All Layers | All Zones (Agent) | 중앙 집중 | Cross-Layer + Zone 0 Server |
| **ITSM** | 운영 지원 | All Layers | Zone 0-4 (User) | 중앙 집중 | Cross-Layer + Zone 0 Platform |
| **Testing** | 운영 지원 | Layer 7 집중 | Zone 2-3 (Runner) | 분산 | Cross-Layer + Zone 2 주 배치 |

---

### 배치 패턴

#### 패턴 1: Hub-Spoke (중앙 집중형)

```yaml
구조:
  중앙: Zone 0에 단일 서버
  분산: All Zones에 Agent 배포

데이터 흐름:
  Agent → 중앙 Server (단방향)

적용 구성요소:
  - Monitoring: Prometheus Server (Zone 0) + Node Exporter (All)
  - SIEM: Splunk Server (Zone 0) + Forwarder (All)
  - IAM: Keycloak (Zone 0) + Client Library (All)

장점:
  - 중앙 집중 관리 용이
  - 정책 일관성 보장
  - 단순한 구조

단점:
  - 중앙 서버가 SPOF (Single Point of Failure)
  - 확장성 제한
  - 네트워크 의존도 높음

배치 예시:
  Zone 0: [Central Server] ← ← ←
  Zone 1: [Agent]            ↑
  Zone 2: [Agent]            ↑
  Zone 3: [Agent]            ↑
```

#### 패턴 2: Federated (연합형)

```yaml
구조:
  로컬: 각 Zone별 로컬 서버
  중앙: Zone 0에 집계 서버

데이터 흐름:
  Agent → 로컬 Server → 중앙 Server (계층적)

적용 구성요소:
  - Monitoring: Zone별 Prometheus + 중앙 Thanos
  - SIEM: Zone별 로컬 SIEM + 중앙 SIEM

장점:
  - 확장성 우수
  - 로컬 장애가 전체에 영향 없음
  - 네트워크 트래픽 감소

단점:
  - 복잡도 증가
  - 데이터 동기화 필요
  - 관리 오버헤드

배치 예시:
  Zone 0: [Central Aggregator] ← ← ←
  Zone 1: [Local Server] ← [Agent] ↑
  Zone 2: [Local Server] ← [Agent] ↑
  Zone 3: [Local Server] ← [Agent] ↑
```

#### 패턴 3: Distributed (완전 분산형)

```yaml
구조:
  중앙 서버 없음
  각 Zone/팀별 독립 운영

데이터 흐름:
  로컬에서 완결 (P2P 가능)

적용 구성요소:
  - Testing: 각 팀별 독립 CI/CD
  - 일부 Monitoring: 팀별 독립

장점:
  - 완전한 독립성
  - 유연성 극대
  - SPOF 없음

단점:
  - 일관성 유지 어려움
  - 전체 가시성 부족
  - 중복 투자

배치 예시:
  Zone 1: [Standalone]
  Zone 2: [Standalone]
  Zone 3: [Standalone]
  (서로 독립)
```

---

### 실전 예시

#### 예시 1: 새로운 "API Rate Limiting" 추가 시

```yaml
1단계 - 역할:
  - 트래픽 제어 (Control)
  - 보안 통제 성격

2단계 - 범위:
  - Layer 2 (Network) 주력
  - Layer 7 (API Gateway) 보조

3단계 - 적용 대상:
  - Zone 1 (Perimeter) 집중

4단계 - 지배 영역:
  - 분산 (각 API별 개별 설정)

결정: Layer 2에 배치
이유: 특정 Layer 집중, Cross-Layer 아님
```

#### 예시 2: "Configuration Management" 추가 시

```yaml
1단계 - 역할:
  - 설정 관리 (Support)

2단계 - 범위:
  - All Layers (모든 구성요소 설정 관리)

3단계 - 적용 대상:
  - All Zones (모든 곳에서 설정 읽기)

4단계 - 지배 영역:
  - 중앙 집중 (Config Server in Zone 0)

결정: Cross-Layer 배치 + Hub-Spoke 패턴
이유: 범용 기능, 중앙 관리 필요
```

#### 예시 3: "Database Backup" 배치 시

```yaml
1단계 - 역할:
  - 운영 지원 (Support - Backup)

2단계 - 범위:
  - Layer 5 (Data) 전용

3단계 - 적용 대상:
  - Zone 3 (Data Zone)만

4단계 - 지배 영역:
  - 분산 (각 DB별 개별 백업)

결정: Layer 5에 배치
이유: 특정 Layer 전용, Cross-Layer 아님
기존 분류: Layer_5_Data/06_Backup/ ✓
```

---

### 배치 결정 플로우차트

```
새로운 구성요소 추가
        ↓
┌─────────────────────┐
│ 모든 Layer에 영향?  │
└─────────────────────┘
    Yes ↓        No →  특정 Layer 배치
        ↓
┌─────────────────────┐
│ 모든 Zone에 배포?   │
└─────────────────────┘
    Yes ↓        No →  범위 재검토
        ↓
┌─────────────────────┐
│ 중앙 정책 관리?     │
└─────────────────────┘
    Yes ↓        No → Distributed 패턴
        ↓
┌─────────────────────┐
│ 로컬 서버 필요?     │
└─────────────────────┘
    Yes ↓        No → Hub-Spoke 패턴
        ↓
   Federated 패턴
```

---

## 🔗 관련 문서

- [Layer 7: Application](../Layer_7_Application/00_Layer_7_정의.md)
- [Layer 6: Runtime](../Layer_6_Runtime/00_Layer_6_정의.md)

---

**문서 끝**
