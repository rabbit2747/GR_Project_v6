# Zone 0-A: Untrusted External (비신뢰 외부 영역)

## 📋 문서 정보

**Zone**: 0-A - Untrusted External
**영문명**: Untrusted External Zone
**한글명**: 비신뢰 외부 영역
**위치**: 조직 외부 (인터넷)
**신뢰 수준**: None (0%)
**작성일**: 2025-01-20
**v2.0 상태**: 🆕 신규 (Zone 0 세분화)

---

## 🎯 Zone 정의

### 개요

**Zone 0-A (Untrusted External)**는 **조직이 전혀 통제할 수 없는 완전 비신뢰 영역**입니다.

```yaml
핵심 특징:
  - 우리가 통제 불가능한 공간
  - 익명성이 높음
  - 악의적 행위자 존재 가능
  - 대규모 트래픽 발생원
  - 신뢰 수준: 0% (완전 비신뢰)
```

### v2.0 주요 변경

```yaml
기존 (v1.0):
  - Zone 0: External/Internet Zone (단일)
  - 모든 외부 요소를 하나로 통합

v2.0 세분화:
  - Zone 0-A: Untrusted External (일반 인터넷)
  - Zone 0-B: Trusted Partner (신뢰 외부 서비스)
  - 보안 정책 차별화 가능
```

---

## 📦 Zone 0-A 구성요소

### 1. 일반 인터넷 사용자

**특성**:
```yaml
익명 사용자:
  - 신원 미확인
  - IP 주소만 식별 가능
  - 지리적 위치 다양
  - VPN, Proxy 사용 가능

행동 패턴:
  - 웹사이트 방문
  - API 호출 (공개 API)
  - 서비스 이용
  - 검색 엔진 크롤링

보안 고려사항:
  - 모든 요청을 잠재적 위협으로 간주
  - Rate Limiting 필수
  - 입력 값 철저한 검증
```

**Function Tags**:
- Primary: `N/A` (우리가 태그를 부여할 수 없음)
- 대신 Zone 1에서 유입 트래픽 분류

---

### 2. 악의적 행위자

**유형**:
```yaml
공격자 (Attacker):
  - 취약점 스캐너
  - SQL Injection 시도
  - XSS 공격
  - DDoS 공격 주체

봇넷 (Botnet):
  - 대규모 분산 공격
  - 스팸 전송
  - 브루트 포스 공격
  - 크레덴셜 스터핑

악성 크롤러:
  - 무단 데이터 수집
  - 서비스 부하 유발
  - 취약점 탐지
```

**위협 수준**:
- Critical: DDoS, 제로데이 공격
- High: 자동화된 스캔, 브루트 포스
- Medium: 단순 취약점 스캔
- Low: 의심스러운 크롤링

---

### 3. 합법적 봇 & 크롤러

**유형**:
```yaml
검색 엔진:
  - Googlebot
  - Bingbot
  - Yandex Bot
  - 목적: 웹사이트 색인

소셜 미디어:
  - FacebookBot (Link Preview)
  - TwitterBot (Card Validator)
  - LinkedInBot
  - 목적: 링크 미리보기 생성

모니터링 봇:
  - Uptime Robot
  - Pingdom
  - 목적: 서비스 가용성 체크
```

**허용 정책**:
- User-Agent 확인 → Allowlist 기반 허용
- robots.txt 준수 여부 확인
- Rate Limiting (봇별 제한)

---

## 🔐 Zone 0-A 보안 정책

### 신뢰 수준

```yaml
신뢰 수준: None (0%)
  - 완전 비신뢰 영역
  - 모든 트래픽을 잠재적 위협으로 간주
  - Zero Trust: Never Trust, Always Verify

기본 원칙:
  - 모든 요청 검증 필수
  - 최소 권한 접근만 허용
  - 철저한 로깅 및 모니터링
  - 이상 징후 자동 차단
```

### 접근 통제

```yaml
허용되는 접근:
  - Zone 1 (Perimeter)로만 접근 가능
  - HTTPS 프로토콜만 허용
  - 공개 API Endpoint만 노출
  - Rate Limiting 적용

차단되는 접근:
  - Zone 2, 3, 4, 5 직접 접근 절대 차단
  - 비표준 포트 접근 차단
  - 의심스러운 User-Agent 차단
  - 알려진 악성 IP 차단
```

