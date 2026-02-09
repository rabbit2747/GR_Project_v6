# Zone 0: External/Internet Zone (외부 영역)

## 📋 Zone 정보

| 속성 | 값 |
|------|-----|
| **Zone명** | Zone 0 - External/Internet Zone |
| **한글명** | 외부 영역 / 인터넷 존 |
| **신뢰 수준** | None (0%) |
| **공격 노출도** | N/A (우리가 통제 불가) |
| **버전** | v1.0.0 |

---

## 🎯 정의

Zone 0은 **조직이 통제할 수 없는 외부 영역으로, 인터넷 전체와 외부 서비스를 포함**합니다.

**핵심 특성**:
- **완전 비신뢰**: 우리가 통제하거나 신뢰할 수 없는 영역
- **익명성**: 행위자의 신원을 확인할 수 없음
- **위협 잠재성**: 악의적 행위자가 존재할 수 있음
- **대규모 트래픽**: 전 세계 사용자와 봇이 혼재

**보안 원칙**:
- **Zero Trust**: Zone 0에서 오는 모든 요청은 검증 필요
- **방어 집중**: Zone 1에서 철저한 필터링 및 검사
- **최소 노출**: 공개 API만 Zone 0에 노출
- **데이터 보호**: Zone 0로 전송되는 데이터는 암호화 필수

---

## 🏗️ Zone 0 구성요소

### 통제 불가 영역 (우리가 배치하지 않음)

```
┌─────────────────────────────────────────────────────┐
│              Zone 0 (External/Internet)             │
│                                                     │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  │
│  │ 인터넷      │  │  외부       │  │  공격자     │ │
│  │ 사용자      │  │  SaaS       │  │  인프라     │ │
│  │(브라우저)    │  │(API)       │  │(봇넷)      │ │
│  └────────────┘  └────────────┘  └────────────┘  │
│                                                     │
│         ↓ HTTPS (공개 인터넷을 통한 요청)            │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│          Zone 1 (Perimeter - 첫 번째 방어선)         │
│            WAF, DDoS Protection, CDN                │
│              철저한 필터링 및 검증                     │
└─────────────────────────────────────────────────────┘
```

---

## 📊 Zone 0 구성요소

### Very Common (매우 흔함)

| 구성요소 | 설명 | 특성 |
|---------|------|------|
| **인터넷 사용자** | 일반 웹 사용자, 모바일 앱 사용자 | 익명, 대규모, 예측 불가 |
| **외부 SaaS 서비스** | Salesforce, Google Workspace 등 | 신뢰할 수 있으나 우리가 통제 못함 |
| **외부 LLM API** | OpenAI API, Claude API, Gemini API | 데이터 전송 시 주의 필요 |
| **봇/크롤러** | 검색 엔진 봇, 스크래핑 봇 | 정상/악의적 봇 혼재 |

### Common (흔함)

| 구성요소 | 설명 | 특성 |
|---------|------|------|
| **공격자 인프라** | C&C 서버, 봇넷 | 악의적, 지속적 위협 |
| **파트너 시스템** | B2B 파트너의 API 클라이언트 | 신뢰 관계 있으나 외부 |
| **외부 모니터링 서비스** | Pingdom, StatusPage | 우리 서비스 상태 확인 |

### Rare (드묾)

| 구성요소 | 설명 | 사용 사례 |
|---------|------|----------|
| **정부 기관** | 법 집행 기관의 데이터 요청 | 법적 요구사항 대응 |
| **보안 연구자** | 화이트햇 해커, 버그바운티 | 취약점 보고 |
| **데이터 브로커** | 위협 인텔리전스 제공자 | 보안 정보 수집 |

---

## 🔐 Zone 0에 대한 방어 전략

### 접근 통제 원칙

```yaml
기본 원칙: Deny All, Allow by Exception
  - Zone 0에서의 모든 접근은 기본 차단
  - 명시적으로 허용된 경로만 개방
  - 지속적인 검증 및 모니터링

허용되는 접근:
  - Zone 0 → Zone 1: HTTPS (443) Only
  - 용도: 공개 웹 서비스, 공개 API 접근
  - 조건: WAF 통과, Rate Limiting, DDoS Protection

절대 차단:
  - Zone 0 → Zone 2: 직접 접근 금지
  - Zone 0 → Zone 3: 직접 접근 금지
  - Zone 0 → Zone 4: 관리 시스템 접근 금지
  - Zone 0 → Zone 5: 내부 엔드포인트 접근 금지
```

### 방어 계층 (Defense in Depth)

