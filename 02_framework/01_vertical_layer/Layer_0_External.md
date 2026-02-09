# Layer 0: External Services (외부 서비스)

## 📋 문서 정보

**Layer**: 0 - External Services
**영문명**: External Services
**한글명**: 외부 서비스
**위치**: 우리 인프라 외부
**목적**: 우리가 직접 통제하지 못하는 외부 제공 서비스 분류
**v2.0 신설**: ✅ GR Framework v2.0에서 추가
**작성일**: 2025-01-20

---

## 🎯 Layer 정의

### 개요

**Layer 0 (External Services)**는 우리가 직접 관리하거나 통제하지 못하는 **외부 공급자가 제공하는 서비스**를 분류하는 계층입니다.

### 핵심 개념

```yaml
핵심 특징:
  - 외부 공급자가 운영 및 관리
  - SLA 계약 기반 제한적 신뢰
  - 우리는 API 클라이언트로서 사용만 가능
  - 장애 발생 시 우리가 직접 복구 불가능

통제 수준: 제한적 (0-20%)
  - 서비스 가용성: 외부 공급자 통제
  - 데이터 저장소: 외부 인프라
  - 보안 정책: 외부 공급자 정책 준수 필요
```

### Layer 0 신설 배경 (v2.0)

**왜 Layer 0이 필요한가?**

1. **외부 의존성 명확화**
   - 전통적 Layer 1-7은 "우리가 통제하는 인프라" 가정
   - SaaS, Public LLM 등 외부 서비스 증가 추세
   - 의존성 및 위험 명확히 식별 필요

2. **보안 위험 관리**
   - Zone 0-B (Trusted Partner)로 분류
   - 데이터 유출, 서비스 중단 위험 인식
   - 백업 전략 및 대체 계획 수립 근거

3. **아키텍처 투명성**
   - 시스템 다이어그램에 외부 서비스 명시
   - Dependency 추적 용이
   - 비용 및 벤더 락인 위험 가시화

---

## 📦 External Services 분류

### 1. SaaS (Software as a Service)

**정의**: 완전 관리형 소프트웨어 서비스

**대표 서비스**:
```yaml
업무 협업:
  - Slack, Microsoft Teams, Zoom
  - Google Workspace (Gmail, Drive, Docs)
  - Notion, Confluence, Jira

CRM & 영업:
  - Salesforce, HubSpot, Zendesk
  - Pipedrive, Intercom

HR & 급여:
  - Workday, BambooHR, Gusto
  - Rippling, Greenhouse
```

**Function Tags**:
- Primary: `A6.1` (SaaS Application)
- Interface: `I1.1` (HTTP/REST API)

**Zone 배치**: Zone 0-B (Trusted Partner)

---

### 2. Public LLM & AI API

**정의**: 외부 제공 대규모 언어 모델 및 AI 추론 API

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

전문 AI:
  - Stability AI: Stable Diffusion (이미지 생성)
  - ElevenLabs: TTS (음성 합성)
  - AssemblyAI: STT (음성 인식)
```

**Function Tags**:
- Primary: `A7.1` (LLM Inference)
- Secondary: `D5.1` (Vector Embeddings)
- Interface: `I1.1` (HTTP/REST API)

**Zone 배치**: Zone 0-B (Trusted Partner)

**보안 고려사항**:
```yaml
데이터 민감도:
  - 주의: 고객 PII, 비즈니스 기밀 전송 금지
  - 허용: 일반 텍스트, 공개 정보

비용 관리:
  - 월간 사용량 모니터링 필수
  - Rate Limit 설정
  - 캐싱 전략 (중복 요청 방지)

벤더 락인:
  - 프롬프트 표준화 (모델 교체 용이성)
  - 추상화 레이어 (LangChain, LlamaIndex)
```

---

### 3. Payment Gateway (결제 게이트웨이)

**정의**: 온라인 결제 처리 서비스

**대표 서비스**:
```yaml
글로벌:
  - Stripe (카드 결제, 구독 관리)
  - PayPal (간편 결제)
  - Square (POS + 온라인 결제)
  - Adyen (다국가 결제)

한국:
  - Toss Payments (간편 결제)
  - KG Inicis, NHN KCP (PG 서비스)
  - Kakao Pay, Naver Pay (간편 결제)
