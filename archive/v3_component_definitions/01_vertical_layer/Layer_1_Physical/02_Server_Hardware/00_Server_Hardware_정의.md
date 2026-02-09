# Server Hardware (서버 하드웨어)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Server Hardware |
| **한글명** | 서버 하드웨어 |
| **Layer** | Layer 1 (Physical Infrastructure) |
| **분류** | Computing Hardware |
| **Function Tag (Primary)** | P1.3 (Rack Server) |
| **Function Tag (Secondary)** | P1.4 (Blade Server) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

서버 하드웨어는 **애플리케이션, 데이터베이스, 서비스를 실행하는 물리적 컴퓨팅 플랫폼**입니다.

### 핵심 역할

1. **연산 처리**
   - CPU를 통한 명령 실행
   - 멀티코어, 멀티스레드 병렬 처리
   - 워크로드별 최적화

2. **메모리 제공**
   - 애플리케이션 실행 공간
   - 캐싱 및 버퍼링
   - 고속 데이터 접근

3. **I/O 처리**
   - 네트워크 인터페이스
   - 스토리지 인터페이스
   - 확장 슬롯 (PCIe)

---

## 🏗️ 서버 유형

### 1. Rack Server (랙 서버)

**특징**:
- 19인치 표준 랙에 장착
- 높이: 1U, 2U, 4U (1U = 1.75인치)
- 가장 일반적인 서버 형태

**대표 모델**:
- **Dell PowerEdge**: R650, R750
- **HP ProLiant**: DL380, DL360
- **Lenovo ThinkSystem**: SR650, SR630
- **Supermicro**: AS-1114S-WN10RT

**일반 사양** (2U 서버):
```yaml
CPU:
  - 2x Intel Xeon Gold 6338 (32 Cores each)
  - or 2x AMD EPYC 7543 (32 Cores each)

Memory:
  - 512GB ~ 4TB DDR4/DDR5 ECC RAM
  - 32 DIMM Slots

Storage:
  - 8-12 x 2.5" Drive Bays
  - NVMe SSD, SATA SSD, HDD

Network:
  - 4x 25GbE or 2x 100GbE

Power:
  - Dual 800W ~ 1600W PSU (Redundant)
```

**가격대**:
- 1U 기본: 300만원 ~ 800만원
- 2U 고급: 1,000만원 ~ 3,000만원
- 4U 고성능: 3,000만원 ~ 1억원

---

### 2. Blade Server (블레이드 서버)

**특징**:
- 샤시(Chassis)에 다수의 블레이드 장착
- 공유 전원, 냉각, 네트워크
- 고밀도 배치

**대표 제품**:
- Dell PowerEdge M1000e (Chassis)
- HP BladeSystem c7000
- Cisco UCS 5108

**구조**:
```
┌─────────────────────────────────────────┐
│  Blade Chassis (10U)                    │
├─────────────────────────────────────────┤
│  [Blade 1] [Blade 2] [Blade 3] [Blade 4]│
│  [Blade 5] [Blade 6] [Blade 7] [Blade 8]│
│                                          │
│  Shared Components:                     │
│  - Power Supply (6x 2400W)              │
│  - Network Switches (2x 10GbE)          │
│  - Management Module                    │
└─────────────────────────────────────────┘
```

**장점**:
- 공간 효율성 (고밀도)
- 케이블링 간소화
- 중앙 관리

**단점**:
- 높은 초기 비용
- 벤더 종속성
- 블레이드 간 열 관리 복잡

---

### 3. Tower Server (타워 서버)

**특징**:
- 독립형 케이스 (데스크톱 유사)
- 랙 불필요
- 소규모 환경에 적합

**용도**:
- 소규모 사무실
- 부서별 서버
- 개발/테스트 환경

---

## 🔧 서버 구성요소 상세

### CPU (중앙처리장치)

**Enterprise CPU**:

