# Zone 5: Endpoint (엔드포인트 영역)

## 📋 문서 정보

**Zone**: 5 - Endpoint
**영문명**: Endpoint Zone
**한글명**: 엔드포인트 영역
**위치**: 최종 사용자 및 디바이스
**신뢰 수준**: Variable (50% - 사용자별 상이)
**작성일**: 2025-01-20

---

## 🎯 Zone 정의

### 개요

**Zone 5 (Endpoint)**는 **최종 사용자 및 디바이스가 위치하는 가변 신뢰 영역**입니다.

```yaml
핵심 특징:
  - 사용자별 신뢰 수준 상이
  - Zero Trust 접근 필수
  - 지속적 검증 (Continuous Verification)
  - 디바이스 관리 필요
  - 신뢰 수준: 50% (가변 - 사용자별 상이)
```

### 계층 위치

```yaml
사용자 (Zone 5) → Zone 1 (Perimeter) → Zone 2 (Application)
                      ↑
                Zero Trust 접근
                - 인증 필수
                - 디바이스 검증
                - 지속적 모니터링
```

---

## 📦 Zone 5 구성요소

### 1. 웹 브라우저 (Web Browser)

**대표 브라우저**:
```yaml
Desktop:
  - Google Chrome (가장 인기)
  - Microsoft Edge (Chromium 기반)
  - Mozilla Firefox
  - Safari (macOS)

Mobile:
  - Chrome Mobile (Android, iOS)
  - Safari Mobile (iOS)
  - Samsung Internet (Android)
```

**보안 고려사항**:
```yaml
HTTPS Only:
  - 모든 통신 HTTPS 필수
  - HSTS (HTTP Strict Transport Security)
  - Certificate Pinning (선택적)

쿠키 보안:
  - Secure Flag (HTTPS only)
  - HttpOnly Flag (XSS 방어)
  - SameSite=Strict (CSRF 방어)

로컬 저장소:
  - LocalStorage: 민감 정보 저장 금지
  - SessionStorage: 세션 종료 시 삭제
  - IndexedDB: 암호화 권장
```

**Function Tags**:
- Primary: `N/A` (사용자 디바이스, 우리가 태그 부여 안 함)

**Zone 배치**: Zone 5 (Endpoint)

---

### 2. 모바일 앱 (Mobile Application)

**대표 플랫폼**:
```yaml
Native:
  - iOS: Swift, SwiftUI
  - Android: Kotlin, Jetpack Compose

Cross-Platform:
  - Flutter (Dart)
  - React Native (JavaScript)
  - Ionic, Capacitor (Web 기반)
```

**보안 고려사항**:
```yaml
데이터 보호:
  - Keychain (iOS), Keystore (Android)
  - 민감 정보 로컬 저장 금지
  - 앱 데이터 암호화

Certificate Pinning:
  - SSL Pinning (중간자 공격 방어)
  - Certificate Transparency

앱 보안:
  - Code Obfuscation (난독화)
  - Root/Jailbreak 탐지
  - Tamper Detection (변조 탐지)
```

**Function Tags**:
- Primary: `A1.7` (Mobile Application)

**Zone 배치**: Zone 5 (Endpoint)

---

### 3. VPN Client

**대표 VPN 솔루션**:
```yaml
Enterprise VPN:
  - Cisco AnyConnect
  - Palo Alto GlobalProtect
  - Fortinet FortiClient

오픈소스:
  - OpenVPN
  - WireGuard (빠르고 간단)

클라우드 VPN:
  - AWS Client VPN
  - Azure VPN Gateway
  - Google Cloud VPN
```

**기능**:
```yaml
보안 터널:
  - IPsec, SSL/TLS VPN
  - Split Tunneling (선택적 트래픽만 VPN)
  - Kill Switch (VPN 끊김 시 차단)

인증:
  - Username/Password + MFA
  - Certificate-based
  - RADIUS, LDAP 통합

사용 사례:
  - 재택근무 (Remote Work)
  - 내부 시스템 접근 (Zone 2, 3, 4)
  - 해외 출장
```

**Function Tags**:
- Primary: `N4.1` (VPN)
- Secondary: `S5.4` (Secure Remote Access)

