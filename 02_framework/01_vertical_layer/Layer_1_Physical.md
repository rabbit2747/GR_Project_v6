# Layer 1: Physical Infrastructure (물리 인프라)

## 📋 문서 정보

**Layer**: 1 - Physical Infrastructure
**영문명**: Physical Infrastructure
**한글명**: 물리 인프라
**위치**: 최하단 계층
**목적**: 물리적 하드웨어 및 데이터센터 시설 관리
**작성일**: 2025-01-20

---

## 🎯 Layer 정의

### 개요

**Layer 1 (Physical Infrastructure)**는 모든 IT 시스템의 **물리적 기반**을 제공하는 최하단 계층입니다.

### 핵심 개념

```yaml
핵심 특징:
  - 물리적 하드웨어 및 시설
  - 데이터센터 인프라
  - 전원, 냉각, 네트워크 케이블링
  - 변경 빈도가 가장 낮음 (년 단위)

통제 수준: 완전 (100%)
  - 온프레미스: 직접 소유 및 관리
  - 코로케이션: 공간 임대, 장비 소유
  - 클라우드: 추상화됨 (AWS, Azure, GCP가 관리)
```

---

## 📦 Physical Infrastructure 구성요소

### 1. Data Center (데이터센터)

**정의**: 서버 및 네트워크 장비를 수용하는 물리적 시설

**분류**:
```yaml
Tier 등급 (Uptime Institute):
  Tier 1: 99.671% (28.8시간/년 다운타임)
  Tier 2: 99.741% (22시간/년 다운타임)
  Tier 3: 99.982% (1.6시간/년 다운타임) - 일반적 선택
  Tier 4: 99.995% (26.3분/년 다운타임) - 미션 크리티컬
```

**대표 시설**:
```yaml
글로벌:
  - Equinix (글로벌 코로케이션)
  - Digital Realty
  - AWS Data Centers (us-east-1, ap-northeast-2)
  - Azure Data Centers
  - GCP Data Centers

한국:
  - LG CNS 상암 데이터센터
  - KT 목동 IDC
  - NHN 춘천 각 데이터센터
```

**Function Tags**:
- Primary: `R1.1` (Data Center Facility)
- Secondary: `S3.1` (Physical Security - 출입 통제)

**Zone 배치**: Layer 1은 Zone 분류 대상 아님 (물리적 위치)

---

### 2. Server Hardware (서버 하드웨어)

**정의**: 컴퓨팅 리소스를 제공하는 물리적 서버

**유형**:
```yaml
Rack Server:
  - Dell PowerEdge R740, R750
  - HP ProLiant DL380 Gen10
  - Cisco UCS C-Series

Blade Server:
  - HP BladeSystem
  - Dell PowerEdge M-Series
  - IBM Flex System

Tower Server:
  - 소규모 환경용
  - 예: Dell PowerEdge T-Series
```

**Function Tags**:
- Primary: `R1.2` (Physical Server)
- Tech Stack: `T3.1` (x86 Architecture), `T3.2` (ARM Architecture)

**Zone 배치**: 물리적 위치 (Data Center)

---

### 3. Storage Hardware (스토리지 하드웨어)

**정의**: 데이터 저장을 위한 물리적 스토리지 시스템

**유형**:
```yaml
SAN (Storage Area Network):
  - EMC Unity, VNX
  - NetApp FAS/AFF
  - Pure Storage FlashArray

NAS (Network Attached Storage):
  - Synology, QNAP
  - NetApp FAS

Direct-Attached Storage (DAS):
  - 서버에 직접 연결된 스토리지
```

**Function Tags**:
- Primary: `D4.1` (Block Storage), `D4.2` (File Storage)

**Zone 배치**: 물리적 위치 (Data Center)

---

### 4. Network Equipment (네트워크 장비)

**정의**: 물리적 네트워크 연결을 제공하는 하드웨어

**유형**:
```yaml
Core Router:
  - Cisco ASR, Nexus Series
  - Juniper MX Series

Core Switch:
  - Cisco Catalyst 9000 Series
  - Arista 7000 Series

광케이블 & 구리 케이블:
  - Fiber Optic (Single-mode, Multi-mode)
  - Cat6, Cat6a 이더넷 케이블
```

**Function Tags**:
- Primary: `N2.1` (Physical Networking)
- Interface: `I2.1` (Ethernet), `I2.2` (Fiber Optic)

---

### 5. Power & Cooling (전원 & 냉각)

**정의**: 데이터센터 전력 공급 및 냉각 시스템

**전원 시스템**:
```yaml
UPS (Uninterruptible Power Supply):
  - APC Symmetra, Smart-UPS
  - Eaton 9PX, 93PM
  - 용량: 5kVA ~ 500kVA

PDU (Power Distribution Unit):
  - Rack-mount PDU
  - Monitored PDU (전력 사용량 모니터링)

발전기:
  - Diesel Generator (장기 정전 대비)
  - 자동 전환 스위치 (ATS)
```

