# Layer 2: Network Infrastructure (네트워크 인프라)

## 📋 Layer 정보

| 속성 | 값 |
|------|-----|
| **Layer 번호** | 2 |
| **한글명** | 네트워크 인프라 |
| **영문명** | Network Infrastructure |
| **변경 빈도** | Medium (월 단위) |
| **복잡도** | High |
| **다이어그램 위치** | 하단 (Layer 1 위) |

---

## 🎯 정의

Layer 2는 **네트워크 트래픽 제어, 보안, 라우팅을 담당하는 논리적 네트워크 계층**입니다.

### 핵심 역할

1. **트래픽 제어**
   - 로드 밸런싱
   - 트래픽 분산
   - QoS (Quality of Service)

2. **보안 게이트웨이**
   - 방화벽 (Firewall)
   - WAF (Web Application Firewall)
   - DDoS 방어

3. **네트워크 서비스**
   - DNS (이름 해석)
   - CDN (콘텐츠 전송)
   - VPN (원격 접속)

---

## 🏗️ 주요 구성요소

Layer 2는 다음 7개 주요 구성요소로 분류됩니다:

| 번호 | 구성요소 | 설명 | 문서 링크 |
|------|---------|------|-----------|
| 1 | **Load Balancer** | L4/L7 부하 분산 | [상세 문서](01_Load_Balancer/00_Load_Balancer_정의.md) |
| 2 | **Firewall** | 네트워크 방화벽 (NGFW) | [상세 문서](02_Firewall/00_Firewall_정의.md) |
| 3 | **WAF** | 웹 애플리케이션 방화벽 | [상세 문서](03_WAF/00_WAF_정의.md) |
| 4 | **Reverse Proxy** | 역방향 프록시 | [상세 문서](04_Reverse_Proxy/00_Reverse_Proxy_정의.md) |
| 5 | **VPN** | 가상 사설망 | [상세 문서](05_VPN/00_VPN_정의.md) |
| 6 | **CDN** | 콘텐츠 전송 네트워크 | [상세 문서](06_CDN/00_CDN_정의.md) |
| 7 | **DNS** | 도메인 네임 시스템 | [상세 문서](07_DNS/00_DNS_정의.md) |

---

## 🔒 Zone별 배치 개요

| Zone | 배치 빈도 | 주요 구성요소 |
|------|----------|---------------|
| **Zone 0** | Very Common | Edge Router, DDoS 방어 |
| **Zone 1** | Very Common | Load Balancer, WAF, CDN, Reverse Proxy |
| **Zone 2** | Common | Internal Load Balancer, Service Mesh |
| **Zone 3** | Rare | DB Proxy (읽기 부하 분산) |
| **Zone 4** | Common | VPN Gateway, Jump Host |

---

## 📊 Layer 특성

### 변경 관리

- **변경 빈도**: 월 단위
- **변경 유형**: 룰 추가/수정, 설정 변경, 버전 업그레이드
- **영향도**: 높음 (트래픽 중단 가능성)

### 의존성

**하위 Layer 의존**:
- Layer 1 (Physical Infrastructure)

**상위 Layer 의존**:
- Layer 3 (Compute)
- Layer 4 (Platform)
- Layer 5 (Data)
- Layer 6 (Runtime)
- Layer 7 (Application)

### 트래픽 흐름

```
인터넷
  ↓
[DNS] → 도메인 해석
  ↓
[CDN] → 정적 콘텐츠 캐싱
  ↓
[DDoS 방어] → 악의적 트래픽 차단
  ↓
[Firewall] → 네트워크 레벨 필터링
  ↓
[Load Balancer] → 트래픽 분산
  ↓
[WAF] → 애플리케이션 레벨 보안
  ↓
[Reverse Proxy] → 요청 전달
  ↓
애플리케이션 서버 (Layer 7)
```

---

## ⚡ 실무 고려사항

### 1. 고가용성 (HA)

**이중화 패턴**:
```
Active-Active:
[LB 1] [LB 2]
  ↓  ×  ↓
[App 1] [App 2]
트래픽 동시 처리

Active-Passive:
[LB 1] [LB 2 (Standby)]
  ↓
[App Servers]
장애 시 자동 전환
```

### 2. 성능 최적화

**계층별 최적화**:
- **L4 Load Balancer**: TCP/UDP 레벨, 초고속
- **L7 Load Balancer**: HTTP 레벨, 세밀한 제어
- **CDN**: Edge 캐싱, 지연시간 감소

### 3. 보안 심층 방어

**다층 보안**:
1. **Perimeter (Zone 0)**: DDoS 방어
2. **Edge (Zone 1)**: Firewall, WAF
3. **Internal**: Micro-segmentation, Zero Trust

### 4. 모니터링

**주요 메트릭**:
- Throughput (Gbps)
- Connections per Second (CPS)
- Latency (ms)
- Error Rate (%)
- SSL/TLS Handshake Time

---

## 🔗 관련 문서

- [차원 1 개요](../00_차원1_개요.md)
- [Layer 1: Physical Infrastructure](../Layer_1_Physical/00_Layer_1_정의.md)
- [Layer 3: Computing Infrastructure](../Layer_3_Compute/00_Layer_3_정의.md)

---

**문서 끝**