**Zone 배치**: Zone 5 (Endpoint)

---

### 4. IoT 디바이스

**유형**:
```yaml
Smart Devices:
  - 스마트폰, 태블릿
  - 스마트 워치 (Apple Watch, Galaxy Watch)

Industrial IoT:
  - 센서 (온도, 습도, 압력)
  - 액추에이터 (모터, 밸브)
  - SCADA 시스템

Consumer IoT:
  - 스마트 홈 (조명, 온도 조절기)
  - 스마트 스피커 (Alexa, Google Home)
  - IP 카메라
```

**보안 고려사항**:
```yaml
취약점:
  - 기본 비밀번호 (admin/admin)
  - 펌웨어 업데이트 부재
  - 낮은 보안 수준

방어:
  - 네트워크 격리 (VLAN)
  - 정기 펌웨어 업데이트
  - 디바이스 인증 (Certificate)
  - Zero Trust 접근
```

**Function Tags**:
- Primary: `A1.8` (IoT Device)

**Zone 배치**: Zone 5 (Endpoint)

---

## 🔐 Zone 5 보안 정책

### 신뢰 수준

```yaml
신뢰 수준: Variable (50% - 사용자별 상이)
  - 일반 사용자: 40%
  - 인증된 사용자: 60%
  - 관리자: 70%
  - IoT 디바이스: 30%

Zero Trust 원칙:
  - Never Trust, Always Verify
  - 지속적 검증 (Continuous Verification)
  - 최소 권한 접근 (Least Privilege)
  - 디바이스 신뢰도 평가
```

### 네트워크 정책

```yaml
인바운드:
  허용:
    - Zone 0-A (인터넷) → Zone 5: HTTPS (일반 사용자)
    - Zone 1 → Zone 5: HTTPS (응답)
  차단:
    - Zone 2, 3, 4 → Zone 5 직접 접근 금지

아웃바운드:
  허용:
    - Zone 5 → Zone 0-A (인터넷): HTTPS (일반 웹 사이트)
    - Zone 5 → Zone 1: HTTPS (우리 서비스)
    - Zone 5 (VPN) → Zone 1 → Zone 2 (내부 서비스)
  차단:
    - Zone 5 → Zone 2, 3, 4 직접 접근 절대 금지
```

### 디바이스 관리 (MDM)

```yaml
Mobile Device Management:
  - Intune (Microsoft)
  - Jamf (Apple)
  - VMware Workspace ONE

정책:
  - 디바이스 암호화 필수
  - 화면 잠금 (5분)
  - 원격 와이프 (Remote Wipe)
  - 앱 화이트리스트

Bring Your Own Device (BYOD):
  - 컨테이너화 (업무 앱 격리)
  - VPN 필수
  - 민감 데이터 로컬 저장 금지
```

---

## 🔄 Zone 5 트래픽 흐름

### 일반 사용자 웹 접속

```
사용자 (Zone 5 - 브라우저)
    ↓ HTTPS (443)
인터넷 (Zone 0-A)
    ↓
CDN/WAF (Zone 1)
    ↓ 검증된 트래픽
Load Balancer (Zone 1)
    ↓
API Server (Zone 2) ← JWT 검증
    ↑ JSON Response
브라우저 (Zone 5)
```

### VPN 사용자 내부 시스템 접근

```
사용자 (Zone 5 - VPN Client)
    ↓ VPN 연결 (IPsec/SSL)
VPN Gateway (Zone 1)
    ↓ 인증 (MFA) ✅
    ↓ 디바이스 검증 ✅
    ↓
내부 서비스 (Zone 2, 3, 4)
    - Zone 2: API Server, App Server
    - Zone 3: Database (제한적 접근)
    - Zone 4: Monitoring, IAM (관리자만)
```

### 모바일 앱 → API Server

```
사용자 (Zone 5 - Mobile App)
    ↓ HTTPS, Certificate Pinning
Zone 1 (WAF, Load Balancer)
    ↓
API Server (Zone 2) ← JWT 검증
    ↓ Database 쿼리
Database (Zone 3)
    ↑ Query Result
API Server (Zone 2)
    ↑ JSON Response
Mobile App (Zone 5)
```

