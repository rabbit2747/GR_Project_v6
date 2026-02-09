# Zone 0-B: Trusted Partner (신뢰 파트너 영역)

## 📋 문서 정보

**Zone**: 0-B - Trusted Partner
**영문명**: Trusted Partner Zone
**한글명**: 신뢰 파트너 영역
**위치**: 조직 외부 (신뢰 서비스 제공자)
**신뢰 수준**: Very Low (10%)
**작성일**: 2025-01-20
**v2.0 상태**: 🆕 신규 (Zone 0 세분화)

---

## 🎯 Zone 정의

### 개요

**Zone 0-B (Trusted Partner)**는 **계약 기반으로 제한적 신뢰를 부여할 수 있는 외부 서비스 제공자 영역**입니다.

```yaml
핵심 특징:
  - 계약 관계 (SLA, DPA)
  - 보안 인증서 보유 (SOC 2, ISO 27001)
  - API 기반 통합
  - 사용량 모니터링 가능
  - 신뢰 수준: 10% (제한적 신뢰)
```

### v2.0 주요 변경

```yaml
기존 (v1.0):
  - Zone 0: External/Internet Zone
  - 모든 외부 서비스를 하나로 통합
  - 차별화된 보안 정책 불가

v2.0 세분화:
  - Zone 0-A: Untrusted External (일반 인터넷)
  - Zone 0-B: Trusted Partner (신뢰 외부 서비스)
  - 보안 정책, 비용 관리 차별화
```

### Zone 0-A vs. Zone 0-B

```yaml
Zone 0-A (Untrusted):
  - 익명 접근
  - 계약 관계 없음
  - 완전 비신뢰 (0%)
  - 예: 일반 인터넷 사용자, 공격자

Zone 0-B (Trusted Partner):
  - 계약 기반 신뢰
  - SLA 보장
  - 제한적 신뢰 (10%)
  - 예: OpenAI API, Salesforce, Stripe
```

---

## 📦 Zone 0-B 구성요소

### 1. Public LLM & AI API

**대표 서비스**:
```yaml
LLM 추론:
  - OpenAI: GPT-4, GPT-3.5, GPT-4-turbo
  - Anthropic: Claude 3 Opus, Sonnet, Haiku
  - Google: Gemini Pro, Gemini Ultra
  - Cohere: Command, Command-R

임베딩 & 벡터:
  - OpenAI: text-embedding-ada-002, text-embedding-3
  - Cohere: embed-multilingual
  - Voyage AI: voyage-2

특징:
  - API Key 인증
  - 사용량 기반 과금
  - Rate Limiting
  - SLA 제공 (가용성 99.9%+)
```

**Function Tags** (Layer 0):
- Primary: `A7.1` (LLM Inference)
- Secondary: `D5.1` (Vector Embeddings)
- Interface: `I1.1` (HTTP/REST API)

**보안 고려사항**:
```yaml
데이터 민감도:
  ❌ 금지: 고객 PII, 비즈니스 기밀
  ✅ 허용: 일반 텍스트, 공개 정보

비용 관리:
  - 월간 사용량 모니터링 필수
  - Rate Limit 설정 (per User, per Org)
  - 캐싱 전략 (중복 요청 방지)

데이터 보호:
  - TLS 1.2+ 암호화 필수
  - API Key Rotation (3개월)
  - 사용 로그 보존 (90일)
```

---

### 2. SaaS (Software as a Service)

**대표 서비스**:
```yaml
CRM:
  - Salesforce
  - HubSpot
  - Zoho CRM

협업 도구:
  - Google Workspace (Gmail, Drive, Docs)
  - Microsoft 365 (Outlook, SharePoint)
  - Slack
  - Notion

마케팅:
  - Mailchimp
  - SendGrid (Email)
  - Twilio (SMS)
```

**Function Tags** (Layer 0):
- Primary: `A1.5` (SaaS Application)
- Interface: `I1.1` (HTTP/REST), `I1.2` (GraphQL)

**보안 고려사항**:
```yaml
인증:
  - OAuth 2.0 / OIDC
  - API Key (환경 변수 저장)
  - IP Allowlist (선택적)

데이터 처리:
  - DPA (Data Processing Agreement) 체결
  - GDPR, CCPA 준수 확인
  - 데이터 위치 (EU, US, Asia) 확인

SLA:
  - 가용성: 99.9% 이상
  - 응답 시간: <500ms
  - 지원: 24/7 또는 업무 시간
```

---

### 3. Payment Gateway (결제 게이트웨이)