| 제조사 | 제품군 | 코어 수 | TDP | 용도 |
|--------|--------|--------|-----|------|
| **Intel** | Xeon Gold 6338 | 32 | 205W | 범용 워크로드 |
| **Intel** | Xeon Platinum 8380 | 40 | 270W | 미션 크리티컬 |
| **AMD** | EPYC 7543 | 32 | 225W | 고성능 컴퓨팅 |
| **AMD** | EPYC 7763 | 64 | 280W | 가상화, 클라우드 |

**선택 기준**:
- 코어 수 vs 클럭 속도
- 워크로드 특성 (CPU 집약 vs I/O 집약)
- 가격 대비 성능

---

### Memory (메모리)

**ECC RAM (Error-Correcting Code)**:
- 오류 자동 감지 및 수정
- 서버용 필수 사양
- 일반 RAM 대비 10-20% 비쌈

**용량 계획**:
```
권장 메모리 = (동시 사용자 수 × 512MB) + OS 오버헤드 (16GB) + 버퍼 (20%)

예시:
- 웹 서버 (1000 동시 사용자): 512GB
- DB 서버 (100GB 데이터): 128GB ~ 256GB
- VM 호스트 (20 VM): 512GB ~ 1TB
```

---

### Storage Interface

**옵션**:
- **SATA**: 최대 6Gbps, HDD/SSD
- **SAS**: 최대 12Gbps, Enterprise SSD
- **NVMe**: 최대 32Gbps (PCIe 4.0 x4), 초고속 SSD

**권장 구성**:
```
OS: 2x NVMe SSD (RAID 1)
Application: 4x NVMe SSD (RAID 10)
Data: 8x SAS SSD (RAID 6)
```

---

## 🔒 Zone별 배치 패턴

| Zone | 일반적 배치 | 서버 유형 |
|------|------------|----------|
| **Zone 1** | Rare | DMZ 웹 서버 |
| **Zone 2** | Very Common | 애플리케이션 서버, API 서버 |
| **Zone 3** | Very Common | DB 서버, 스토리지 서버 |
| **Zone 4** | Common | 관리 서버, 모니터링 서버 |

---

## 📊 서버 선택 기준

### Workload별 추천 사양

**웹 서버**:
```yaml
CPU: 8-16 Cores (높은 클럭)
Memory: 64GB ~ 128GB
Storage: 2x 480GB NVMe (OS/App)
Network: 2x 10GbE (Bonding)
```

**데이터베이스 서버**:
```yaml
CPU: 24-32 Cores (높은 코어 수)
Memory: 256GB ~ 1TB
Storage: 8x 1.92TB NVMe (RAID 10)
Network: 2x 25GbE
```

**가상화 호스트**:
```yaml
CPU: 32-64 Cores
Memory: 512GB ~ 2TB
Storage: 12x 3.84TB NVMe
Network: 2x 100GbE
```

---

## ⚡ 실무 고려사항

### 1. 구매 전 체크리스트

- [ ] 워크로드 프로파일링 (CPU, Memory, I/O)
- [ ] 3년 후 성장률 예측
- [ ] 전력 용량 및 냉각 확인
- [ ] 지원 및 보증 옵션 (3년 vs 5년)
- [ ] 부품 호환성 (기존 인프라와)

### 2. 이중화 전략

**N+1 Redundancy**:
```
필요 서버: 10대
실제 구매: 11대 (1대 예비)
```

**Active-Active**:
```
로드 밸런서
    ↓
[Server 1] [Server 2] [Server 3]
모두 트래픽 처리
```

### 3. 전력 및 냉각

**전력 소비**:
```
2U 서버: 평균 400W ~ 800W (Peak: 1200W)
Blade 샤시: 평균 3000W ~ 5000W
```

**냉각 요구사항**:
```
서버 10대 → 8kW 발열 → 2-3 Ton 냉방
```

---

## 🔗 관련 문서

- [Layer 1 정의](../00_Layer_1_정의.md)
- [Data Center](../01_Data_Center/00_Data_Center_정의.md)
- [Storage](../03_Storage/00_Storage_정의.md)
- [Layer 3: Computing Infrastructure](../../Layer_3_Compute/00_Layer_3_정의.md)

---

**문서 끝**
