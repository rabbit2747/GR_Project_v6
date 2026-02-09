# Firewall (방화벽)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Firewall |
| **한글명** | 방화벽 |
| **Layer** | Layer 2 (Network Infrastructure) |
| **분류** | Security Gateway |
| **Function Tag (Primary)** | S1.1 (Stateful FW) |
| **Function Tag (Secondary)** | S1.2 (NGFW) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

방화벽은 **네트워크 트래픽을 검사하고 정책에 따라 허용/차단하는 보안 장비**입니다.

### 핵심 기능

1. **트래픽 제어**
   - 소스/목적지 IP 기반 필터링
   - 포트 기반 차단/허용
   - 프로토콜 제어

2. **상태 추적 (Stateful Inspection)**
   - TCP 연결 상태 추적
   - 세션 테이블 관리
   - Return 트래픽 자동 허용

3. **고급 위협 방어 (NGFW)**
   - 애플리케이션 인식
   - IPS (Intrusion Prevention System)
   - URL 필터링
   - 악성코드 차단

---

## 🏗️ 방화벽 유형

### 1. Packet Filtering Firewall (패킷 필터링)

**특징**:
- OSI Layer 3/4 검사
- IP, Port, Protocol 기반
- 빠르지만 기능 제한적

**동작**:
```
Rule 1: Allow TCP 80 from 0.0.0.0/0 to 10.0.1.10
Rule 2: Allow TCP 443 from 0.0.0.0/0 to 10.0.1.10
Rule 3: Deny all
```

---

### 2. Stateful Firewall (상태 추적 방화벽)

**특징**:
- 연결 상태 추적
- Return 트래픽 자동 허용
- 세션 하이재킹 방지

**세션 테이블**:
```
Source IP:Port  → Dest IP:Port      State    Timeout
1.2.3.4:54321   → 10.0.1.10:80     ESTABLISHED  300s
5.6.7.8:12345   → 10.0.1.10:443    SYN_SENT     30s
```

---

### 3. NGFW (Next-Generation Firewall)

**정의**: 애플리케이션, 사용자, 콘텐츠 인식 방화벽

**추가 기능**:
```yaml
Application Control:
  - Facebook 차단
  - YouTube HD 제한
  - BitTorrent 차단

User Identity:
  - Active Directory 통합
  - 사용자별 정책
  - LDAP/RADIUS 인증

Threat Prevention:
  - IPS (Intrusion Prevention)
  - Anti-Virus
  - Anti-Spyware
  - URL Filtering
  - Sandboxing

SSL/TLS Inspection:
  - HTTPS 트래픽 복호화
  - 악성코드 검사
  - 데이터 유출 방지 (DLP)
```

**대표 제품**:
- **Palo Alto Networks**: PA-Series (PA-3200, PA-5200)
- **Fortinet**: FortiGate (FG-600E, FG-1000F)
- **Cisco**: Firepower NGFW
- **Check Point**: Quantum Security Gateway

---

## 📝 방화벽 룰 예시

### 기본 정책 (Palo Alto)

```xml
<!-- Zone-based Policy -->
<security-rules>
  <!-- Internet to DMZ -->
  <rule name="Allow-Web-Inbound">
    <from>untrust</from>
    <to>dmz</to>
    <source>any</source>
    <destination>Web-Servers</destination>
    <service>
      <member>service-http</member>
      <member>service-https</member>
    </service>
    <application>
      <member>web-browsing</member>
      <member>ssl</member>
    </application>
    <action>allow</action>
  </rule>

  <!-- DMZ to Internal (Deny by default) -->
  <rule name="DMZ-to-Internal">
    <from>dmz</from>
    <to>trust</to>
    <action>deny</action>
    <log-end>yes</log-end>
  </rule>

  <!-- Internal to Internet -->
  <rule name="Internal-Outbound">
    <from>trust</from>
    <to>untrust</to>
    <application>
      <member>web-browsing</member>
      <member>ssl</member>
    </application>
    <action>allow</action>
    <profile-setting>
      <group>
        <member>AV-Profile</member>
        <member>Anti-Spyware</member>
        <member>URL-Filtering</member>
      </group>
    </profile-setting>
  </rule>
</security-rules>
```