**대표 서비스**:
```yaml
글로벌:
  - Stripe
  - PayPal
  - Square

한국:
  - Toss Payments
  - KG 이니시스
  - NHN KCP
```

**Function Tags** (Layer 0):
- Primary: `A2.1` (Payment Processing)
- Secondary: `C1.1` (PCI-DSS Compliance)
- Interface: `I1.1` (HTTP/REST API)

**보안 고려사항**:
```yaml
PCI-DSS 준수:
  - Level 1 인증서 확인
  - 카드 정보 절대 저장 금지
  - Tokenization 사용

데이터 흐름:
  - 결제 정보: 브라우저 → Payment Gateway 직접 전송
  - 우리 서버: Token만 수신
  - 카드 번호 절대 로깅 금지

모니터링:
  - 결제 성공률 모니터링
  - 실패 원인 분석
  - 이상 거래 탐지
```

---

### 4. CDN (Content Delivery Network)

**대표 서비스**:
```yaml
글로벌 CDN:
  - Cloudflare
  - Fastly
  - Akamai
  - AWS CloudFront

특징:
  - 정적 콘텐츠 캐싱
  - DDoS 방어
  - WAF 기능
  - SSL/TLS 종료
```

**Function Tags** (Layer 0):
- Primary: `N3.1` (CDN)
- Secondary: `S5.1` (DDoS Protection)
- Interface: `I1.1` (HTTP/HTTPS)

**보안 고려사항**:
```yaml
캐싱 정책:
  - 공개 콘텐츠만 캐싱
  - 민감 정보 캐싱 금지
  - Cache-Control 헤더 설정

DDoS 방어:
  - Layer 3/4/7 보호
  - Rate Limiting
  - IP Reputation

SSL/TLS:
  - TLS 1.2+ 필수
  - HSTS 활성화
  - Certificate Pinning (선택적)
```

---

### 5. 외부 인증 제공자

**대표 서비스**:
```yaml
Enterprise SSO:
  - Okta
  - Auth0
  - Azure AD (Enterprise)

소셜 로그인:
  - Google OAuth
  - GitHub OAuth
  - Facebook Login
```

**Function Tags** (Layer 0):
- Primary: `S2.3` (SSO - Single Sign-On)
- Secondary: `S2.2` (MFA)
- Interface: `I1.4` (OAuth 2.0/OIDC)

**보안 고려사항**:
```yaml
인증 흐름:
  - Authorization Code Flow (PKCE)
  - State Parameter 검증
  - ID Token 검증

토큰 관리:
  - Access Token: 짧은 만료 시간 (1시간)
  - Refresh Token: 보안 저장, Rotation
  - ID Token: 서명 검증 필수

감사:
  - 로그인 이력 기록
  - 이상 로그인 탐지 (Impossible Travel)
  - MFA 사용 권장
```

---

## 🔐 Zone 0-B 보안 정책

### 신뢰 수준

```yaml
신뢰 수준: Very Low (10%)
  - 계약 기반 제한적 신뢰
  - SLA 및 보안 인증서 보유
  - 정기 보안 감사 필요

신뢰 조건:
  - 명시적 서비스 계약 체결
  - SLA 보장 (가용성, 성능, 보안)
  - 보안 인증서 (SOC 2, ISO 27001)
  - GDPR, CCPA 준수
  - API 인증 체계 (API Key, OAuth)

주의 사항:
  - 신뢰하되 검증 (Trust but Verify)
  - 민감 데이터 전송 최소화
  - 사용량 및 비용 모니터링
  - 정기 보안 리뷰 (분기별)
```

### Zone 0-B 진입 기준

```yaml
필수 조건 (모두 충족):
  1. 계약 관계: 명시적 서비스 계약
  2. SLA 보장: 가용성, 성능, 보안 SLA
  3. 보안 인증: SOC 2, ISO 27001, PCI-DSS 중 1개 이상
  4. 데이터 보호: GDPR, CCPA 준수
  5. API 인증: API Key, OAuth 등 인증 체계

선택 조건 (권장):
  - Bug Bounty Program 운영
  - 보안 사고 대응 계획 (Incident Response)
  - 정기 보안 감사 보고서 제공
  - 데이터 처리 계약 (DPA)
```

---

## 🚫 Zone 0-B ↔ Zone 간 통제

### Zone 0-B → Zone 1 (인바운드)

