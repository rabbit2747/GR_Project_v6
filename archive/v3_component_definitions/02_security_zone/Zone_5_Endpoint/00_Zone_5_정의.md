# Zone 5: Endpoint Zone (엔드포인트 존)

## 📋 Zone 정보

| 속성 | 값 |
|------|-----|
| **Zone명** | Zone 5 - Endpoint Zone |
| **한글명** | 엔드포인트 존 |
| **신뢰 수준** | Variable (사용자/디바이스별 상이) |
| **공격 노출도** | High |
| **버전** | v1.0.0 |

---

## 🎯 정의

Zone 5는 **최종 사용자 및 디바이스가 위치한 영역**으로, Zero Trust 원칙이 가장 중요한 구간입니다.

**핵심 역할**:
- **사용자 인터페이스**: 웹/모바일 애플리케이션 실행
- **데이터 입력**: 사용자 입력 및 파일 업로드
- **로컬 처리**: 클라이언트 측 로직 실행
- **디바이스 관리**: 보안 정책 적용

**보안 원칙**:
- **Zero Trust**: 모든 디바이스를 잠재적 위협으로 간주
- **지속적 검증**: 세션 중에도 지속적 인증
- **최소 데이터 저장**: 로컬 저장 최소화
- **보안 업데이트**: 정기 패치 및 업데이트

---

## 🏗️ Zone 5 아키텍처

### 논리적 배치

```
┌─────────────────────────────────────────────┐
│          Zone 5 (Endpoint)                  │
│                                             │
│  ┌────────────────────────────────────┐    │
│  │    웹 브라우저                       │    │
│  │  Chrome, Safari, Firefox, Edge      │    │
│  │                                     │    │
│  │  ┌─────────────────────────────┐   │    │
│  │  │  SPA (React, Vue, Angular)   │   │    │
│  │  └─────────────────────────────┘   │    │
│  └────────────────────────────────────┘    │
│                                             │
│  ┌────────────────────────────────────┐    │
│  │    모바일 앱                         │    │
│  │  iOS App, Android App               │    │
│  │                                     │    │
│  │  ┌─────────────────────────────┐   │    │
│  │  │  Native / React Native      │   │    │
│  │  └─────────────────────────────┘   │    │
│  └────────────────────────────────────┘    │
│                                             │
│  ┌────────────────────────────────────┐    │
│  │    Desktop 앱                        │    │
│  │  Electron, .NET, Qt                 │    │
│  └────────────────────────────────────┘    │
│                                             │
│  ┌────────────────────────────────────┐    │
│  │    IoT 디바이스                      │    │
│  │  Sensors, Gateways, Edge Devices    │    │
│  └────────────────────────────────────┘    │
└─────────────────────────────────────────────┘
                     ↓ HTTPS Only
┌─────────────────────────────────────────────┐
│          Zone 1 (Perimeter)                 │
│         CDN, WAF, Load Balancer             │
└─────────────────────────────────────────────┘
```

---

## 📊 배치 구성요소

### Very Common (필수 배치)

| 구성요소 | Platform | 목적 | 주요 기술 |
|---------|----------|------|----------|
| **웹 브라우저** | Cross-Platform | 웹 애플리케이션 실행 | Chrome, Safari, Firefox, Edge |
| **모바일 앱** | iOS, Android | 네이티브 모바일 경험 | Swift, Kotlin, React Native |

### Common (자주 배치)

| 구성요소 | Platform | 목적 | 주요 기술 |
|---------|----------|------|----------|
| **Desktop 앱** | Windows, macOS, Linux | 데스크톱 애플리케이션 | Electron, .NET, Qt |
| **VPN Client** | Cross-Platform | 안전한 원격 접근 | OpenVPN, WireGuard |

### Rare (특수 배치)

| 구성요소 | Platform | 목적 | 사용 사례 |
|---------|----------|------|----------|
| **IoT 디바이스** | Embedded | 센서, 제어 | 스마트 빌딩, 산업 IoT |
| **Kiosk 단말** | Dedicated Hardware | 공공 서비스 단말 | 공항, 은행, 병원 |
| **Edge Computing Device** | Embedded | 엣지 데이터 처리 | 자율주행, 스마트 시티 |

---

## 🔐 보안 정책

### 네트워크 정책