```

**Function Tags**:
- Primary: `A5.1` (Payment Processing)
- Control: `S6.1` (PCI-DSS Compliance)
- Interface: `I1.1` (HTTP/REST API)

**Zone 배치**: Zone 0-B (Trusted Partner)

**컴플라이언스**:
- PCI-DSS Level 1 인증 필수
- Tokenization 사용 (카드 정보 비저장)
- 3D Secure 지원

---

### 4. CDN (Content Delivery Network)

**정의**: 글로벌 콘텐츠 배포 네트워크

**대표 서비스**:
```yaml
글로벌 CDN:
  - Cloudflare (CDN + WAF + DDoS 방어)
  - Fastly (실시간 CDN)
  - Akamai (엔터프라이즈 CDN)
  - AWS CloudFront (AWS 통합)

한국 CDN:
  - CDNetworks
  - 가비아 CDN
```

**Function Tags**:
- Primary: `N3.1` (Content Caching)
- Secondary: `S1.3` (DDoS Protection)
- Interface: `I1.1` (HTTP/HTTPS)

**Zone 배치**: Zone 0-B (Trusted Partner)

---

### 5. External API Services

**정의**: 특정 기능을 제공하는 외부 API

**대표 서비스**:
```yaml
지도 & 위치:
  - Google Maps API, Kakao Map API
  - Mapbox, HERE Maps

통신:
  - Twilio (SMS, Voice, Video)
  - SendGrid (이메일 발송)
  - Mailgun, AWS SES

인증:
  - Auth0 (SaaS IAM)
  - Firebase Auth
  - Okta (엔터프라이즈 SSO)

모니터링:
  - Datadog, New Relic (SaaS 모니터링)
  - PagerDuty (On-call 관리)
```

**Function Tags**:
- Primary: 기능별 상이 (예: `N4.1` for SMS, `A4.1` for Auth)
- Interface: `I1.1` (HTTP/REST API)

**Zone 배치**: Zone 0-B (Trusted Partner)

---

## 🔒 Security Zone 분류

### Zone 0-B (Trusted Partner) - 일반적 배치

**신뢰 기준**:
```yaml
계약 요건:
  - SLA 99.9% 이상 보장
  - 데이터 처리 계약 (DPA) 체결
  - 컴플라이언스 인증 (SOC 2, ISO 27001, PCI-DSS 등)

모니터링:
  - API 가용성 모니터링
  - 응답 시간 추적
  - 에러율 알람
```

### Zone 0-A (Untrusted External) - 예외적 경우

**비신뢰 서비스** (사용 권장하지 않음):
- 계약 없는 무료 API
- 개인 운영 서비스
- 검증되지 않은 신규 서비스

---

## 🛡️ 보안 고려사항

### 1. 데이터 전송 보안

```yaml
암호화:
  - TLS 1.2 이상 필수
  - 가능 시 mTLS (Mutual TLS) 사용
  - API Key 암호화 저장

인증:
  - API Key 주기적 갱신 (3-6개월)
  - OAuth 2.0, JWT 사용
  - Secrets Manager 활용 (Vault, AWS Secrets Manager)
```

### 2. 데이터 최소화

```yaml
원칙:
  - 필요한 최소한의 데이터만 전송
  - PII (개인식별정보) 익명화 또는 제거
  - 민감 데이터 전송 금지

예시 (LLM API):
  ❌ 잘못된 사용:
    "사용자 홍길동(주민번호: 123456-1234567)의 주문 분석"

  ✅ 올바른 사용:
    "사용자 ID U12345의 주문 패턴 분석"
```

### 3. Rate Limiting & Quota 관리

```yaml
비용 폭탄 방지:
  - 월간 사용량 한도 설정
  - Rate Limit 설정 (requests/second)
  - 알람 설정 (80% 사용 시 알림)

예시:
  OpenAI API:
    - 일일 한도: $100
    - RPM (Requests Per Minute): 3,500
    - TPM (Tokens Per Minute): 90,000
```

### 4. 장애 대응 전략

```yaml
Fallback 전략:
  - 대체 서비스 준비 (예: OpenAI 장애 시 Anthropic 전환)
  - 캐싱 활용 (중복 요청 감소)
  - Graceful Degradation (서비스 일부 비활성화)

예시:
  LLM API 장애 시:
    - Level 1: 캐시된 응답 반환
    - Level 2: 대체 모델 (Claude → GPT-4)
    - Level 3: AI 기능 일시 비활성화 (기본 응답)
```

---

## 📊 실전 예시

### 예시 1: AI 기반 고객 지원 시스템

```yaml
시스템 구성:
  Layer 0 (External):
    - OpenAI GPT-4: 고객 문의 응답 생성
    - Anthropic Claude: 대체 LLM (Failover)
    - SendGrid: 이메일 알림

  Layer 7 (Application):
    - FastAPI: 백엔드 API
    - React: 고객 대시보드

  Layer 5 (Data):
    - PostgreSQL + pgvector: 고객 문의 이력 + 벡터 검색
    - Redis: 응답 캐싱