```yaml
허용:
  - Webhook (등록된 서비스만)
  - CDN → Origin Server 요청
  - 외부 인증 Provider → Callback

검증:
  - Webhook Secret 검증
  - IP Allowlist (선택적)
  - Signature 검증 (HMAC)
  - TLS 1.2+ 필수

예시:
  - Stripe Webhook (결제 완료 알림)
  - Salesforce → 우리 API (데이터 동기화)
  - Auth0 → Callback Endpoint
```

### Zone 2 → Zone 0-B (아웃바운드)

```yaml
허용:
  - LLM API 호출 (OpenAI, Claude)
  - SaaS API 호출 (Salesforce, Slack)
  - Payment API 호출 (Stripe)
  - CDN 캐시 무효화 (Purge)

검증:
  - API Key 환경 변수 저장
  - Rate Limiting (per Org)
  - Timeout 설정 (10초)
  - Retry 정책 (Exponential Backoff)

예시:
  - Zone 2 (API Server) → OpenAI API (GPT-4)
  - Zone 2 (App Server) → Stripe API (결제 처리)
  - Zone 2 (Backend) → Salesforce API (CRM 업데이트)
```

### Zone 4 → Zone 0-B (관리)

```yaml
허용:
  - 위협 인텔리전스 수집
  - 보안 업데이트 확인
  - 외부 SIEM 연동

검증:
  - API Key Rotation
  - HTTPS Only
  - Audit Logging

예시:
  - SIEM (Zone 4) → 외부 위협 인텔리전스 (Zone 0-B)
  - Monitoring (Zone 4) → PagerDuty (Zone 0-B)
```

---

## 📊 실전 예시

### 예시 1: AI 기반 고객 지원 (LLM API)

```yaml
흐름:
  사용자 (Zone 5) → Zone 1 → Zone 2 (API Server)
  ↓
  Zone 2 → Zone 0-B (OpenAI API - GPT-4)
  ↓
  Zone 0-B → Zone 2 (LLM Response)
  ↓
  Zone 2 → Zone 1 → 사용자 (Zone 5)

보안 고려사항:
  - PII 데이터 LLM 전송 금지
  - 사용자 입력 Sanitization
  - LLM 응답 필터링 (민감 정보 마스킹)
  - 비용 모니터링 (월 $10,000 임계값)

데이터 흐름:
  ✅ 허용: "사용자 ID U12345의 주문 분석해줘"
  ❌ 금지: "홍길동(주민번호: 123456-1234567)의 주문 분석해줘"
```

### 예시 2: 결제 처리 (Stripe)

```yaml
흐름:
  사용자 (Zone 5 - 브라우저)
  ↓ 카드 정보 입력
  Zone 0-B (Stripe.js - 직접 전송)
  ↓ Payment Token 반환
  Zone 5 (브라우저) → Zone 1 → Zone 2 (API Server)
  ↓ Token 전달
  Zone 2 → Zone 0-B (Stripe API - 결제 처리)
  ↓ 결제 결과
  Zone 2 → Zone 3 (주문 DB 저장)

보안 고려사항:
  - 카드 정보는 절대 우리 서버를 거치지 않음
  - PCI-DSS 준수 (Stripe에 위임)
  - Token만 우리 서버에서 처리
  - 결제 로그 암호화 저장
```

### 예시 3: CRM 동기화 (Salesforce)

```yaml
흐름:
  Zone 2 (App Server) → Zone 0-B (Salesforce API)
  ↓ 고객 정보 업데이트 (매 1시간)
  Zone 0-B → Zone 2 (성공/실패)

보안 고려사항:
  - OAuth 2.0 인증 (Client Credentials)
  - Refresh Token Rotation
  - 동기화 실패 시 Retry (최대 3회)
  - 동기화 이력 로깅

데이터 보호:
  - DPA (Data Processing Agreement) 체결
  - GDPR 준수 (EU 데이터센터 사용)
  - 민감 필드 암호화 전송
```

---

## 🔍 Zone 0-B 분류 기준

### 자동 분류 결정 트리

```yaml
1단계: "이 서비스를 우리가 직접 운영하는가?"
  YES → Zone 1-5 (내부)
  NO → 2단계로

2단계: "계약 관계가 있는가?"
  NO → Zone 0-A (Untrusted)
  YES → 3단계로

3단계: "SLA 및 보안 인증서가 있는가?"
  NO → Zone 0-A (Untrusted)
  YES → 4단계로

4단계: "API 인증 체계가 있는가?"
  NO → Zone 0-A (Untrusted)
  YES → Zone 0-B (Trusted Partner)
```

### 판단 예시

