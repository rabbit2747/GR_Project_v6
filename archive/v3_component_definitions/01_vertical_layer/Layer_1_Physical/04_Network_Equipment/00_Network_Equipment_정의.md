# Network Equipment (네트워크 장비)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Network Equipment |
| **한글명** | 네트워크 장비 |
| **Layer** | Layer 1 (Physical Infrastructure) |
| **분류** | Network Hardware |
| **Function Tag (Primary)** | P2.1 (Router) |
| **Function Tag (Secondary)** | P2.2 (Switch), P2.3 (Firewall) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

네트워크 장비는 **데이터 전송, 라우팅, 스위칭을 수행하는 물리적 하드웨어**입니다.

### 핵심 역할

1. **데이터 전송**
   - 패킷 라우팅
   - 스위칭 (Layer 2/3)
   - 트래픽 제어

2. **네트워크 연결**
   - WAN 연결 (인터넷, 전용선)
   - LAN 구성
   - VLAN 분리

3. **보안 및 제어**
   - 방화벽
   - 접근 제어
   - QoS (Quality of Service)

---

## 🏗️ 주요 네트워크 장비

### 1. Router (라우터)

**정의**: 서로 다른 네트워크 간 패킷 라우팅

**기능**:
- Layer 3 (IP) 라우팅
- NAT (Network Address Translation)
- VPN 터널링
- 동적 라우팅 프로토콜 (BGP, OSPF)

**대표 제품**:
- **Cisco**: ASR 1000 Series, ISR 4000 Series
- **Juniper**: MX Series
- **Arista**: 7280R Series
- **Mikrotik**: CCR Series

**일반 사양** (Enterprise Router):
```yaml
Throughput: 10-100 Gbps
Ports:
  - 4-8 x 10GbE SFP+
  - 2-4 x 100GbE QSFP28
Routing Table: 1M+ Routes
Protocols: BGP, OSPF, IS-IS, MPLS
HA: Dual PSU, VRRP Support
```

**가격대**:
- SMB: 100만원 ~ 500만원
- Enterprise: 1,000만원 ~ 1억원
- Carrier: 1억원 ~ 10억원+

---

### 2. Switch (스위치)

**정의**: 동일 네트워크 내 디바이스 간 연결

#### Layer 2 Switch (Unmanaged/Managed)
```yaml
Layer: Data Link (MAC Address)
Ports: 24-48 x 1GbE
Uplink: 4 x 10GbE SFP+
VLAN: 802.1Q Support
가격: 50만원 ~ 300만원
```

#### Layer 3 Switch (Core/Distribution)
```yaml
Layer: Network (IP Routing)
Ports: 48 x 10GbE + 6 x 100GbE
Switching Capacity: 1-10 Tbps
Routing Table: 100K Routes
VLAN: 4096 VLANs
가격: 500만원 ~ 5,000만원
```

**대표 제품**:
- **Cisco**: Catalyst 9000 Series, Nexus 9000
- **Arista**: 7050X, 7280E
- **Juniper**: EX Series, QFX Series
- **HP/Aruba**: 2930M, 3810M

**스위치 아키텍처**:
```
┌────────────────────────────────────────┐
│  Core Switch (Layer 3)                 │
│  - 100GbE Uplinks                      │
│  - 10GbE Downlinks                     │
└──────────┬────────────┬────────────────┘
           ↓            ↓
  ┌────────────┐  ┌────────────┐
  │Distribution│  │Distribution│
  │Switch (L3) │  │Switch (L3) │
  └─────┬──────┘  └──────┬─────┘
        ↓                ↓
  ┌──────────┐      ┌──────────┐
  │Access SW │      │Access SW │
  │(L2/L3)   │      │(L2/L3)   │
  └────┬─────┘      └─────┬────┘
       ↓                  ↓
  [Servers]          [Workstations]
```

---

### 3. Firewall (방화벽)

**참고**: Layer 2에서 상세 설명 (논리적 기능), 여기서는 물리 장비만

**하드웨어 방화벽 예시**:
- **Palo Alto**: PA-3200, PA-5200
- **Fortinet**: FortiGate 600E, 1000F
- **Cisco**: Firepower 2100, 4100
- **Check Point**: 6000, 15000

**일반 사양** (Mid-range):
```yaml
Throughput: 10-50 Gbps (Firewall)
IPS Throughput: 5-20 Gbps
Concurrent Sessions: 2M - 10M
Ports: 8-16 x 10GbE SFP+
HA: Active-Passive or Active-Active
```

---

### 4. Access Point (무선 AP)