### iptables (Linux Firewall)

```bash
# Flush existing rules
iptables -F

# Default Policy: DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow Loopback
iptables -A INPUT -i lo -j ACCEPT

# Allow Established Connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow SSH (Port 22)
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow HTTP/HTTPS
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Rate Limiting (DDoS Protection)
iptables -A INPUT -p tcp --dport 80 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT

# Log Dropped Packets
iptables -A INPUT -j LOG --log-prefix "FW-DROP: "
iptables -A INPUT -j DROP
```

---

## 🔒 Zone 기반 아키텍처

```
┌─────────────────────────────────────────────────┐
│  Zone-Based Firewall Architecture               │
└─────────────────────────────────────────────────┘

[Internet] (Untrust Zone)
    ↓
[Firewall]
    ↓
[DMZ Zone]
  - Web Servers
  - Mail Servers
  - DNS Servers
    ↓
[Firewall]
    ↓
[Internal Zone] (Trust Zone)
  - Application Servers
  - Database Servers
  - User Workstations
```

**Zone 간 트래픽 정책**:
```
Untrust → DMZ: Allow (HTTP, HTTPS, SMTP)
DMZ → Trust: Deny (기본)
Trust → DMZ: Allow (필요 시)
Trust → Untrust: Allow (제한적)
```

---

## 🛡️ 보안 프로파일

### IPS (Intrusion Prevention)

```yaml
Critical Severity:
  - SQL Injection 차단
  - Remote Code Execution 차단
  - Buffer Overflow 차단
  Action: Block + Alert

High Severity:
  - Known Exploits
  - Malformed Packets
  Action: Block

Medium/Low:
  - Action: Alert Only
```

### Anti-Virus

```yaml
Real-time Scanning:
  - HTTP Downloads
  - SMTP Attachments
  - FTP Transfers

Update Frequency: 매일

Action:
  - Virus Detected → Block + Alert
  - Suspicious → Quarantine
```

### URL Filtering

```yaml
Categories:
  Blocked:
    - Adult Content
    - Gambling
    - Malware Sites
    - Command & Control

  Allowed:
    - Business
    - News
    - Education

  Warned:
    - Social Media (경고 후 접속 허용)
```

---

## 📊 성능 지표

### NGFW 성능 (Palo Alto PA-5220)

```yaml
Firewall Throughput: 63 Gbps
Threat Prevention Throughput: 14.3 Gbps
IPsec VPN Throughput: 12.5 Gbps

Max Sessions: 8,000,000
New Sessions/sec: 630,000

Max Security Rules: 100,000
Max NAT Rules: 32,000
```

---

## ⚡ 실무 고려사항

### 1. 룰 최적화

**Best Practices**:
```
1. 자주 매칭되는 룰을 상단에 배치
2. 구체적인 룰 → 일반적인 룰 순서
3. Deny All 룰을 최하단에
4. 주석으로 룰 목적 명시
5. 정기적으로 미사용 룰 정리
```

### 2. 로깅 전략

```yaml
로그 레벨:
  Critical/High: 실시간 알림
  Medium: 일일 리뷰
  Low: 주간 리뷰

로그 보관:
  - 방화벽 로컬: 30일
  - SIEM으로 전송: 1년
  - 아카이브: 3년 (규정 준수)
```

### 3. HA (High Availability)

```
[Firewall 1]     [Firewall 2]
  (Active)         (Standby)
      ↓                ↓
  [HA Link] (Heartbeat, Config Sync)
      ↓
  State Sync (Session Table)

Failover Time: < 1초
```

---

## 🔗 관련 문서

- [Layer 2 정의](../00_Layer_2_정의.md)
- [WAF](../03_WAF/00_WAF_정의.md)
- [VPN](../05_VPN/00_VPN_정의.md)

---

**문서 끝**
