# WAF (Web Application Firewall)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | WAF |
| **한글명** | 웹 애플리케이션 방화벽 |
| **Layer** | Layer 2 (Network Infrastructure) |
| **분류** | Application Security |
| **Function Tag (Primary)** | S1.3 (WAF) |
| **Function Tag (Secondary)** | 없음 |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

WAF는 **HTTP/HTTPS 트래픽을 검사하여 웹 애플리케이션을 공격으로부터 보호하는 보안 장비**입니다.

### 핵심 기능

1. **OWASP Top 10 방어**
   - SQL Injection
   - XSS (Cross-Site Scripting)
   - CSRF (Cross-Site Request Forgery)
   - Path Traversal

2. **트래픽 분석**
   - HTTP Request/Response 검사
   - 악의적 패턴 탐지
   - 정상 행위 학습 (Behavioral Analysis)

3. **Bot 관리**
   - 악성 봇 차단
   - Rate Limiting
   - CAPTCHA 챌린지

---

## 🏗️ WAF 유형

### 1. Network-based WAF (하드웨어)

**특징**:
- 물리 장비 또는 가상 어플라이언스
- 온프레미스 배치
- 낮은 지연시간

**대표 제품**:
- **F5**: BIG-IP ASM (Application Security Manager)
- **Imperva**: SecureSphere WAF
- **Barracuda**: WAF
- **Fortinet**: FortiWeb

**가격대**: 2,000만원 ~ 2억원

---

### 2. Cloud-based WAF (클라우드)

**특징**:
- DNS 기반 프록시
- 즉시 배포 가능
- 글로벌 DDoS 방어

**대표 서비스**:
- **Cloudflare**: WAF + CDN + DDoS
- **AWS WAF**: ALB/CloudFront 통합
- **Azure WAF**: Application Gateway 통합
- **Akamai**: Kona Site Defender

**가격 모델**:
```yaml
Cloudflare:
  - Pro: $20/month (기본 룰셋)
  - Business: $200/month (고급 룰셋)
  - Enterprise: 협의 (커스텀 룰)

AWS WAF:
  - Web ACL: $5/month
  - Rule: $1/month per rule
  - Requests: $0.60 per 1M requests
```

---

### 3. Host-based WAF (소프트웨어)

**특징**:
- 웹 서버에 모듈로 설치
- 애플리케이션 레벨 통합
- 설정 복잡

**대표 제품**:
- **ModSecurity**: 오픈소스, Apache/NGINX 모듈
- **NAXSI**: NGINX 전용

---

## 🛡️ OWASP Top 10 방어

### 1. SQL Injection

**공격 예시**:
```sql
' OR '1'='1' --
UNION SELECT username, password FROM users--
```

**WAF 룰**:
```yaml
Rule: Detect SQL Injection
Pattern:
  - (\bUNION\b.*\bSELECT\b)
  - (\bOR\b.*=.*)
  - (';.*--)
Action: Block
```

---

### 2. Cross-Site Scripting (XSS)

**공격 예시**:
```html
<script>alert('XSS')</script>
<img src=x onerror=alert('XSS')>
```

**WAF 룰**:
```yaml
Rule: Detect XSS
Pattern:
  - (<script[^>]*>.*</script>)
  - (onerror\s*=)
  - (javascript:)
Action: Block
```

---

### 3. Path Traversal

**공격 예시**:
```
GET /download?file=../../../etc/passwd
GET /view?page=....//....//etc/passwd
```

**WAF 룰**:
```yaml
Rule: Detect Path Traversal
Pattern:
  - (\.\./)
  - (%2e%2e%2f)
  - (\.\.\\)
Action: Block
```

---

## 📝 설정 예시

### ModSecurity (Core Rule Set)

```apache
# Enable ModSecurity
SecRuleEngine On

# Request Body Inspection
SecRequestBodyAccess On
SecRequestBodyLimit 13107200

# Response Body Inspection
SecResponseBodyAccess On

# Core Rule Set (CRS)
Include /etc/modsecurity/crs/crs-setup.conf
Include /etc/modsecurity/crs/rules/*.conf

# Custom Rules
SecRule ARGS "@detectSQLi" \
    "id:1001,phase:2,deny,status:403,msg:'SQL Injection Detected'"

SecRule ARGS "@detectXSS" \
    "id:1002,phase:2,deny,status:403,msg:'XSS Attack Detected'"

# Rate Limiting
SecAction "id:1003,phase:1,initcol:ip=%{REMOTE_ADDR}"
SecRule IP:bf_counter "@gt 100" \
    "id:1004,phase:1,deny,status:429,msg:'Rate Limit Exceeded'"
```

