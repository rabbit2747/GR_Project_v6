# VPN (Virtual Private Network)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | VPN |
| **한글명** | 가상 사설망 |
| **Layer** | Layer 2 (Network Infrastructure) |
| **분류** | Secure Remote Access |
| **Function Tag (Primary)** | S1.6 (VPN Gateway) |
| **Function Tag (Secondary)** | S1.7 (IPsec), S1.8 (SSL VPN) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

VPN은 **공용 네트워크(인터넷)를 통해 안전한 암호화 터널을 생성하여 원격 접속 또는 네트워크 간 연결을 제공하는 기술**입니다.

### 핵심 기능

1. **암호화 통신**
   - 데이터 암호화 (AES-256)
   - 터널링 프로토콜
   - 중간자 공격 방지

2. **원격 접속**
   - 재택근무 지원
   - 외부에서 내부 네트워크 접근
   - 다중 인증 (MFA)

3. **Site-to-Site 연결**
   - 본사 ↔ 지사 연결
   - 클라우드 ↔ 온프레미스 연결
   - 항상 연결 (Always-on)

---

## 🏗️ VPN 유형

### 1. Site-to-Site VPN (사이트 간 VPN)

**정의**: 두 네트워크를 항상 연결

**구조**:
```
[본사 네트워크]
  10.0.0.0/16
       ↓
  [VPN Gateway]
       ↓
  [인터넷] (암호화 터널)
       ↓
  [VPN Gateway]
       ↓
[지사 네트워크]
  10.1.0.0/16
```

**프로토콜**:
- **IPsec**: 가장 일반적, 하드웨어 가속
- **GRE over IPsec**: 라우팅 프로토콜 지원
- **WireGuard**: 최신, 빠르고 간단

**대표 제품**:
- Cisco ASA, FTD
- Palo Alto Networks
- Fortinet FortiGate
- pfSense, OPNsense

---

### 2. Remote Access VPN (원격 접속 VPN)

**정의**: 개별 사용자가 기업 네트워크에 접속

#### SSL VPN (HTTPS 기반)

**특징**:
- 웹 브라우저로 접속 가능
- 클라이언트 소프트웨어 불필요 (Portal 모드)
- 방화벽 통과 쉬움 (443 포트)

**동작 방식**:
```
[사용자] --HTTPS (443)--> [SSL VPN Gateway] --> [내부 네트워크]

인증:
1. 사용자명/비밀번호
2. MFA (OTP, Push)
3. 인증서 (선택)

터널:
- Full Tunnel: 모든 트래픽 VPN 경유
- Split Tunnel: 기업 트래픽만 VPN 경유
```

**대표 제품**:
- Palo Alto GlobalProtect
- Cisco AnyConnect
- Fortinet FortiClient
- OpenVPN

---

#### IPsec VPN (전용 클라이언트)

**특징**:
- 전용 클라이언트 필요
- 강력한 암호화
- OS 레벨 통합

**프로토콜**:
- **IKEv2/IPsec**: 모던 표준, 모바일 지원
- **L2TP/IPsec**: 오래됨, 호환성 좋음

---

### 3. Cloud VPN

**정의**: 클라우드 제공 VPN 서비스

**제품**:
- **AWS VPN**: Site-to-Site, Client VPN
- **Azure VPN Gateway**: Point-to-Site, Site-to-Site
- **Google Cloud VPN**: HA VPN, Classic VPN

**가격** (AWS 예시):
```yaml
VPN Connection: $0.05/hour ($36/month)
Data Transfer: $0.09/GB (out)
```

---

## 🔧 IPsec VPN 설정

### Phase 1 (IKE)

**목적**: VPN 게이트웨이 간 보안 채널 수립

```yaml
Phase 1 (IKEv2):
  Authentication: Pre-Shared Key (PSK) or Certificate
  Encryption: AES-256-CBC
  Integrity: SHA256
  DH Group: 14 (2048-bit)
  Lifetime: 28800s (8 hours)
```