```yaml
인바운드 규칙:
  허용:
    - Zone 0 (인터넷) → Zone 5: 공개 웹사이트 접속
    - Zone 1 → Zone 5: HTTPS 응답
    - Zone 4 (Management) → Zone 5: 정책 배포 (MDM/EMM)

  차단:
    - Zone 2, 3 → Zone 5: 직접 연결 금지
    - 알 수 없는 출처 → Zone 5: 악성 코드

아웃바운드 규칙:
  허용:
    - Zone 5 → Zone 0 (인터넷): 웹 브라우징, 외부 서비스 접속
    - Zone 5 → Zone 1: HTTPS 요청 (내부 서비스)
    - Zone 5 → Zone 4: 로그/메트릭 전송 (Optional)

  차단:
    - Zone 5 → Zone 2, 3: 직접 접근 절대 금지
    - Zone 5 → 의심스러운 도메인: 악성 사이트

디바이스 정책:
  - 회사 소유 (Corporate): 엄격한 통제
  - BYOD (Bring Your Own Device): 제한적 접근
  - 게스트: 최소 권한
```

### 인증 정책

```yaml
사용자 인증:
  - Username + Password: 기본
  - Multi-Factor Authentication (MFA): 필수
    - TOTP (Google Authenticator, Authy)
    - Push Notification (Duo, Okta Verify)
    - Biometric (Face ID, Touch ID, Windows Hello)

디바이스 인증:
  - Device ID: 고유 식별자
  - Certificate: 디바이스 인증서
  - Compliance Check: 보안 정책 준수 확인

지속적 검증 (Continuous Verification):
  - 세션 중 디바이스 상태 모니터링
  - 위치 변경 감지 (IP, GPS)
  - 비정상 행동 탐지

세션 관리:
  - 타임아웃: 30분 (비활동 시)
  - 절대 타임아웃: 8시간
  - Refresh Token: 7일
```

### 로깅 정책

```yaml
로그 수집 범위:
  - 로그인/로그아웃 이벤트
  - 페이지 방문 (URL, 타임스탬프)
  - API 호출 (클라이언트 측)
  - 에러 및 크래시 리포트

로그 보존 기간:
  - 사용자 활동: 180일
  - 보안 이벤트: 1년
  - 크래시 리포트: 90일

개인정보 보호:
  - PII 수집 최소화
  - 로그 익명화 (사용자 동의 시)
  - GDPR 준수 (EU 사용자)
```

### 데이터 취급

```yaml
로컬 저장:
  - 최소 저장: 필요한 데이터만
  - 암호화: AES-256 (민감 데이터)
  - 자동 삭제: 로그아웃 시 또는 30일

클라이언트 측 암호화:
  - TLS/SSL: 전송 중 암호화
  - HTTPS Only: HTTP 차단
  - Certificate Pinning: 중간자 공격 방어

Cache 관리:
  - Cache-Control: no-store (민감 데이터)
  - LocalStorage: 비민감 데이터만
  - SessionStorage: 세션 한정

입력 검증:
  - 클라이언트 측 검증 (UX)
  - 서버 측 재검증 (보안)
  - XSS 방어: HTML 이스케이프
```

---

## 🚪 Zone 경계 통제

### Zone 5 → Zone 1 (아웃바운드)

```yaml
통제 메커니즘: HTTPS + SRI (Subresource Integrity)

보안 헤더:
  - Content-Security-Policy (CSP)
  - Strict-Transport-Security (HSTS)
  - X-Frame-Options: DENY
  - X-Content-Type-Options: nosniff

요청 검증:
  1. HTTPS 전용
  2. CORS 확인
  3. API Token 포함 (Authorization 헤더)
  4. Request ID (추적용)

악성 코드 방어:
  - Anti-Virus: 실시간 스캔
  - EDR (Endpoint Detection and Response)
  - Firewall: 아웃바운드 제한
```

### Zone 1 → Zone 5 (인바운드)

```yaml
통제 메커니즘: CDN + CSP

응답 보안:
  - HTTPS Only
  - SRI: 스크립트 무결성 검증
  - CSP: 허용된 소스만

컨텐츠 보호:
  - 난독화: JavaScript 코드 (선택적)
  - Minification: 크기 최소화
  - Source Map: 프로덕션에서 제거
```

---

## 💡 실전 배치 예시

### 예시 1: Startup (소규모)