---

## 🚫 Zone 5 접근 제어

### 허용되는 연결

| 출발 Zone | 목적 Zone | 프로토콜 | 용도 |
|----------|----------|---------|------|
| Zone 5 | Zone 0-A | HTTPS | 일반 웹 사이트 |
| Zone 5 | Zone 1 | HTTPS | 우리 서비스 (WAF 경유) |
| Zone 5 (VPN) | Zone 1 → Zone 2 | VPN + HTTPS | 내부 서비스 (인증 후) |
| Zone 1 | Zone 5 | HTTPS | 응답 반환 |
| Zone 5 | Zone 4 | Syslog | 사용자 활동 로그 (선택적) |

### 절대 차단되는 연결

| 출발 Zone | 목적 Zone | 이유 |
|----------|----------|------|
| Zone 5 | Zone 2 | 사용자가 직접 App Server 접근 금지 (Zone 1 경유 필수) |
| Zone 5 | Zone 3 | 사용자가 직접 Database 접근 금지 |
| Zone 5 | Zone 4 | 일반 사용자 Management Zone 접근 금지 (관리자만 VPN 경유) |
| Zone 2, 3, 4 | Zone 5 | 서버에서 Endpoint 직접 접근 금지 |

---

## 📊 실전 예시

### 예시 1: 일반 사용자 웹 사이트 접속

```yaml
시나리오: 사용자가 https://example.com 접속

흐름:
  1. 브라우저 (Zone 5) ← 사용자 입력
  2. DNS 조회 → Cloudflare CDN (Zone 0-B)
  3. HTTPS 연결 (TLS 1.3)
  4. Cloudflare WAF (Zone 1):
     - DDoS Protection ✅
     - Bot Detection ✅
     - Rate Limiting ✅
  5. Load Balancer (Zone 1):
     - SSL 종료
     - 헬스 체크 ✅
  6. API Server (Zone 2):
     - 비즈니스 로직 실행
     - Database (Zone 3) 쿼리
  7. 응답 반환 (JSON/HTML)
  8. 브라우저 (Zone 5) ← 렌더링

보안:
  - HTTPS Only
  - HSTS 헤더
  - Secure Cookie
```

### 예시 2: 재택근무자 VPN 접속

```yaml
시나리오: 재택근무자가 내부 시스템 접속

흐름:
  1. VPN Client (Zone 5) ← 사용자 실행
  2. VPN Gateway (Zone 1) 연결:
     - 프로토콜: IPsec or SSL VPN
     - 인증: Username/Password + MFA (TOTP)
     - 디바이스 검증: Certificate
  3. VPN 터널 생성 ✅
  4. 내부 시스템 접근:
     - API Server (Zone 2): 업무 애플리케이션
     - Database (Zone 3): 제한적 접근 (읽기 전용)
     - Monitoring (Zone 4): 관리자만 (일반 사용자 차단)
  5. Kill Switch:
     - VPN 끊김 시 내부 시스템 접근 차단

보안:
  - Split Tunneling Off (모든 트래픽 VPN 경유)
  - Session Timeout: 8시간 (업무 시간)
  - Audit Log: Zone 4 (SIEM)
```

### 예시 3: 모바일 앱 → 결제 API

```yaml
시나리오: 모바일 앱에서 결제

흐름:
  1. Mobile App (Zone 5) ← 사용자 결제 요청
  2. Certificate Pinning 검증 ✅
  3. HTTPS 연결 (TLS 1.3)
  4. JWT Token 포함:
     Authorization: Bearer <token>
  5. WAF (Zone 1):
     - Rate Limiting ✅
     - Bot Detection ✅
  6. API Server (Zone 2):
     - JWT 검증 ✅
     - 결제 요청 → Stripe API (Zone 0-B)
  7. Stripe API (Zone 0-B):
     - Payment Token 처리
     - 결제 성공 ✅
  8. API Server (Zone 2):
     - 주문 저장 (Database - Zone 3)
     - 응답 반환
  9. Mobile App (Zone 5) ← "결제 완료" 표시

보안:
  - Certificate Pinning (중간자 공격 방어)
  - JWT Token (인증)
  - 카드 정보 절대 앱에 저장 금지
```

