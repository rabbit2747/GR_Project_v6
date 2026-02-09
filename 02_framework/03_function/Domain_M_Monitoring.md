# Domain M: Monitoring (모니터링)

**버전**: v2.0
**최종 수정**: 2025-11-20
**목적**: 시스템 가시성, 성능 추적, 이상 탐지, 보안 모니터링

---

## 1. Domain 개요

### 1.1 정의
Monitoring Domain은 IT 인프라 전반의 **가시성(Observability)**을 제공하는 기능 집합입니다.

### 1.2 v2.0 변경사항
- **v1.0**: Management Domain의 일부
- **v2.0**: 독립 Domain으로 분리, AI/ML 기반 이상 탐지 추가

### 1.3 핵심 목표
1. **실시간 가시성**: 모든 Layer/Zone의 상태 추적
2. **성능 최적화**: 병목 지점 식별 및 개선
3. **이상 탐지**: AI/ML 기반 자동 탐지
4. **보안 위협 탐지**: SIEM 연동

---

## 2. Tag 체계

### Tag 구조
```
M + [숫자] + (선택적 서브 카테고리)
예: M1 (Metrics Collection), M2.1 (APM - Backend)
```

---

## 3. Tag 상세 정의

### M1: Metrics Collection (메트릭 수집)

**목적**: 시스템 성능 지표 수집

**구성 요소**:
- **M1.1**: Infrastructure Metrics
  - CPU, Memory, Disk, Network I/O
  - 도구: Prometheus Node Exporter, Telegraf
  - 수집 주기: 15s~1m

- **M1.2**: Application Metrics
  - Request rate, Error rate, Latency (RED)
  - 도구: Prometheus, StatsD, OpenTelemetry
  - Format: Prometheus Exposition Format

- **M1.3**: Business Metrics
  - 회원가입, 결제, 주문 완료
  - KPI Dashboard 연동

**사용 예시**:
```yaml
Component: NGINX (L1, Zone 1)
Tags: [M1.1, M1.2, N3.1, P1.1]
Metrics:
  - nginx_connections_active (M1.1)
  - nginx_http_requests_total (M1.2)
  - nginx_http_request_duration_seconds (M1.2)
```

---

### M2: APM (Application Performance Monitoring)

**목적**: 애플리케이션 성능 추적 및 분산 추적

**구성 요소**:
- **M2.1**: Backend APM
  - 도구: Datadog APM, New Relic, Elastic APM
  - Span 추적, Trace ID 전파
  - 언어: Python (ddtrace), Java (dd-java-agent)

- **M2.2**: Frontend APM (RUM - Real User Monitoring)
  - 도구: Datadog RUM, Google Analytics
  - Core Web Vitals: LCP, FID, CLS
  - User Session Replay

- **M2.3**: Database APM
  - 도구: pg_stat_statements (PostgreSQL), MySQL Enterprise Monitor
  - Slow Query 탐지 (>100ms)
  - Connection Pool 모니터링

**사용 예시**:
```python
# Backend API (L2, Zone 2)
# Tags: [M2.1, A2.1, T1.3, I1.1]

from ddtrace import tracer

@tracer.wrap(service="user-api", resource="POST /api/users")
def create_user(request):
    with tracer.trace("db.query", service="postgres"):
        user = User.objects.create(**request.data)
    return user
```

---

### M3: Log Management (로그 관리)

**목적**: 중앙화된 로그 수집, 저장, 분석

**구성 요소**:
- **M3.1**: Log Collection
  - 도구: Fluentd, Logstash, Vector
  - Protocol: Syslog, HTTP, TCP
  - Format: JSON, CEF (Common Event Format)

- **M3.2**: Log Storage
  - 도구: Elasticsearch, Loki, S3 (장기 보관)
  - Retention: Hot (7d), Warm (30d), Cold (1y)

- **M3.3**: Log Analysis
  - 도구: Kibana, Grafana, Splunk
  - Use Case: Error 추적, 보안 이벤트 분석

**사용 예시**:
```yaml
Component: Application Server (L2, Zone 2)
Tags: [M3.1, M3.3, S5.2]

Log Entry:
  timestamp: "2025-11-20T10:30:45Z"
  level: "ERROR"
  service: "payment-api"
  trace_id: "a1b2c3d4"
  message: "Payment gateway timeout"
  error_code: "GATEWAY_TIMEOUT"
  user_id: "user_12345"
```

---

### M4: Alerting (알림)

**목적**: 임계값 기반 자동 알림 및 온콜 관리

**구성 요소**:
- **M4.1**: Threshold Alerting
  - 도구: Prometheus Alertmanager, Grafana Alerts
  - 임계값: CPU >80%, Memory >90%, Error Rate >1%

- **M4.2**: Anomaly Detection (AI/ML 기반)
  - 도구: Datadog Anomaly Detection, AWS CloudWatch Anomaly Detection
  - 알고리즘: Moving Average, Seasonal Decomposition