---

### AWS WAF (JSON Rules)

```json
{
  "Name": "SQLInjectionRule",
  "Priority": 1,
  "Statement": {
    "SqliMatchStatement": {
      "FieldToMatch": {
        "AllQueryArguments": {}
      },
      "TextTransformations": [
        {
          "Priority": 0,
          "Type": "URL_DECODE"
        }
      ]
    }
  },
  "Action": {
    "Block": {}
  },
  "VisibilityConfig": {
    "SampledRequestsEnabled": true,
    "CloudWatchMetricsEnabled": true,
    "MetricName": "SQLInjectionRule"
  }
}
```

---

### Cloudflare WAF (Firewall Rules)

```
# Block SQL Injection
(http.request.uri.query contains "UNION SELECT") or
(http.request.uri.query contains "OR 1=1") or
(http.request.body contains "'; DROP TABLE")

Action: Block

# Challenge suspicious bots
(cf.bot_management.score lt 30) and
(http.request.uri.path contains "/api/")

Action: Managed Challenge (CAPTCHA)

# Rate Limiting
(http.request.uri.path eq "/api/login") and
(rate(1m) > 10)

Action: Block for 1 hour
```

---

## 🤖 Bot 관리

### Bot 분류

```yaml
Good Bots:
  - Googlebot (검색엔진)
  - Bingbot
  - 합법적 API 클라이언트
  Action: Allow

Bad Bots:
  - Scrapers (무단 크롤링)
  - Credential Stuffing
  - DDoS 봇
  Action: Block

Suspicious:
  - 헤드리스 브라우저
  - 비정상 User-Agent
  Action: Challenge (CAPTCHA)
```

### Bot Detection 방법

```yaml
1. User-Agent Analysis:
   - 빈 User-Agent
   - 오래된 브라우저
   - 자동화 도구 시그니처

2. Behavioral Analysis:
   - 비정상적으로 빠른 요청
   - 순차적 페이지 접근
   - JavaScript 실행 실패

3. Browser Fingerprinting:
   - TLS Fingerprint
   - HTTP/2 Fingerprint
   - Canvas Fingerprinting
```

---

## 📊 WAF 운영 모드

### 1. Detection Mode (탐지 모드)
```
악성 트래픽 탐지 → 로그 기록만
→ 초기 튜닝 시 사용
→ False Positive 확인
```

### 2. Prevention Mode (차단 모드)
```
악성 트래픽 탐지 → 즉시 차단
→ 운영 환경
→ 오탐(False Positive) 최소화 필요
```

---

## ⚡ 실무 고려사항

### 1. False Positive 최소화

**튜닝 프로세스**:
```
1. Detection 모드로 1-2주 운영
2. 로그 분석 → 정상 트래픽 차단 확인
3. 예외 규칙 추가 (Whitelist)
4. Prevention 모드 전환
5. 지속적 모니터링 및 개선
```

**Whitelist 예시**:
```yaml
# Allow specific IPs
Allow: 1.2.3.4/32 (Office IP)

# Allow specific User-Agents
Allow: "MyApp/1.0" (Mobile App)

# Allow specific URLs
/api/webhook/* → Disable SQL Injection rule
```

### 2. 성능 영향

```yaml
Latency Impact:
  - Cloud WAF: +5-20ms
  - On-premise WAF: +1-5ms

Throughput:
  - Hardware WAF: 1-100 Gbps
  - Cloud WAF: Auto-scaling

CPU Overhead:
  - Complex Regex: High
  - Simple Rules: Low
```

### 3. 로깅 및 모니터링

```yaml
Essential Logs:
  - Blocked Requests (공격 시도)
  - Allowed Requests (샘플링)
  - False Positives
  - Performance Metrics

Integration:
  - SIEM (Splunk, ELK)
  - Alerting (PagerDuty, Slack)
  - Dashboards (Grafana)
```

---

## 🔗 관련 문서

- [Layer 2 정의](../00_Layer_2_정의.md)
- [Firewall](../02_Firewall/00_Firewall_정의.md)
- [Reverse Proxy](../04_Reverse_Proxy/00_Reverse_Proxy_정의.md)

---

**문서 끝**