### 방어 전략

```yaml
Layer 1: DDoS Protection
  - Cloudflare DDoS Protection
  - AWS Shield
  - Rate Limiting (per IP, per Endpoint)
  - SYN Flood, UDP Flood 방어

Layer 2: WAF (Web Application Firewall)
  - OWASP Top 10 방어
  - SQL Injection 차단
  - XSS (Cross-Site Scripting) 차단
  - CSRF (Cross-Site Request Forgery) 차단

Layer 3: Bot Management
  - Bot Detection (User-Agent, 행동 패턴)
  - CAPTCHA Challenge
  - Browser Fingerprinting
  - IP Reputation 기반 차단

Layer 4: Threat Intelligence
  - 외부 위협 인텔리전스 연동
  - 알려진 악성 IP 차단
  - 지리적 위치 기반 차단 (Geo-blocking)
  - Honeypot 운영
```

---

## 🚫 Zone 0-A → Zone 1 통제

### 허용되는 트래픽

```yaml
프로토콜:
  - HTTPS (443)
  - HTTP (80) → HTTPS로 자동 리다이렉트

요청 유형:
  - 웹사이트 접근 (GET, POST)
  - 공개 API 호출 (REST, GraphQL)
  - Webhook (등록된 서비스만)

검증 항목:
  - TLS 1.2 이상
  - 유효한 HTTP Method
  - Content-Type 검증
  - 요청 크기 제한 (예: 10MB)
```

### 차단되는 트래픽

```yaml
절대 차단:
  - 비표준 포트 접근 (SSH 22, RDP 3389 등)
  - 알려진 악성 IP (위협 인텔리전스)
  - 비정상적인 User-Agent
  - 과도한 요청 (Rate Limit 초과)

의심 행위:
  - SQL 패턴 포함 요청
  - 경로 탐색 시도 (Path Traversal)
  - 파일 업로드 악용 시도
  - 헤더 조작 시도
```

---

## 📊 실전 예시

### 예시 1: 일반 웹사이트 접근

```yaml
Zone 0-A → Zone 1:
  사용자: 일반 인터넷 사용자
  요청: https://example.com

  Zone 1 (CDN/WAF):
    1. DDoS Protection ✅
    2. WAF 규칙 체크 ✅
    3. Rate Limiting 체크 ✅
    4. 정상 트래픽으로 판단

  → Zone 2 (API Server)로 전달
```

### 예시 2: 공격 시도

```yaml
Zone 0-A → Zone 1:
  공격자: 악의적 행위자
  요청: https://example.com/api?id=1' OR '1'='1

  Zone 1 (WAF):
    1. SQL Injection 패턴 감지 ❌
    2. 요청 차단
    3. IP 주소 블랙리스트 추가
    4. SIEM (Zone 4) 알림

  → 차단, 로그 기록
```

### 예시 3: DDoS 공격

```yaml
Zone 0-A → Zone 1:
  봇넷: 10,000 IP에서 동시 요청
  요청: https://example.com (초당 10만 요청)

  Zone 1 (DDoS Protection):
    1. 비정상 트래픽 감지 ❌
    2. Rate Limiting 발동
    3. CAPTCHA Challenge
    4. 지속 시 IP 블랙리스트

  → 대부분 차단, 정상 사용자 보호
```

---

## 🔍 Zone 0-A 분류 기준

### 자동 분류

새로운 접근이 Zone 0-A에 해당하는지 판단:

```yaml
질문 1: "이 접근의 출처를 우리가 통제할 수 있는가?"
  NO → Zone 0-A 가능성 높음
  YES → Zone 1-5 중 하나

질문 2: "이 접근이 계약 기반 신뢰 관계가 있는가?"
  NO → Zone 0-A
  YES → Zone 0-B

질문 3: "이 접근이 인증되었는가?"
  NO → Zone 0-A
  YES → Zone 0-B 또는 Zone 5 (내부 사용자)

결론:
  - 통제 불가 + 계약 없음 + 인증 없음 → Zone 0-A
```

### 판단 예시