**냉각 시스템**:
```yaml
CRAC (Computer Room Air Conditioning):
  - Precision Cooling Units
  - 목표 온도: 18-27°C

Hot Aisle / Cold Aisle:
  - 효율적 공기 흐름 관리
  - 냉각 효율 최대화
```

**Function Tags**:
- Primary: `R2.1` (Power Supply), `R2.2` (Cooling System)

---

## 🔒 Security Zone 분류

**Layer 1은 물리적 위치**이므로 전통적 Zone 분류 대상이 아닙니다.

대신 **Physical Security** 적용:
```yaml
출입 통제:
  - Biometric Access (지문, 홍채)
  - 2-Factor Authentication (카드 + PIN)
  - Man-trap (이중 잠금 구역)

감시:
  - CCTV 24/7 모니터링
  - Motion Detector
  - 침입 경보 시스템
```

---

## 🛡️ 보안 고려사항

### 1. 물리적 보안

```yaml
출입 통제:
  - 승인된 인원만 접근 가능
  - 방문자 로그 기록
  - Escort Policy (동반자 필수)

환경 감시:
  - 온도, 습도 모니터링
  - 화재 감지 및 소화 시스템
  - 수해 감지 시스템
```

### 2. 재해 복구

```yaml
백업 전략:
  - 이중화된 전원 공급 (UPS + Generator)
  - 지리적 분산 (Multi-Region)
  - 정기 재해 복구 훈련

사고 대응:
  - 화재: 가스 소화 시스템 (FM-200, Inergen)
  - 정전: UPS → Generator 자동 전환 (<30초)
  - 침수: 누수 감지 센서 + 배수 펌프
```

---

## 📊 실전 예시

### 예시 1: 온프레미스 데이터센터

```yaml
시나리오: 금융사 자체 데이터센터

Layer 1 (Physical):
  Data Center:
    - Tier 3 인증 시설
    - 서울 및 부산 이중화

  Server:
    - Dell PowerEdge R750 × 50대
    - HP ProLiant DL380 Gen10 × 30대

  Storage:
    - NetApp AFF A700 (All-Flash)
    - 용량: 500TB (Raw)

  Network:
    - Cisco Nexus 9000 (Core Switch)
    - Fiber Optic 100Gbps

  Power:
    - UPS: 500kVA × 2 (이중화)
    - Generator: 1,000kVA (디젤)

  Cooling:
    - CRAC Unit × 4 (N+1 이중화)
    - Hot Aisle Containment

Zone 배치: 물리적 위치 (서울, 부산)
```

### 예시 2: 클라우드 (추상화됨)

```yaml
시나리오: AWS 기반 스타트업

Layer 1 (Physical):
  - AWS가 관리 (사용자 불가시)
  - us-east-1, ap-northeast-2 Region 선택

Layer 3 (Compute):
  - EC2 인스턴스 사용 (Layer 1 추상화)
  - t3.medium, m5.large 등

통제 수준:
  - Layer 1: AWS 완전 통제 (우리는 선택 불가)
  - Layer 3+: 우리가 관리
```

---

## 🔗 Layer 간 통신

### Layer 1 → Layer 2

```yaml
물리적 연결:
  Server Hardware (Layer 1)
    ↓ 네트워크 케이블
  Network Switch (Layer 2)
```

### Layer 1 → Layer 3

```yaml
가상화:
  Physical Server (Layer 1)
    ↓ Hypervisor 설치
  Virtual Machine (Layer 3)
```

---

## ✅ 체크리스트

### 온프레미스 환경

- [ ] Data Center Tier 등급 확인
- [ ] 서버 하드웨어 사양 및 수량 파악
- [ ] 스토리지 용량 및 백업 전략
- [ ] 전원 이중화 (UPS + Generator)
- [ ] 냉각 시스템 N+1 이중화
- [ ] 물리적 보안 (출입 통제, CCTV)

### 클라우드 환경

- [ ] Region 선택 (지리적 이중화)
- [ ] Availability Zone 분산
- [ ] AWS/Azure/GCP Data Center 위치 확인

---

## 🔗 관련 문서

- [차원 1: Deployment Layer 개요](00_차원1_개요.md)
- [Layer 2: Network Infrastructure](Layer_2_Network.md)
- [Layer 3: Computing Infrastructure](Layer_3_Computing.md)

---

## 📞 변경 이력

**v1.0 (2025-01-20)** - 초기 작성:
- ✅ Physical Infrastructure 정의 및 구성요소
- ✅ Data Center, Server, Storage, Network, Power 분류
- ✅ 보안 고려사항 및 실전 예시

---

**문서 끝**