**정의**: Wi-Fi 무선 네트워크 제공

**대표 제품**:
- **Cisco Meraki**: MR46, MR56
- **Aruba**: AP-515, AP-635
- **Ubiquiti**: UniFi 6 Pro, WiFi 6 LR

**일반 사양**:
```yaml
Standard: Wi-Fi 6 (802.11ax)
Speed: 1.2-2.4 Gbps
Frequency: 2.4GHz + 5GHz (Dual-Band)
Antennas: 4x4 MIMO
PoE: 802.3at/bt
Management: Cloud or On-Prem Controller
```

---

## 🔌 네트워크 인터페이스 & 케이블

### Ethernet 표준

| 표준 | 속도 | 매체 | 거리 | 커넥터 |
|------|------|------|------|--------|
| **1000BASE-T** | 1 Gbps | Cat5e/6 | 100m | RJ-45 |
| **10GBASE-T** | 10 Gbps | Cat6A/7 | 100m | RJ-45 |
| **10GBASE-SR** | 10 Gbps | Fiber (MM) | 300m | SFP+ |
| **10GBASE-LR** | 10 Gbps | Fiber (SM) | 10km | SFP+ |
| **40GBASE-SR4** | 40 Gbps | Fiber (MM) | 100m | QSFP+ |
| **100GBASE-SR4** | 100 Gbps | Fiber (MM) | 100m | QSFP28 |

---

### SFP Transceiver (광 모듈)

**유형**:
- **SFP**: 1 Gbps
- **SFP+**: 10 Gbps
- **QSFP**: 40 Gbps
- **QSFP28**: 100 Gbps
- **QSFP-DD**: 400 Gbps

**광섬유**:
- **MMF** (Multi-Mode Fiber): 짧은 거리 (< 2km), 저렴
- **SMF** (Single-Mode Fiber): 긴 거리 (최대 80km), 고가

---

## 🔒 Zone별 배치 패턴

| Zone | 배치 장비 | 용도 |
|------|----------|------|
| **Zone 0** | Edge Router, Firewall | 인터넷 게이트웨이 |
| **Zone 1** | DMZ Switch, WAF | 외부 접근 서비스 |
| **Zone 2** | Core Switch (L3) | 애플리케이션 네트워크 |
| **Zone 3** | Core Switch (L3) | 데이터베이스 네트워크 (격리) |
| **Zone 4** | Management Switch | Out-of-Band 관리 |

---

## 📊 네트워크 토폴로지

### Spine-Leaf 아키텍처 (데이터센터)

```
        [Spine 1]          [Spine 2]
           ↓ ↓ ↓ ↓            ↓ ↓ ↓ ↓
        ┌──┴─┴─┴─┴────────────┴─┴─┴─┴──┐
        ↓      ↓       ↓       ↓       ↓
    [Leaf 1] [Leaf 2] [Leaf 3] [Leaf 4] [Leaf 5]
       ↓        ↓        ↓        ↓        ↓
    [Rack 1] [Rack 2] [Rack 3] [Rack 4] [Rack 5]

특징:
- 모든 Leaf는 모든 Spine에 연결
- 2-hop 통신 (최대)
- 수평 확장 용이
- 대역폭 예측 가능
```

---

## ⚡ 실무 고려사항

### 1. 대역폭 계획

**Oversubscription Ratio**:
```
1:1 (No Oversubscription): 모든 포트 동시 사용 가능
2:1: 절반만 동시 사용 가능 (일반적)
4:1: 1/4만 동시 사용 가능 (비용 절감)

예시:
48 x 10GbE Access → 4 x 100GbE Uplink
= 480 Gbps → 400 Gbps
= 1.2:1 Oversubscription
```

### 2. 이중화 설계

**Network Redundancy**:
```
[Router 1]     [Router 2]
    ↓ (VRRP)      ↓
[Core SW 1] — [Core SW 2]
    ↓              ↓
[Distribution SW 1] [Distribution SW 2]
    ↓                    ↓
[Access SW] (Dual-Homed)
```

### 3. 케이블 관리

**색상 코딩**:
- 파란색: 서버 연결
- 노란색: 스토리지
- 빨간색: 관리 네트워크
- 초록색: 백업 네트워크

---

## 🔗 관련 문서

- [Layer 1 정의](../00_Layer_1_정의.md)
- [Data Center](../01_Data_Center/00_Data_Center_정의.md)
- [Layer 2: Network Infrastructure](../../Layer_2_Network/00_Layer_2_정의.md)

---

**문서 끝**