데이터 흐름:
  1. 고객 문의 수신 (Layer 7)
  2. 벡터 검색으로 유사 문의 찾기 (Layer 5 - pgvector)
  3. OpenAI API 호출 (Layer 0) - 프롬프트 구성
  4. 응답 생성 및 Redis 캐싱 (Layer 5)
  5. SendGrid로 이메일 발송 (Layer 0)

보안 고려:
  - 고객 이름 익명화 (User_12345)
  - API Key는 Vault에 암호화 저장
  - 월간 OpenAI 사용량 $500 한도 설정
```

### 예시 2: E-Commerce 결제 시스템

```yaml
Layer 0 (External):
  - Stripe: 카드 결제 처리
  - Toss Payments: 한국 간편 결제
  - Cloudflare CDN: 상품 이미지 배포

Zone 분류:
  - Stripe, Toss: Zone 0-B (PCI-DSS 인증, SLA 99.95%)
  - Cloudflare CDN: Zone 0-B (SLA 100%)

보안:
  - 카드 정보 비저장 (Tokenization)
  - PCI-DSS Self-Assessment Questionnaire (SAQ-A)
  - Webhook 검증 (서명 확인)
```

---

## 🔗 Layer 간 통신

### Layer 0 → Layer 7

```yaml
호출 방향: Layer 7 → Layer 0 (API 호출)

예시:
  Backend API (Layer 7)
    ↓ HTTP/REST
  OpenAI API (Layer 0)
    ↓ 응답
  Backend API (Layer 7)
```

### 보안 경계

```yaml
Zone 2 (Application) → Zone 0-B (External API):
  - Proxy 통과 필수
  - API Key 관리 (Secrets Manager)
  - Data Loss Prevention (DLP) 검증
  - Outbound 트래픽 모니터링
```

---

## 📌 Pre-Mapping Reference (선택적)

**참고**: Pre-mapping은 선택적 참고 자료이며, 사용자는 자유롭게 커스터마이징 가능

### SaaS 제품 매핑 예시

| 제품명 | 벤더 | Layer | Zone | Primary Tag | Interface |
|--------|------|-------|------|-------------|-----------|
| **Salesforce** | Salesforce | L0 | 0-B | A6.1 (SaaS CRM) | I1.1 (REST) |
| **Slack** | Salesforce | L0 | 0-B | A6.2 (SaaS Collaboration) | I1.1 (REST) |
| **Google Workspace** | Google | L0 | 0-B | A6.3 (SaaS Productivity) | I1.1 (REST) |
| **Microsoft 365** | Microsoft | L0 | 0-B | A6.3 (SaaS Productivity) | I1.1 (REST) |

### LLM API 매핑 예시

| 제품명 | 벤더 | Layer | Zone | Primary Tag | Interface |
|--------|------|-------|------|-------------|-----------|
| **GPT-4** | OpenAI | L0 | 0-B | A7.1 (LLM Inference) | I1.1 (REST) |
| **Claude** | Anthropic | L0 | 0-B | A7.1 (LLM Inference) | I1.1 (REST) |
| **Gemini** | Google | L0 | 0-B | A7.1 (LLM Inference) | I1.1 (REST) |
| **Command** | Cohere | L0 | 0-B | A7.1 (LLM Inference) | I1.1 (REST) |

---

## ✅ 체크리스트

### Layer 0 식별

- [ ] 우리가 직접 통제하지 못하는 서비스 목록 작성
- [ ] 각 서비스의 SLA 및 컴플라이언스 확인
- [ ] Zone 0-A vs 0-B 분류 완료
- [ ] 데이터 전송 민감도 평가

### 보안 검증

- [ ] API Key 암호화 저장 확인
- [ ] PII 데이터 전송 여부 검토
- [ ] Rate Limit 및 Quota 설정
- [ ] Failover 전략 수립

### 모니터링

- [ ] API 가용성 모니터링 설정
- [ ] 응답 시간 추적 대시보드
- [ ] 비용 알람 설정
- [ ] 에러율 추적

---

## 🔗 관련 문서

- [차원 1: Deployment Layer 개요](00_차원1_개요.md)
- [차원 2: Security Zone - Zone 0-B](../02_차원2_Security_Zone/Zone_0-B_Trusted_Partner.md) (예정)
- [분류 체계 전체 개요](../00_분류체계_개요.md)

---

## 📞 변경 이력

**v1.0 (2025-01-20)** - 초기 작성:
- ✅ GR Framework v2.0 - Layer 0 신설
- ✅ External Services 분류 체계 정의
- ✅ 보안 고려사항 및 실전 예시 추가
- ✅ Pre-mapping Reference (선택적) 제공

---

**문서 끝**
