# SIEM (Security Information and Event Management)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | SIEM |
| **한글명** | 보안 정보 및 이벤트 관리 |
| **Layer** | Cross-Layer (Management) |
| **분류** | Security |
| **Function Tag (Primary)** | M4.1 (Log Analysis) |
| **Function Tag (Secondary)** | M4.2 (Threat Detection), M4.3 (Incident Response) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

SIEM은 **보안 이벤트를 실시간으로 수집, 분석, 대응하는 통합 보안 관리 시스템**입니다.

---

## 🏗️ SIEM 핵심 기능

```yaml
로그 수집 (Collection):
  - 방화벽, IDS/IPS
  - 서버, 애플리케이션
  - 네트워크 장비
  - 클라우드 서비스

정규화 (Normalization):
  - 다양한 포맷 → 통일된 포맷
  - 타임스탬프 표준화
  - 필드 매핑

상관 분석 (Correlation):
  - 이벤트 패턴 분석
  - 위협 탐지 규칙 적용
  - 이상 행위 탐지

알람 및 대응 (Alerting):
  - 실시간 알람
  - 자동 대응 (SOAR)
  - 인시던트 티켓 생성
```

---

## 🏗️ 주요 SIEM 솔루션

### 1. Splunk

**특징**: 강력한 검색, 시각화, 머신러닝

```spl
# Splunk SPL 쿼리
# 실패한 로그인 시도 탐지
index=security sourcetype=auth
| search action=login status=failed
| stats count by user, src_ip
| where count > 5
| sort -count

# SQL Injection 공격 탐지
index=web sourcetype=access_log
| regex _raw="(?i)(union|select|insert|update|delete|drop)\s+"
| stats count by src_ip, uri
| where count > 3
```

**가격**:
```yaml
Splunk Cloud:
  - $150 per GB/월
  - 최소 5GB/일

Splunk Enterprise:
  - $1,800 per GB/년 (영구 라이선스)
```

---

### 2. ELK + Elastic Security

```yaml
# Filebeat → Logstash → Elasticsearch → Kibana
# Logstash 필터
filter {
  grok {
    match => { "message" => "%{COMBINEDAPACHELOG}" }
  }

  geoip {
    source => "clientip"
  }

  if [response] == "401" or [response] == "403" {
    mutate {
      add_tag => [ "security_alert" ]
    }
  }
}
```

```json
// Elasticsearch 쿼리 - 비정상 로그인 탐지
{
  "query": {
    "bool": {
      "must": [
        { "match": { "event.category": "authentication" }},
        { "match": { "event.outcome": "failure" }}
      ],
      "filter": {
        "range": {
          "@timestamp": {
            "gte": "now-1h"
          }
        }
      }
    }
  },
  "aggs": {
    "failed_logins_by_user": {
      "terms": {
        "field": "user.name",
        "size": 10
      }
    }
  }
}
```

---

### 3. AWS Security Hub

```python
import boto3

securityhub = boto3.client('securityhub')

# 보안 표준 활성화
securityhub.batch_enable_standards(
    StandardsSubscriptionRequests=[
        {
            'StandardsArn': 'arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0'
        }
    ]
)

# 보안 결과 조회
response = securityhub.get_findings(
    Filters={
        'SeverityLabel': [{'Value': 'CRITICAL', 'Comparison': 'EQUALS'}],
        'WorkflowStatus': [{'Value': 'NEW', 'Comparison': 'EQUALS'}]
    },
    MaxResults=100
)

for finding in response['Findings']:
    print(f"Title: {finding['Title']}")
    print(f"Severity: {finding['Severity']['Label']}")
    print(f"Resource: {finding['Resources'][0]['Id']}")
```

---

## 🚨 SIEM 탐지 규칙 예시

### 1. Brute Force 공격 탐지

```yaml
Rule: Multiple Failed Login Attempts
Condition:
  - Failed login attempts > 5
  - Within 5 minutes
  - Same source IP
Action:
  - Alert: HIGH
  - Block IP (automatic)
  - Notify security team
```

### 2. 권한 상승 시도

```yaml
Rule: Privilege Escalation Attempt
Condition:
  - sudo/su command execution
  - By non-admin user
  - To root account
Action:
  - Alert: CRITICAL
  - Capture full command
  - Lock account (pending review)
```

### 3. 데이터 유출 탐지

```yaml
Rule: Large Data Transfer
Condition:
  - Outbound traffic > 1GB
  - Within 10 minutes
  - To external IP
Action:
  - Alert: HIGH
  - Log session details
  - Rate limit connection
```

---

## 📊 MITRE ATT&CK 매핑

```yaml
초기 침투 (Initial Access):
  - T1078: Valid Accounts
    → 탐지: 비정상 시간 로그인
  - T1190: Exploit Public-Facing Application
    → 탐지: 취약점 스캔 패턴

권한 상승 (Privilege Escalation):
  - T1068: Exploitation for Privilege Escalation
    → 탐지: sudo 명령어 이상 사용
  - T1548: Abuse Elevation Control Mechanism
    → 탐지: UAC 우회 시도

데이터 유출 (Exfiltration):
  - T1048: Exfiltration Over Alternative Protocol
    → 탐지: 비정상 프로토콜 사용
  - T1041: Exfiltration Over C2 Channel
    → 탐지: 대용량 아웃바운드 트래픽
```

---

## 🔄 SOAR 통합 (Security Orchestration, Automation and Response)

```python
# Phantom (Splunk SOAR) 플레이북 예시
def handle_malware_detection(event):
    # 1. 호스트 격리
    isolate_host(event['hostname'])

    # 2. 프로세스 종료
    kill_process(event['process_id'])

    # 3. 포렌식 데이터 수집
    collect_forensics(event['hostname'])

    # 4. 티켓 생성
    create_ticket({
        'title': f"Malware detected on {event['hostname']}",
        'severity': 'HIGH',
        'description': event['details']
    })

    # 5. 보안팀 알림
    notify_security_team(event)
```

---

## 📈 SIEM 대시보드 예시

```yaml
실시간 보안 현황:
  - 금일 보안 이벤트 수
  - Severity별 분포 (CRITICAL, HIGH, MEDIUM, LOW)
  - 공격 출발지 지도
  - 공격 유형 TOP 10

로그인 모니터링:
  - 실패한 로그인 시도
  - 비정상 시간 로그인
  - 지역별 로그인 분포

네트워크 보안:
  - 방화벽 차단 건수
  - IDS/IPS 알람
  - DDoS 공격 탐지

규정 준수:
  - PCI-DSS 위반 사항
  - GDPR 데이터 접근 로그
  - 감사 로그 보존 현황
```

---

## 🔒 Zone별 배치

| Zone | 배치 | 용도 |
|------|------|------|
| **Zone 0** | Very Common | 중앙 SIEM 서버 |
| **All Zones** | Very Common | 로그 수집 에이전트 |

---

## 🔗 관련 문서

- [Cross-Layer 정의](../00_CrossLayer_정의.md)
- [Monitoring](../01_Monitoring/00_Monitoring_정의.md)

---

**문서 끝**