### Phase 2 (IPsec)

**목적**: 실제 데이터 암호화

```yaml
Phase 2 (ESP):
  Encryption: AES-256-GCM
  Integrity: (GCM includes auth)
  PFS: DH Group 14
  Lifetime: 3600s (1 hour)
```

### StrongSwan 설정 예시 (Linux)

```
# /etc/ipsec.conf
conn site-to-site
    type=tunnel
    auto=start

    # Local (본사)
    left=203.0.113.1
    leftsubnet=10.0.0.0/16
    leftid=@hq.example.com

    # Remote (지사)
    right=198.51.100.1
    rightsubnet=10.1.0.0/16
    rightid=@branch.example.com

    # Phase 1
    ike=aes256-sha256-modp2048!
    ikelifetime=28800s

    # Phase 2
    esp=aes256gcm16!
    lifetime=3600s
    rekeymargin=540s
```

---

## 🌐 WireGuard (Modern VPN)

**특징**:
- 매우 빠름 (Linux 커널 통합)
- 간단한 설정
- 최신 암호화 (Curve25519, ChaCha20)

**설정 예시**:
```ini
# /etc/wireguard/wg0.conf
[Interface]
Address = 10.200.200.1/24
PrivateKey = <server_private_key>
ListenPort = 51820

# Peer (Client)
[Peer]
PublicKey = <client_public_key>
AllowedIPs = 10.200.200.2/32
```

**클라이언트 설정**:
```ini
[Interface]
Address = 10.200.200.2/24
PrivateKey = <client_private_key>
DNS = 1.1.1.1

[Peer]
PublicKey = <server_public_key>
Endpoint = vpn.example.com:51820
AllowedIPs = 0.0.0.0/0, ::/0  # Full Tunnel
PersistentKeepalive = 25
```

---

## 🔒 Zone별 배치 패턴

| Zone | 배치 빈도 | 용도 |
|------|----------|------|
| **Zone 0/1** | Very Common | VPN Gateway (인터넷 접속점) |
| **Zone 4** | Common | VPN 터미네이션 후 관리 네트워크 접근 |

---

## ⚡ 실무 고려사항

### 1. Split Tunnel vs Full Tunnel

**Split Tunnel**:
```
기업 네트워크 (10.0.0.0/8) → VPN
인터넷 (나머지) → 직접 연결

장점:
- VPN 부하 감소
- 빠른 인터넷 속도

단점:
- 보안 위험 (사용자 ISP 신뢰 필요)
```

**Full Tunnel**:
```
모든 트래픽 → VPN → 기업 프록시 → 인터넷

장점:
- 완전한 보안
- 중앙 로깅

단점:
- VPN 대역폭 부담
- 느린 인터넷 속도
```

### 2. 대역폭 계획

```yaml
사용자당 평균 대역폭: 1-5 Mbps
동시 접속자 100명:
  - 평균: 200 Mbps
  - 피크: 500 Mbps
  → 1 Gbps VPN Gateway 권장
```

### 3. 다중 인증 (MFA)

```yaml
VPN 인증 단계:
  1. 사용자명/비밀번호
  2. MFA:
     - TOTP (Google Authenticator)
     - Push Notification (Duo, Okta)
     - SMS (비권장, SIM 스와핑 위험)
  3. 인증서 (선택)
```

### 4. 모니터링

```yaml
주요 메트릭:
  - Active Connections
  - Throughput (Mbps)
  - Latency (ms)
  - Connection Failures
  - Authentication Failures

알림:
  - Connection > 80% capacity
  - High latency (> 100ms)
  - Authentication failures (brute force 탐지)
```

---

## 🔗 관련 문서

- [Layer 2 정의](../00_Layer_2_정의.md)
- [Firewall](../02_Firewall/00_Firewall_정의.md)
- [Layer 1: Network Equipment](../../Layer_1_Physical/04_Network_Equipment/00_Network_Equipment_정의.md)

---

**문서 끝**