```yaml
1차 방어: DDoS Protection
  - 대규모 공격 탐지 및 차단
  - Challenge 페이지 제공
  - IP Reputation 기반 필터링

2차 방어: CDN
  - 정적 콘텐츠 캐싱
  - 원본 서버 보호
  - 지역별 트래픽 분산

3차 방어: WAF
  - OWASP Top 10 공격 차단
  - SQL Injection, XSS 방어
  - Bot 탐지 및 차단

4차 방어: Load Balancer
  - 헬스 체크
  - Rate Limiting
  - SSL/TLS 종료

5차 방어: API Gateway (Zone 1)
  - 인증/인가 검증
  - API 호출 제한
  - 요청/응답 검증
```

### 데이터 전송 보안

```yaml
Zone 내부 → Zone 0 (아웃바운드):
  암호화:
    - TLS 1.3 필수
    - 강력한 암호화 스위트
    - Certificate Pinning (고위험 통신)

  데이터 최소화:
    - 민감 정보 전송 금지
    - 필요한 데이터만 전송
    - 데이터 마스킹/익명화

  로깅:
    - 모든 외부 API 호출 로깅
    - 전송 데이터 종류 기록
    - 실패 시 재시도 메커니즘

외부 SaaS 사용 시:
  - 데이터 주권 확인 (GDPR, 개인정보보호법)
  - SaaS 제공자 보안 인증 확인 (SOC 2, ISO 27001)
  - 계약서에 데이터 보호 조항 포함
  - 정기적인 보안 감사
```

---

## 🚫 Zone 0 위협 모델

### 위협 유형

```yaml
1. DDoS 공격:
  - 대량 트래픽으로 서비스 마비
  - Layer 3/4 (Volumetric), Layer 7 (Application)
  - 방어: DDoS Protection, Rate Limiting

2. 웹 애플리케이션 공격:
  - SQL Injection, XSS, CSRF
  - Remote Code Execution
  - 방어: WAF, 입력 검증, 파라미터 검증

3. 자동화 봇 공격:
  - Credential Stuffing (계정 탈취)
  - Web Scraping (데이터 수집)
  - 방어: Bot Management, CAPTCHA

4. Zero-Day 취약점:
  - 알려지지 않은 취약점 악용
  - 방어: Virtual Patching (WAF), 빠른 패치

5. 공급망 공격:
  - 외부 라이브러리/CDN 침해
  - 방어: SRI (Subresource Integrity), CSP
```

### 위협 행위자 (Threat Actors)

```yaml
Script Kiddies (낮은 기술):
  - 공개 도구 사용
  - 무작위 공격
  - 영향: 낮음
  - 대응: 기본 WAF 룰

Cybercriminals (중간 기술):
  - 금전적 목적
  - Ransomware, 데이터 탈취
  - 영향: 중간
  - 대응: EDR, SIEM, 위협 인텔리전스

Advanced Persistent Threat (APT) (높은 기술):
  - 국가 지원
  - 장기간 잠복
  - 영향: 매우 높음
  - 대응: Zero Trust, 지속적 모니터링

Insiders (내부자):
  - 전/현직 직원
  - 권한 남용
  - 영향: 높음
  - 대응: 최소 권한 원칙, 감사 로그
```

---

## 💡 Zone 0 통신 패턴

### 패턴 1: 일반 사용자 접속

```
일반 사용자 (Zone 0)
    ↓ DNS 조회 (공개 DNS)
CDN PoP 선택 (가장 가까운 서버)
    ↓ HTTPS 요청 (443)
DDoS Protection (트래픽 분석)
    ↓ 정상 트래픽 판단
WAF (보안 검사)
    ↓ OWASP 공격 패턴 검사 통과
Load Balancer (Zone 1)
    ↓ 검증된 트래픽
API Server (Zone 2)
    ↑ JSON 응답
사용자
```

### 패턴 2: 외부 SaaS 서비스 연동

```
우리 시스템 (Zone 2)
    ↓ HTTPS 요청 (외부 API 호출)
Zone 1 (Egress Gateway)
    ↓ TLS 1.3 암호화
외부 LLM API (Zone 0)
    ↓ API 처리
    ↑ AI 응답 (JSON)
Zone 1 (응답 검증)
    ↑
우리 시스템 (Zone 2)

주의사항:
  - 민감 데이터 전송 금지
  - API 키 Vault에 안전하게 저장
  - 응답 데이터 검증
  - 모든 호출 로깅
```

### 패턴 3: 공격 트래픽 차단

```
공격자 (Zone 0)
    ↓ 초당 100,000 요청 (DDoS)
DDoS Protection
    ↓ 비정상 트래픽 탐지
Challenge 페이지 (CAPTCHA)
    ❌ 차단 또는 속도 제한

또는

공격자 (Zone 0)
    ↓ ' OR '1'='1 (SQL Injection)
WAF
    ↓ SQL Injection 패턴 탐지
403 Forbidden
    ❌ 차단 + IP 블랙리스트 추가
```

