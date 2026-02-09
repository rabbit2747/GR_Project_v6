# Power & Cooling (전원 & 냉각)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Power & Cooling |
| **한글명** | 전원 & 냉각 |
| **Layer** | Layer 1 (Physical Infrastructure) |
| **분류** | Facility Infrastructure |
| **Function Tag (Primary)** | P1.7 (UPS) |
| **Function Tag (Secondary)** | P1.8 (PDU), P1.9 (HVAC) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

전원 및 냉각 시스템은 **IT 장비의 안정적 운영을 위한 전력 공급 및 열 관리 인프라**입니다.

### 핵심 역할

1. **전력 공급**
   - 안정적 전력 제공
   - 정전 대비 (UPS, 발전기)
   - 전력 품질 관리 (전압, 주파수)

2. **열 관리**
   - IT 장비 발열 제거
   - 적정 온도 유지 (18-27°C)
   - 습도 조절 (40-60%)

3. **에너지 효율**
   - PUE (Power Usage Effectiveness) 최적화
   - 에너지 비용 절감
   - 친환경 운영

---

## ⚡ 전력 시스템

### 1. UPS (Uninterruptible Power Supply)

**정의**: 정전 시 일시적 전력 공급 장치

**유형**:

#### Standby UPS (Offline)
```
특징: 정전 시만 배터리 사용
절환 시간: 2-10ms
용량: 500VA ~ 2kVA
용도: 개인 PC, 소규모 장비
가격: 10만원 ~ 50만원
```

#### Line-Interactive UPS
```
특징: 전압 조정 + 정전 대비
절환 시간: 2-4ms
용량: 1kVA ~ 10kVA
용도: 소규모 서버, 네트워크 장비
가격: 50만원 ~ 300만원
```

#### Online UPS (Double-Conversion)
```
특징: 항상 배터리 경유 (0ms 절환)
전력 품질: 완벽한 사인파
용량: 10kVA ~ 2000kVA
용도: 데이터센터, 미션 크리티컬
가격: 500만원 ~ 5억원+
```

**대표 제품**:
- **APC by Schneider**: Symmetra, Galaxy
- **Eaton**: 9395, 93PM
- **Vertiv**: Liebert EXL, APM
- **Delta**: Modulon

**일반 사양** (데이터센터용):
```yaml
Capacity: 500kVA ~ 1000kVA (모듈러)
Runtime: 10-15분 (배터리)
Efficiency: 96-99% (에코 모드)
Redundancy: N+1 or 2N
Input: 3-Phase 380/220V
Output: 3-Phase 380/220V
Management: SNMP, Modbus TCP
```

---

### 2. PDU (Power Distribution Unit)

**정의**: 랙 내 전력 분배 장치

**유형**:

#### Basic PDU
```
특징: 단순 분배 (계량 없음)
Outlets: 12-24
가격: 10만원 ~ 50만원
```

#### Metered PDU
```
특징: 전력 사용량 측정
Display: LCD (전류, 전압, kW)
가격: 50만원 ~ 150만원
```

#### Switched PDU
```
특징: 개별 포트 On/Off 제어
Remote: 네트워크 원격 제어
가격: 100만원 ~ 300만원
```

#### Intelligent PDU
```
특징: 포트별 계량 + 제어 + 환경 센서
Features:
  - 온습도 센서
  - 전력 Cap 설정
  - 알림 (SNMP Trap)
가격: 150만원 ~ 500만원
```

**대표 제품**:
- **Raritan**: PX Series
- **APC**: Rack PDU
- **Vertiv**: Geist rPDU
- **Server Technology**: Sentry PDU

---

### 3. Generator (발전기)

**정의**: 장시간 정전 대비 전력 생성

**유형**:
- **Diesel**: 가장 일반적, 대용량
- **Natural Gas**: 깨끗, 소음 적음
- **Dual-Fuel**: 디젤 + 가스 겸용

**일반 사양** (데이터센터):
```yaml
Capacity: 500kW ~ 2MW
Fuel Tank: 1000L ~ 5000L
Runtime: 24-72시간 (Full Load)
Start Time: 10-15초 (자동)
Noise: 70-85 dB
```

**가격대**:
- 500kW: 1억원 ~ 2억원
- 1MW: 2억원 ~ 4억원
- 2MW: 4억원 ~ 8억원

---

## ❄️ 냉각 시스템

### 1. CRAC (Computer Room Air Conditioning)

**정의**: 데이터센터 전용 정밀 공조기

