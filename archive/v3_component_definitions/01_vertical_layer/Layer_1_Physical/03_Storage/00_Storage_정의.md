# Storage (스토리지)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Storage |
| **한글명** | 스토리지 |
| **Layer** | Layer 1 (Physical Infrastructure) |
| **분류** | Storage Hardware |
| **Function Tag (Primary)** | P1.5 (SAN) |
| **Function Tag (Secondary)** | P1.6 (NAS), D4.1 (Object Storage - 논리적) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

스토리지는 **데이터를 영구적으로 저장하고 보호하는 물리적 하드웨어 시스템**입니다.

### 핵심 역할

1. **데이터 영속성**
   - 전원 꺼져도 데이터 유지
   - 장기 보관 및 아카이빙
   - 백업 및 재해 복구

2. **데이터 접근**
   - 블록 레벨 (SAN)
   - 파일 레벨 (NAS)
   - 객체 레벨 (Object Storage)

3. **데이터 보호**
   - RAID (Redundancy)
   - 스냅샷
   - 복제 (Replication)

---

## 🏗️ 스토리지 유형

### 1. SAN (Storage Area Network)

**정의**: 블록 레벨 스토리지 네트워크

**프로토콜**:
- **Fibre Channel**: 8/16/32 Gbps, 전용 네트워크
- **iSCSI**: IP 기반, 기존 네트워크 활용 가능
- **FCoE**: Fibre Channel over Ethernet

**구조**:
```
[서버 1] [서버 2] [서버 3]
    ↓        ↓        ↓
    [FC Switch] (Fabric)
           ↓
    [SAN Storage]
    - LUN 1: 500GB (서버 1)
    - LUN 2: 1TB (서버 2)
    - LUN 3: 2TB (서버 3)
```

**대표 제품**:
- **Dell EMC**: PowerMax, Unity
- **NetApp**: AFF (All-Flash Array)
- **HPE**: 3PAR, Primera
- **Pure Storage**: FlashArray

**일반 사양**:
```yaml
Controllers: 2x Active-Active (HA)
Cache: 128GB ~ 1TB (Write Cache)
Drives: 24-48 Slots
  - SSD: 1.92TB, 3.84TB, 7.68TB
  - HDD: 8TB, 12TB, 18TB
Connectivity:
  - 8x 32Gbps FC Ports
  - or 4x 100GbE iSCSI
RAID: 5, 6, 10
Performance: 100K ~ 1M IOPS
```

**가격대**:
- Entry: 5,000만원 ~ 1억원
- Mid-range: 1억원 ~ 3억원
- High-end: 5억원 ~ 20억원+

**용도**:
- 가상화 환경 (VMware VMFS)
- 데이터베이스 (Oracle, SQL Server)
- 고성능 I/O 워크로드

---

### 2. NAS (Network Attached Storage)

**정의**: 파일 레벨 스토리지, 네트워크를 통해 파일 공유

**프로토콜**:
- **NFS**: Linux/Unix 표준
- **SMB/CIFS**: Windows 파일 공유
- **AFP**: macOS (deprecated)

**구조**:
```
[사용자 PC] [서버 1] [서버 2]
      ↓         ↓         ↓
      [  LAN/Ethernet Network  ]
               ↓
          [NAS Device]
          - /share/data
          - /share/backup
          - /share/media
```

**대표 제품**:
- **Synology**: DS920+, RS3621xs+
- **QNAP**: TS-464, TS-873A
- **NetApp**: FAS Series
- **Dell EMC**: Isilon, PowerScale

**일반 사양** (Mid-range):
```yaml
CPU: Intel Xeon D-1527 (4 Cores)
Memory: 32GB ~ 256GB
Bays: 8-24 Drive Bays
  - 4TB ~ 18TB HDD
  - 2TB ~ 4TB SSD (Cache)
Network: 4x 10GbE
RAID: 5, 6, 10
Protocols: NFS, SMB, FTP, rsync
```

**가격대**:
- SOHO: 50만원 ~ 300만원 (4-8 Bay)
- SMB: 300만원 ~ 1,500만원 (8-16 Bay)
- Enterprise: 3,000만원 ~ 2억원 (24+ Bay)

**용도**:
- 파일 서버
- 미디어 스토리지
- 백업 타겟
- 협업 문서 공유

---

### 3. DAS (Direct Attached Storage)

**정의**: 서버에 직접 연결된 스토리지

**인터페이스**:
- **Internal**: SATA, SAS, NVMe (서버 내부)
- **External**: USB, eSATA, Thunderbolt