---

## 🔒 데이터 취급 원칙

### Zone 5에서 처리 가능한 데이터

```yaml
허용:
  - 사용자 세션 (Session Token, JWT)
  - 일반 비즈니스 데이터 (주문 목록, 상품 정보)
  - 캐시된 공개 정보

제한적 허용 (암호화 필수):
  - PII (개인 식별 정보) - 전송 중만 허용
  - 결제 정보 (Token만, 카드 번호 금지)

금지:
  - 비밀번호 평문 저장
  - 카드 번호 원본 저장
  - 민감 데이터 로컬 저장 (LocalStorage, IndexedDB)
```

### 클라이언트 측 보안

```yaml
XSS 방어:
  - Content Security Policy (CSP)
  - 사용자 입력 Sanitization
  - innerHTML 사용 금지 (textContent 사용)

CSRF 방어:
  - SameSite Cookie (Strict)
  - CSRF Token
  - Origin 헤더 검증

클릭재킹 방어:
  - X-Frame-Options: DENY
  - Content-Security-Policy: frame-ancestors 'none'
```

---

## 📋 모니터링 및 로깅

### 사용자 활동 로그

```yaml
수집 항목:
  - 로그인/로그아웃 이력
  - 페이지 방문 로그 (URL, Timestamp)
  - API 호출 로그 (Endpoint, Method)
  - 에러 로그 (클라이언트 측 에러)

보존:
  - 일반 활동: 180일
  - 보안 사고: 1년 이상

개인정보 보호:
  - IP 주소 마스킹 (마지막 옥텟)
  - User-Agent 수집 (분석 목적)
  - PII 로깅 금지
```

### 클라이언트 메트릭

```yaml
성능 메트릭:
  - Page Load Time (P50, P95)
  - API 응답 시간 (클라이언트 관점)
  - 에러율 (<1% 목표)

사용자 경험:
  - Bounce Rate (이탈률)
  - Session Duration (세션 지속 시간)
  - Conversion Rate (전환율)

디바이스 분석:
  - 브라우저 분포 (Chrome, Safari, Firefox)
  - OS 분포 (Windows, macOS, iOS, Android)
  - 화면 해상도
```

---

## ✅ 체크리스트

### 보안

- [ ] HTTPS Only (모든 통신)
- [ ] HSTS 헤더 설정
- [ ] Secure Cookie (Secure, HttpOnly, SameSite)
- [ ] Certificate Pinning (모바일 앱)
- [ ] XSS/CSRF 방어 (CSP, CSRF Token)

### 인증

- [ ] JWT Token 사용
- [ ] Token 만료 시간 (1시간)
- [ ] Refresh Token Rotation
- [ ] MFA 권장 (관리자 필수)

### 디바이스 관리

- [ ] MDM 설정 (Intune, Jamf)
- [ ] 디바이스 암호화 필수
- [ ] 원격 와이프 활성화
- [ ] VPN 설정 (재택근무)

### 모니터링

- [ ] 사용자 활동 로그 (180일)
- [ ] 클라이언트 에러 추적 (Sentry)
- [ ] 성능 모니터링 (Google Analytics, Mixpanel)
- [ ] 이상 로그인 탐지 (Impossible Travel)

---

## 🔗 관련 문서

- [차원 2: Security Zone 개요](./00_차원2_개요.md)
- [Zone 0-A: Untrusted External](./Zone_0-A_Untrusted.md)
- [Zone 1: Perimeter Zone](./Zone_1_Perimeter.md)
- [Zone 2: Application Zone](./Zone_2_Application.md)

---

## 📞 변경 이력

**v2.0 (2025-01-20)** - v2.0 업데이트:
- ✅ Zero Trust 원칙 강화
- ✅ VPN 접속 흐름 업데이트
- ✅ 모바일 앱 보안 강화 (Certificate Pinning)
- ✅ IoT 디바이스 보안 고려사항

**v1.0** - 초기 작성:
- Zone 5 기본 정의
- 브라우저, 모바일 앱

---

**문서 끝**