**일반 사양**:
```yaml
Cooling Capacity: 30-100 Tons (1 Ton = 3.5kW)
Airflow: 10,000-40,000 CFM
Temperature Control: ±1°C
Humidity Control: ±5% RH
Redundancy: N+1
```

**가격대**:
- 30 Ton: 3,000만원 ~ 5,000만원
- 50 Ton: 5,000만원 ~ 8,000만원
- 100 Ton: 1억원 ~ 1.5억원

**대표 제품**:
- **Vertiv**: Liebert CRV
- **Stulz**: CyberAir 3
- **Schneider**: EcoBreeze
- **Daikin**: Magnitude

---

### 2. Hot/Cold Aisle Containment

**개념**: 뜨거운 공기와 차가운 공기 분리

```
Cold Aisle Containment:
┌──────────────────────────────┐
│  Cold Aisle (Contained)      │
│                              │
│  [Rack] ← Cold → [Rack]      │
│    ↓                  ↓      │
│  [Rack] ← Cold → [Rack]      │
└──────────────────────────────┘
      ↑              ↑
  Hot Exhaust    Hot Exhaust
      ↓              ↓
    [CRAC]        [CRAC]
```

**효과**:
- 냉각 효율 20-40% 향상
- PUE 개선
- 전력 비용 절감

---

### 3. In-Row Cooling

**정의**: 서버 랙 사이에 배치된 냉각 장치

**특징**:
- 고밀도 환경 (>10kW/Rack)
- 짧은 냉각 경로
- 높은 효율

**일반 사양**:
```yaml
Cooling per Unit: 30-50kW
Placement: Between Racks
Airflow: Horizontal
```

---

### 4. Liquid Cooling

**정의**: 액체를 이용한 직접 냉각

**유형**:

#### Direct-to-Chip
```
CPU/GPU에 직접 냉각수 공급
냉각 능력: 매우 높음
용도: HPC, AI 워크로드
```

#### Immersion Cooling
```
서버 전체를 비전도성 액체에 침수
냉각 능력: 극도로 높음
용도: 초고밀도 컴퓨팅
```

---

## 📊 PUE (Power Usage Effectiveness)

**정의**: 데이터센터 에너지 효율 지표

**계산**:
```
PUE = 전체 시설 전력 / IT 장비 전력

예시:
전체: 1000kW
IT: 600kW
PUE = 1000 / 600 = 1.67
```

**등급**:
```
PUE 3.0: 매우 비효율 (구형 DC)
PUE 2.0: 일반적
PUE 1.5: 효율적
PUE 1.2: 매우 효율적 (구글, 페이스북급)
PUE 1.1: 이상적 (거의 불가능)
```

**PUE 개선 방법**:
1. Hot/Cold Aisle 구현
2. 에어플로우 최적화
3. 온도 상향 조정 (18→24°C)
4. Free Cooling 활용
5. 고효율 UPS/PDU 사용

---

## 🔒 Zone별 고려사항

| Zone | 전력 요구사항 | 냉각 요구사항 |
|------|--------------|---------------|
| **Zone 2** | 중간 (App 서버) | 중간 (5-8kW/Rack) |
| **Zone 3** | 높음 (DB, Storage) | 높음 (10-15kW/Rack) |
| **Zone 4** | 낮음 (관리 서버) | 낮음 (3-5kW/Rack) |

---

## ⚡ 실무 고려사항

### 1. 전력 용량 계획

**계산 예시**:
```
서버 10대 × 800W = 8kW
스토리지 2대 × 400W = 0.8kW
네트워크 장비 × 200W = 0.2kW
──────────────────────────
IT 부하: 9kW
PUE 1.5 적용: 9kW × 1.5 = 13.5kW
여유율 20%: 13.5kW × 1.2 = 16.2kW

→ 20kW UPS 필요
```

### 2. 냉각 용량 계획

**Rule of Thumb**:
```
1kW IT 부하 = 1 Ton 냉방 (대략)

9kW IT = 9 Ton + N+1 = 12 Ton 필요
```

### 3. 이중화 전략

**2N (Full Redundancy)**:
```
[Utility A] [Utility B]
     ↓           ↓
  [UPS A]     [UPS B]
     ↓           ↓
  [PDU A]     [PDU B]
     ↓           ↓
  [Server Dual PSU]
```

---

## 🔗 관련 문서

- [Layer 1 정의](../00_Layer_1_정의.md)
- [Data Center](../01_Data_Center/00_Data_Center_정의.md)
- [Server Hardware](../02_Server_Hardware/00_Server_Hardware_정의.md)

---

**문서 끝**