```yaml
Zone 5 구성:
  - 웹 앱: React SPA (Cloudflare CDN)
  - 모바일 앱: React Native (iOS + Android)
  - 인증: Auth0 (소셜 로그인)

특징:
  - 클라우드 기반 (Serverless)
  - 빠른 배포
  - 최소 관리 부담

디바이스 정책:
  - BYOD 허용
  - 최소 보안 요구사항
  - MFA 권장

비용:
  - Cloudflare: $20/월
  - Auth0: $100/월
  - 모바일 빌드: $50/월
  - 총: ~$170/월

보안 수준: ⭐⭐⭐⚪⚪
```

### 예시 2: Mid-size Company (중견기업)

```yaml
Zone 5 구성:
  - 웹 앱: Vue.js SPA (CDN + WAF)
  - 모바일 앱: Native (Swift + Kotlin)
  - Desktop 앱: Electron
  - MDM (Mobile Device Management): Microsoft Intune

특징:
  - 멀티 플랫폼
  - 디바이스 관리
  - 보안 정책 강제

디바이스 정책:
  - 회사 소유 디바이스 우선
  - BYOD: 제한적 허용 (승인 필요)
  - Compliance Check: 자동

비용:
  - CDN + WAF: $500/월
  - MDM (Intune): $600/월 (100명 기준)
  - App Store: $200/월
  - 총: ~$1,300/월

보안 수준: ⭐⭐⭐⭐⚪
```

### 예시 3: Enterprise (대기업)

```yaml
Zone 5 구성:
  - 웹 앱: Angular (전용 CDN)
  - 모바일 앱: Native + MDM (MobileIron)
  - Desktop 앱: .NET (Windows), Qt (Mac/Linux)
  - IoT: Edge Computing (Azure IoT Edge)
  - Zero Trust: Okta + Duo + Conditional Access

특징:
  - 엔터프라이즈급 보안
  - 디바이스 완전 통제
  - 24/7 모니터링

디바이스 정책:
  - 회사 소유만 허용
  - BYOD 금지 (규제 산업)
  - Full Disk Encryption (FDE) 필수
  - Remote Wipe 가능

비용:
  - 전용 CDN: $5,000/월
  - MDM (MobileIron): $10,000/월 (1,000명 기준)
  - Zero Trust (Okta + Duo): $8,000/월
  - IoT Platform: $5,000/월
  - 총: ~$28,000/월

보안 수준: ⭐⭐⭐⭐⭐
```

---

## 🔄 Zone 5 사용자 흐름

### 웹 애플리케이션 (SPA)

```
사용자 (웹 브라우저)
    ↓ https://example.com
CDN (Zone 1) ← 정적 파일 (HTML, CSS, JS)
    ↓ 다운로드 (캐시 활용)
브라우저 ← React/Vue 앱 실행
    ↓ API 호출 (JWT Token)
API Gateway (Zone 1) ← 인증 검증
    ↓ 라우팅
API Server (Zone 2) ← 비즈니스 로직
    ↑ JSON 응답
브라우저 ← UI 업데이트
```

### 모바일 애플리케이션

```
사용자 (모바일 디바이스)
    ↓ 앱 실행
모바일 앱 ← 로컬 캐시 확인
    ↓ API 호출 (JWT Token)
API Gateway (Zone 1) ← 인증 검증
    ↓ 모바일 최적화 응답
API Server (Zone 2)
    ↑ JSON 응답 (압축)
모바일 앱 ← 데이터 표시 + 로컬 저장
```

---

## 🚨 Zone 5 인시던트 대응

### 시나리오 1: 디바이스 분실

```yaml
탐지:
  - 사용자 신고
  - 비정상 위치 접근 (GeoIP)

대응:
  1. 즉시: 세션 강제 종료
  2. 즉시: Remote Wipe (MDM)
  3. 분석: 접근 로그 검토
  4. 후속: 비밀번호 재설정 요청

복구:
  - 새 디바이스 등록
  - 복원 (클라우드 백업)
  - 보안 재교육

평균 대응 시간: 즉시 (자동)
```

### 시나리오 2: 악성 앱 설치

```yaml
탐지:
  - MDM 정책 위반 알림
  - Anti-Virus 탐지
  - 비정상 네트워크 트래픽

대응:
  1. 즉시: 디바이스 격리
  2. 분석: 악성 앱 식별
  3. 제거: MDM을 통한 원격 제거
  4. 검증: 보안 스캔 재실행

예방:
  - 앱 화이트리스트
  - 정기 보안 스캔
  - 사용자 교육

평균 대응 시간: 5-30분
```