| 접근 주체 | 통제 가능 | 계약 관계 | 인증 | Zone |
|---------|---------|---------|-----|------|
| 일반 인터넷 사용자 | ❌ | ❌ | ❌ | Zone 0-A |
| Google 검색 봇 | ❌ | ❌ | ❌ | Zone 0-A |
| 공격자 | ❌ | ❌ | ❌ | Zone 0-A |
| OpenAI API | ❌ | ✅ | ✅ | Zone 0-B |
| Salesforce SaaS | ❌ | ✅ | ✅ | Zone 0-B |
| 내부 직원 | ✅ | ✅ | ✅ | Zone 5 |

---

## 🔒 데이터 취급 원칙

### Zone 0-A로 전송되는 데이터

```yaml
허용:
  - 공개 정보 (웹사이트 콘텐츠)
  - 마케팅 자료
  - 공개 API 응답 (비민감)

금지:
  - 개인 식별 정보 (PII)
  - 비즈니스 기밀
  - 인증 토큰
  - 내부 시스템 정보
  - 데이터베이스 스키마

암호화:
  - 모든 전송은 HTTPS (TLS 1.2+)
  - 민감 정보는 절대 전송 금지
  - 에러 메시지에 내부 정보 노출 금지
```

### Zone 0-A로부터 수신되는 데이터

```yaml
검증 필수:
  - 입력 값 Sanitization
  - SQL Injection 패턴 체크
  - XSS 패턴 체크
  - 파일 업로드 검증 (MIME Type, 크기)

신뢰하지 않음:
  - HTTP 헤더 (User-Agent, Referer)
  - 쿠키 값
  - 쿼리 파라미터
  - POST Body
```

---

## 📋 모니터링 및 로깅

### 로그 수집

```yaml
Zone 0-A 자체:
  수집: 불가능 (우리가 통제하지 못함)

Zone 1에서 수집 (Zone 0-A 유입 트래픽):
  - 요청 시간, IP 주소, User-Agent
  - 요청 URL, HTTP Method
  - 응답 코드, 응답 시간
  - WAF 룰 매칭 결과
  - DDoS Protection 상태

로그 보존:
  - 정상 트래픽: 30일
  - 차단된 트래픽: 90일
  - 보안 사고: 1년 이상
```

### 알람 설정

```yaml
Critical (즉시 대응):
  - DDoS 공격 감지
  - 제로데이 취약점 공격 시도
  - 대량 데이터 유출 시도

High (30분 내 대응):
  - 반복된 SQL Injection 시도
  - 브루트 포스 공격
  - 비정상적인 트래픽 패턴

Medium (1시간 내 검토):
  - Rate Limit 임계값 도달
  - 의심스러운 User-Agent
  - 지리적 이상 접근 (평소와 다른 국가)
```

---

## ✅ 체크리스트

### 방어 체계

- [ ] DDoS Protection 설정 (Cloudflare, AWS Shield)
- [ ] WAF 규칙 적용 (OWASP Top 10)
- [ ] Rate Limiting 설정 (per IP, per Endpoint)
- [ ] Bot Detection 활성화
- [ ] 위협 인텔리전스 연동

### 모니터링

- [ ] 실시간 트래픽 대시보드 (Grafana)
- [ ] SIEM 연동 (Zone 4)
- [ ] 알람 룰 설정 (Critical, High, Medium)
- [ ] 로그 보존 정책 (30일 이상)

### 데이터 보호

- [ ] HTTPS Only 정책
- [ ] 민감 정보 노출 검증
- [ ] 에러 메시지 최소화
- [ ] 공개 API 문서화

---

## 🔗 관련 문서

- [차원 2: Security Zone 개요](./00_차원2_개요.md)
- [Zone 0-B: Trusted Partner](./Zone_0-B_Trusted_Partner.md)
- [Zone 1: Perimeter Zone](./Zone_1_Perimeter.md)
- [Layer 2: Network Infrastructure](../01_차원1_Deployment_Layer/Layer_2_Network.md)

---

## 📞 변경 이력

**v2.0 (2025-01-20)** - 신규 작성:
- ✅ Zone 0 세분화 (0-A 신규)
- ✅ 완전 비신뢰 영역 정의
- ✅ 방어 전략 (DDoS, WAF, Bot Management)
- ✅ Zone 0-A vs. 0-B 분류 기준

---

**문서 끝**