---

## 🔍 Zone 0 모니터링 전략

### 위협 인텔리전스 수집

```yaml
IP Reputation:
  - 악의적 IP 목록 (블랙리스트)
  - 위협 인텔리전스 피드 (AlienVault, Talos)
  - 실시간 업데이트 (1시간 간격)

지리적 분석:
  - 비정상적인 국가에서의 트래픽
  - GeoIP 기반 차단 (선택적)
  - 지역별 트래픽 패턴 분석

행동 패턴 분석:
  - 비정상적인 요청 패턴
  - 속도 급증 탐지
  - User-Agent 분석
```

### 로깅 및 분석

```yaml
수집 대상:
  - Zone 0에서의 모든 접근 시도 (성공/실패)
  - 차단된 IP 및 차단 사유
  - 외부 API 호출 (아웃바운드)

분석 도구:
  - SIEM: Splunk, Elastic Security
  - 위협 인텔리전스: MISP, ThreatConnect
  - 시각화: Grafana, Kibana

알림 조건:
  - DDoS 공격 탐지 → 즉시 알림
  - WAF 룰 트리거 급증 → 5분 내 알림
  - 신규 취약점 (CVE) → 1시간 내 알림
```

---

## 🚨 Zone 0 관련 인시던트 대응

### 시나리오 1: 대규모 DDoS 공격

```yaml
탐지:
  - 트래픽 10배 급증
  - DDoS Protection 알림
  - 서비스 응답 시간 증가

대응:
  1. 자동: DDoS Protection 활성화
  2. 자동: Challenge 페이지 제공
  3. 수동: 공격 유형 분석
  4. 수동: Cloudflare/Akamai 전문가 지원 요청

복구:
  - 트래픽 정상화 확인
  - 차단 규칙 점진적 완화
  - 사후 분석 및 개선

평균 대응 시간: 5-30분
```

### 시나리오 2: 외부 API (LLM) 침해

```yaml
탐지:
  - 외부 LLM API 응답 이상
  - 데이터 유출 의심
  - 보안 뉴스/공지

대응:
  1. 긴급: 외부 API 호출 차단
  2. 분석: 전송한 데이터 내역 확인
  3. 평가: 민감 정보 유출 여부
  4. 조치: 대체 서비스 전환

예방:
  - 민감 데이터 전송 금지
  - 데이터 마스킹/익명화
  - 정기적인 보안 감사

평균 대응 시간: 1-4시간
```

### 시나리오 3: Zero-Day 취약점 (CVE)

```yaml
탐지:
  - 보안 권고 (NVD, CERT)
  - 외부 보안 업체 알림

대응:
  1. 긴급: Virtual Patching (WAF 룰 추가)
  2. 임시: 취약한 기능 비활성화
  3. 영구: 소프트웨어 패치 적용

예시:
  - Log4Shell (CVE-2021-44228)
  - Heartbleed (CVE-2014-0160)

평균 대응 시간: 1-8시간
```

---

## 📊 Zone 0 관련 메트릭

### 보안 메트릭

```yaml
위협 탐지:
  - 차단된 요청 수 (count/min)
  - DDoS 공격 탐지 빈도
  - WAF 룰 트리거 Top 10

IP Reputation:
  - 블랙리스트 IP 수
  - 새로운 악의적 IP (daily)
  - 지역별 차단 통계

외부 API 사용:
  - 아웃바운드 호출 수
  - 전송 데이터량
  - 실패율 (%)
```

### 대시보드 예시

```yaml
Dashboard 1: 위협 현황
  - 실시간 공격 지도
  - 차단된 IP Top 10
  - WAF 룰 트리거 트렌드

Dashboard 2: 외부 연동
  - 외부 API 호출 현황
  - 응답 시간 (SLA)
  - 에러율 (by API)

Dashboard 3: 트래픽 분석
  - 지역별 트래픽
  - User-Agent 분포
  - Bot vs Human 비율
```

---

## 🔗 관련 문서

- [Security Zone 개요](../00_Security_Zone_개요.md)
- [Zone 1: Perimeter Zone](../Zone_1_Perimeter/00_Zone_1_정의.md)
- [Zone 4: Management Zone](../Zone_4_Management/00_Zone_4_정의.md)
- [DDoS Protection](../../01_차원1_Deployment_Layer/Layer_2_Network/05_DDoS_Protection/00_DDoS_정의.md)
- [WAF 구성요소](../../01_차원1_Deployment_Layer/Layer_2_Network/03_WAF/00_WAF_정의.md)

---

**문서 끝**