- **M4.3**: Incident Management
  - 도구: PagerDuty, Opsgenie, Slack
  - Escalation Policy: L1 (5m) → L2 (15m) → Manager (30m)

**사용 예시**:
```yaml
Alert Rule:
  name: "High API Error Rate"
  expr: "rate(http_requests_total{status=~'5..'}[5m]) > 0.01"
  for: 5m
  severity: critical
  annotations:
    description: "API error rate is {{ $value }}% for 5 minutes"
  actions:
    - PagerDuty: oncall-backend-team
    - Slack: #alerts-production
```

---

### M5: Tracing (분산 추적)

**목적**: 마이크로서비스 간 요청 흐름 추적

**구성 요소**:
- **M5.1**: Distributed Tracing
  - 도구: Jaeger, Zipkin, AWS X-Ray
  - Protocol: OpenTelemetry, Zipkin B3
  - Trace Context 전파: HTTP Header (X-B3-TraceId)

- **M5.2**: Service Mesh Tracing
  - 도구: Istio + Jaeger, Linkerd
  - Automatic Instrumentation (Sidecar Proxy)

**사용 예시**:
```
Trace ID: a1b2c3d4-e5f6-7890-abcd-ef1234567890

Spans:
1. frontend (Zone 5) → API Gateway (Zone 1): 50ms
2. API Gateway → User Service (Zone 2): 80ms
3. User Service → PostgreSQL (Zone 3): 30ms
4. User Service → Redis (Zone 3): 5ms
Total Latency: 165ms
```

---

### M6: Security Monitoring (보안 모니터링)

**목적**: 보안 위협 탐지 및 대응

**구성 요소**:
- **M6.1**: SIEM (Security Information and Event Management)
  - 도구: Splunk, QRadar, Azure Sentinel
  - Use Case: 로그인 실패 패턴, 권한 상승 시도

- **M6.2**: IDS/IPS Monitoring
  - 도구: Suricata, Snort, Zeek
  - Signature 기반 탐지 + Anomaly 탐지

- **M6.3**: Threat Intelligence
  - 도구: MISP, ThreatConnect
  - IoC (Indicator of Compromise) 수집

**사용 예시**:
```yaml
Security Event:
  event_type: "Brute Force Attack Detected"
  source_ip: "203.0.113.45"
  target: "login-api.example.com"
  failed_attempts: 120
  time_window: "5 minutes"
  action: "IP Blocked (Zone 1 WAF)"
  mitre_attack: "T1110.001 (Brute Force: Password Guessing)"
```

---

### M7: Infrastructure Monitoring (인프라 모니터링)

**목적**: 물리/가상 인프라 상태 추적

**구성 요소**:
- **M7.1**: Server Monitoring
  - 도구: Zabbix, PRTG, Nagios
  - Checks: Ping, Port, Process, Service

- **M7.2**: Network Monitoring
  - 도구: Cisco DNA Center, SolarWinds
  - SNMP, NetFlow, sFlow

- **M7.3**: Cloud Monitoring
  - 도구: AWS CloudWatch, Azure Monitor, GCP Monitoring
  - Auto-scaling metrics, Billing alerts

**사용 예시**:
```yaml
Infrastructure Alert:
  resource: "RDS PostgreSQL Instance (Zone 3)"
  metric: "DatabaseConnections"
  current: 95
  threshold: 100
  action: "Auto-scale read replicas"
  tags: [M7.3, D2.1, R2.2]
```

---

### M8: User Experience Monitoring (사용자 경험 모니터링)

**목적**: 실제 사용자 경험 측정

**구성 요소**:
- **M8.1**: Synthetic Monitoring
  - 도구: Datadog Synthetic Tests, Pingdom
  - Use Case: Uptime 체크, 주요 User Journey 시뮬레이션

- **M8.2**: Real User Monitoring (RUM)
  - 도구: Google Analytics, Datadog RUM
  - Metrics: Page Load Time, AJAX 성능

**사용 예시**:
```javascript
// Frontend (Zone 5)
// Tags: [M8.2, A1.1, I1.1]

// Core Web Vitals
const observer = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    if (entry.entryType === 'largest-contentful-paint') {
      console.log('LCP:', entry.renderTime || entry.loadTime);
      // Send to monitoring backend
    }
  }
});
observer.observe({ type: 'largest-contentful-paint', buffered: true });
```

---

## 4. Layer/Zone 연관성

### Layer별 Monitoring 전략

| Layer | 주요 Monitoring Tags | 도구 예시 |
|-------|---------------------|----------|
| L0 (External) | M6.2 (IDS/IPS) | Suricata, CloudFlare Analytics |
| L1 (Perimeter) | M1.2, M6.1 | WAF Logs, NGINX Metrics |
| L2 (Application) | M2.1, M3.3, M5.1 | Datadog APM, Jaeger |
| L3 (Data) | M2.3, M7.3 | pg_stat_statements, CloudWatch |
| L4 (Management) | M4.3, M6.1 | PagerDuty, SIEM |
| L5 (Endpoint) | M8.1, M8.2 | Datadog RUM, Synthetic Tests |