### 시나리오 3: 피싱 공격

```yaml
탐지:
  - 의심스러운 로그인 시도
  - 비정상 API 호출 패턴
  - 사용자 신고

대응:
  1. 즉시: 계정 임시 차단
  2. 확인: MFA를 통한 사용자 확인
  3. 분석: 피싱 사이트 URL 수집
  4. 차단: 방화벽/WAF 차단 규칙 추가

복구:
  - 비밀번호 재설정
  - MFA 재등록
  - 보안 의식 교육

평균 대응 시간: 10-60분
```

---

## 📊 Zone 5 모니터링 메트릭

### 핵심 메트릭 (KPI)

```yaml
사용자 메트릭:
  - Active Users (일일, 월간)
  - Session Duration (평균)
  - Login Success Rate (%)

보안 메트릭:
  - Failed Login Attempts
  - MFA Adoption Rate (%)
  - Device Compliance Rate (%)

성능 메트릭:
  - Page Load Time (ms)
  - API Response Time (ms)
  - Crash Rate (%)

디바이스 메트릭:
  - OS Version Distribution
  - Browser/App Version
  - Device Type (모바일, 데스크톱)
```

### 분석 대시보드 예시

```yaml
Dashboard 1: 사용자 활동
  - Active Users (실시간)
  - Top 10 페이지
  - User Journey (퍼널)

Dashboard 2: 보안
  - Failed Login Map (지역별)
  - MFA 사용률
  - Device Compliance 현황

Dashboard 3: 성능
  - Page Load Time (p50, p95, p99)
  - API Latency
  - Crash Rate (버전별)

Dashboard 4: 디바이스
  - OS Distribution (iOS, Android, Windows, macOS)
  - Browser Distribution
  - Screen Size Distribution
```

---

## 🔧 Zone 5 최적화 기법

### 프론트엔드 최적화

```yaml
성능 최적화:
  - Code Splitting: 라우트별 분할
  - Lazy Loading: 이미지, 컴포넌트
  - Tree Shaking: 미사용 코드 제거
  - Minification: 코드 압축

네트워크 최적화:
  - CDN: 정적 파일 캐싱
  - HTTP/2: 멀티플렉싱
  - Compression: Gzip, Brotli

캐싱 전략:
  - Service Worker: 오프라인 지원
  - LocalStorage: 비민감 데이터
  - In-Memory Cache: 세션 데이터
```

### 모바일 앱 최적화

```yaml
성능:
  - Native 모듈: 성능 중요 부분
  - 이미지 최적화: WebP, 압축
  - 배터리 절약: 백그라운드 작업 최소화

보안:
  - Certificate Pinning: MITM 방어
  - Root Detection: 탈옥/루팅 감지
  - Code Obfuscation: 역공학 방어

사용자 경험:
  - Offline Mode: 기본 기능 제공
  - Push Notification: 적절한 사용
  - App Size: 최소화 (100MB 이하)
```

### Zero Trust 구현

```yaml
디바이스 신뢰 평가:
  - OS 버전: 최신 버전 권장
  - Security Patch: 필수 패치 확인
  - Anti-Virus: 최신 상태
  - Firewall: 활성화 필수

Conditional Access:
  - 디바이스 신뢰 점수 기반 접근 제어
  - 위치: 허용된 지역만
  - 시간: 업무 시간만 (선택적)
  - 네트워크: 회사 네트워크 우선

Step-Up Authentication:
  - 민감한 작업 시 재인증
  - 예: 비밀번호 변경, 결제, 데이터 다운로드
```

---

## 🔗 관련 문서

- [Security Zone 개요](../00_Security_Zone_개요.md)
- [Zone 1: Perimeter Zone](../Zone_1_Perimeter/00_Zone_1_정의.md)
- [Zone 2: Application Zone](../Zone_2_Application/00_Zone_2_정의.md)
- [Frontend 구성요소](../../01_차원1_Deployment_Layer/Layer_7_Application/01_Frontend/00_Frontend_정의.md)
- [Mobile Backend 구성요소](../../01_차원1_Deployment_Layer/Layer_7_Application/06_Mobile_Backend/00_Mobile_Backend_정의.md)

---

**문서 끝**