| 서비스 | 계약 | SLA | 인증서 | API 인증 | Zone |
|-------|-----|-----|-------|---------|------|
| OpenAI API | ✅ | ✅ | SOC 2 | API Key | Zone 0-B |
| Salesforce | ✅ | ✅ | ISO 27001 | OAuth | Zone 0-B |
| Stripe | ✅ | ✅ | PCI-DSS L1 | API Key | Zone 0-B |
| 일반 인터넷 사용자 | ❌ | ❌ | ❌ | ❌ | Zone 0-A |
| 의심스러운 SaaS | ✅ | ❌ | ❌ | ❌ | Zone 0-A |

---

## 🔒 데이터 취급 원칙

### Zone 0-B로 전송 가능한 데이터

```yaml
허용 (서비스별):
  LLM API:
    ✅ 일반 텍스트, 공개 정보
    ❌ PII, 비즈니스 기밀

  SaaS (Salesforce, Slack):
    ✅ 비즈니스 데이터 (DPA 체결 시)
    ⚠️ PII (암호화 + GDPR 준수)
    ❌ 결제 정보, 비밀번호

  Payment Gateway:
    ✅ Payment Token, 주문 금액
    ❌ 원본 카드 번호 (PCI-DSS 위반)

  CDN:
    ✅ 공개 정적 콘텐츠 (이미지, CSS, JS)
    ❌ 사용자별 민감 데이터
```

### Zone 0-B로부터 수신되는 데이터

```yaml
검증 필수:
  - API 응답 Signature 검증 (Webhook)
  - Schema Validation (예상 형식과 일치)
  - Rate Limit 체크 (과도한 요청 방지)

신뢰하되 검증:
  - LLM 응답: Prompt Injection 필터링
  - Payment 결과: 금액 일치 확인
  - SaaS 데이터: 비즈니스 로직 검증
```

---

## 📋 비용 및 사용량 관리

### 비용 모니터링

```yaml
LLM API:
  - 월간 예산: $10,000
  - 알람: 80% 도달 시
  - 임계값: 100% 시 자동 차단
  - 추적: Token 사용량 (per User, per Feature)

SaaS:
  - 사용자 수 기반 과금 모니터링
  - 불필요한 라이선스 제거
  - 사용률 분석 (월별)

Payment Gateway:
  - 거래 수수료 추적
  - 환불 비율 모니터링
  - 실패 원인 분석
```

### 사용량 최적화

```yaml
캐싱 전략:
  LLM API:
    - 동일 질문 캐싱 (Redis)
    - 유사 질문 Vector 검색
    - Cache Hit율 목표: 40%

  SaaS API:
    - Bulk API 사용 (개별 호출 최소화)
    - Webhook 활용 (Polling 대신)
    - Delta Sync (전체 동기화 대신)
```

---

## ✅ 체크리스트

### 계약 및 준수

- [ ] 서비스 계약 체결 (SLA 포함)
- [ ] DPA (Data Processing Agreement) 체결
- [ ] 보안 인증서 확인 (SOC 2, ISO 27001)
- [ ] GDPR, CCPA 준수 확인

### 보안

- [ ] API Key 환경 변수 저장
- [ ] API Key Rotation (3개월)
- [ ] Rate Limiting 설정
- [ ] Webhook Secret 검증
- [ ] TLS 1.2+ 사용 확인

### 모니터링

- [ ] 사용량 모니터링 (일별, 월별)
- [ ] 비용 알람 설정 (80%, 100%)
- [ ] 에러율 모니터링 (<1%)
- [ ] SLA 모니터링 (가용성 99.9%)

### 데이터 보호

- [ ] PII 데이터 전송 최소화
- [ ] 민감 정보 암호화
- [ ] 사용 로그 보존 (90일)
- [ ] 정기 보안 리뷰 (분기별)

---

## 🔗 관련 문서

- [차원 2: Security Zone 개요](./00_차원2_개요.md)
- [Zone 0-A: Untrusted External](./Zone_0-A_Untrusted.md)
- [Zone 1: Perimeter Zone](./Zone_1_Perimeter.md)
- [Layer 0: External Services](../01_차원1_Deployment_Layer/Layer_0_External.md)

---

## 📞 변경 이력

**v2.0 (2025-01-20)** - 신규 작성:
- ✅ Zone 0 세분화 (0-B 신규)
- ✅ 신뢰 파트너 영역 정의 (10% 신뢰)
- ✅ LLM API, SaaS, Payment Gateway, CDN 분류
- ✅ 계약 기반 신뢰 체계
- ✅ 비용 및 사용량 관리 전략

---

**문서 끝**