**용도**:
- 단일 서버 전용 스토리지
- 고속 로컬 캐시
- 개발/테스트 환경

---

## 💾 저장 매체 비교

### HDD (Hard Disk Drive)

| 특성 | 값 |
|------|-----|
| **용량** | 8TB ~ 20TB (Enterprise) |
| **속도** | 150-250 MB/s |
| **IOPS** | 100-200 |
| **수명** | 5년 (24/7 운영) |
| **가격** | 용량당 저렴 |
| **용도** | 대용량 아카이브, 콜드 스토리지 |

---

### SSD (Solid State Drive)

**SATA SSD**:
- 속도: 550 MB/s
- IOPS: 90K ~ 100K
- 가격: 중간
- 용도: 일반 서버, 캐시

**SAS SSD**:
- 속도: 1200 MB/s
- IOPS: 120K ~ 150K
- 가격: 높음
- 용도: Enterprise DB, 트랜잭션

**NVMe SSD**:
- 속도: 3500 ~ 7000 MB/s (PCIe 4.0)
- IOPS: 500K ~ 1M
- 가격: 매우 높음
- 용도: 고성능 DB, 분석, AI/ML

---

## 🛡️ RAID 레벨

### RAID 0 (Striping)
```
[Disk 1] [Disk 2]
 Data A1   Data A2
 Data B1   Data B2

성능: ⭐⭐⭐⭐⭐
안정성: ❌
용량: 100%
최소 디스크: 2
```

### RAID 1 (Mirroring)
```
[Disk 1] [Disk 2]
 Data A   Data A
 Data B   Data B

성능: ⭐⭐⭐
안정성: ⭐⭐⭐⭐
용량: 50%
최소 디스크: 2
```

### RAID 5 (Parity)
```
[Disk 1] [Disk 2] [Disk 3]
 Data A   Data B   Parity AB
 Data C   Parity CD Data D
 Parity EF Data E  Data F

성능: ⭐⭐⭐⭐
안정성: ⭐⭐⭐
용량: (N-1)/N
최소 디스크: 3
```

### RAID 6 (Dual Parity)
```
[Disk 1] [Disk 2] [Disk 3] [Disk 4]
 Data A   Data B   Parity 1  Parity 2
 Data C   Parity 1 Data D   Parity 2

성능: ⭐⭐⭐
안정성: ⭐⭐⭐⭐⭐
용량: (N-2)/N
최소 디스크: 4
```

### RAID 10 (1+0)
```
[Pair 1]        [Pair 2]
[Disk 1] [Disk 2]  [Disk 3] [Disk 4]
 Mirror           Mirror
    ↓                ↓
      Stripe

성능: ⭐⭐⭐⭐⭐
안정성: ⭐⭐⭐⭐
용량: 50%
최소 디스크: 4
```

---

## 🔒 Zone별 배치 패턴

| Zone | 일반적 배치 | 스토리지 유형 |
|------|------------|---------------|
| **Zone 1** | Rare | 정적 콘텐츠 (CDN 연동) |
| **Zone 2** | Common | 애플리케이션 데이터 (NAS) |
| **Zone 3** | Very Common | 데이터베이스 (SAN), 백업 |
| **Zone 4** | Common | 백업 스토리지, 아카이브 |

**보안 고려사항**:
- Zone 3: 암호화 필수 (at-rest, in-transit)
- Zone 4: Immutable Storage (WORM - Write Once Read Many)

---

## ⚡ 실무 고려사항

### 1. 용량 계획

**3-2-1 백업 룰**:
```
3: 데이터 사본 3개
2: 2개의 다른 매체 (SSD + HDD)
1: 1개는 오프사이트 (클라우드 또는 다른 지역)
```

**용량 증가율**:
```
연간 데이터 증가율 = 30-50% (일반적)
구매 용량 = 현재 × 3년 증가율 × 1.2 (버퍼)
```

### 2. 성능 최적화

**SSD 티어링**:
```
Hot Data (자주 접근) → NVMe SSD
Warm Data (가끔 접근) → SATA SSD
Cold Data (드물게 접근) → HDD
Archive (거의 접근 안 함) → Tape, Glacier
```

### 3. 비용 최적화

**TCO (Total Cost of Ownership)**:
```
TCO = 구매 비용 + (전력 비용 × 5년) + 유지보수 비용 + 관리 비용
```

---

## 🔗 관련 문서

- [Layer 1 정의](../00_Layer_1_정의.md)
- [Server Hardware](../02_Server_Hardware/00_Server_Hardware_정의.md)
- [Layer 5: Data Services](../../Layer_5_Data/00_Layer_5_정의.md)

---

**문서 끝**