### Zone별 Monitoring 우선순위

| Zone | Critical Metrics | Alert Threshold |
|------|-----------------|----------------|
| Zone 0-A | M6.2 (공격 시도) | >100 req/min |
| Zone 0-B | M1.2 (API Rate Limit) | >80% quota |
| Zone 1 | M1.2 (Error Rate) | >0.5% |
| Zone 2 | M2.1 (Latency P95) | >500ms |
| Zone 3 | M2.3 (DB Connections) | >90% |
| Zone 4 | M4.3 (Incident Response) | <5m MTTA |
| Zone 5 | M8.2 (LCP) | >2.5s |

---

## 5. CVE 매핑

### Monitoring 도구 취약점 예시

| CVE ID | 영향 받는 도구 | Tech Stack Tag | Severity |
|--------|--------------|---------------|----------|
| CVE-2023-12345 | Prometheus 2.40.0 | T4.5 (Monitoring) | High |
| CVE-2024-67890 | Grafana <10.0.0 | T4.5 | Critical |
| CVE-2024-11111 | Elasticsearch <8.9.0 | T2.3 (Search) | Medium |

**대응 전략**:
```yaml
Vulnerability: CVE-2024-67890 (Grafana)
Affected Components:
  - Grafana Dashboard (L4, Zone 4)
  - Tags: [M3.3, M7.3, A3.1]
Mitigation:
  - Upgrade: Grafana 9.5.3 → 10.1.0
  - Workaround: Disable public dashboards
  - Monitoring: Check for unauthorized access attempts
```

---

## 6. MITRE ATT&CK 매핑

### Monitoring으로 탐지 가능한 공격 기법

| MITRE Technique | Monitoring Tag | 탐지 방법 |
|----------------|---------------|----------|
| T1078 (Valid Accounts) | M6.1 | 비정상 로그인 시간/위치 |
| T1190 (Exploit Public-Facing Application) | M6.2, M1.2 | WAF 로그, Error Rate 급증 |
| T1498 (DoS) | M1.1, M6.2 | Traffic Spike, CPU 급증 |
| T1565 (Data Manipulation) | M3.3, M6.1 | Audit Log 분석 |

---

## 7. Best Practices

### 7.1 Observability 3 Pillars
1. **Metrics**: 시계열 데이터 (M1, M2)
2. **Logs**: 이벤트 기록 (M3)
3. **Traces**: 분산 추적 (M5)

### 7.2 Golden Signals (Google SRE)
1. **Latency**: 요청 응답 시간 (M2.1)
2. **Traffic**: 요청 처리량 (M1.2)
3. **Errors**: 에러율 (M1.2)
4. **Saturation**: 리소스 사용률 (M1.1)

### 7.3 Alert Fatigue 방지
- **Threshold Tuning**: 통계 기반 동적 임계값
- **Alert Grouping**: 연관 알림 통합
- **Silence Rules**: 유지보수 기간 알림 차단

---

## 8. 실제 구현 예시

### 8.1 Full Stack Monitoring Architecture

```yaml
Frontend (Zone 5):
  - Datadog RUM (M8.2)
  - Core Web Vitals tracking
  - User Session Replay

API Gateway (Zone 1):
  - NGINX metrics (M1.1, M1.2)
  - Access logs → Fluentd → Elasticsearch (M3.1)
  - WAF alerts → SIEM (M6.1)

Backend Services (Zone 2):
  - Datadog APM (M2.1)
  - OpenTelemetry instrumentation (M5.1)
  - Prometheus metrics endpoint (M1.2)

Database (Zone 3):
  - PostgreSQL metrics (M2.3)
  - Slow query logging (M3.3)
  - Connection pool monitoring (M7.3)

Alerting:
  - Prometheus Alertmanager (M4.1)
  - PagerDuty escalation (M4.3)
  - Slack notifications (M4.3)
```

### 8.2 Monitoring Data Flow

```
Application Logs → Fluentd (M3.1) → Elasticsearch (M3.2) → Kibana (M3.3)
                                   ↓
                             SIEM (M6.1) → Alert (M4.3)

Application Metrics → Prometheus (M1.2) → Grafana Dashboard
                                        ↓
                              Alertmanager (M4.1) → PagerDuty (M4.3)

APM Traces → Datadog Agent (M2.1) → Datadog Backend → Dashboard
                                                     ↓
                                              Anomaly Detection (M4.2)
```

---

## 9. 다음 단계

- **Domain N (Networking)**: M1.1과 연동되는 네트워크 메트릭
- **Domain S (Security)**: M6과 연동되는 보안 통제
- **Domain T (Tech Stack)**: Monitoring 도구 버전 관리 및 CVE 추적

---

**문서 종료**
