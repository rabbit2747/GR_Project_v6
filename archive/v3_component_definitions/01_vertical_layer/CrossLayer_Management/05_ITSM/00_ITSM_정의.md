# ITSM (IT Service Management)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | ITSM |
| **한글명** | IT 서비스 관리 |
| **Layer** | Cross-Layer (Management) |
| **분류** | Operations |
| **Function Tag (Primary)** | M5.1 (Ticketing) |
| **Function Tag (Secondary)** | M5.2 (Change Management), M5.3 (Asset Management) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

ITSM은 **IT 서비스를 체계적으로 관리하고 개선하기 위한 프로세스와 도구의 집합**입니다.

---

## 🏗️ ITIL 프레임워크

```yaml
Service Strategy (서비스 전략):
  - 서비스 포트폴리오 관리
  - 재무 관리
  - 비즈니스 관계 관리

Service Design (서비스 설계):
  - 서비스 카탈로그 관리
  - 가용성 관리
  - 용량 관리

Service Transition (서비스 전환):
  - 변경 관리 ⭐
  - 릴리스 관리
  - 지식 관리

Service Operation (서비스 운영):
  - 인시던트 관리 ⭐
  - 문제 관리
  - 이벤트 관리

Continual Service Improvement (지속적 개선):
  - 프로세스 개선
  - 서비스 측정
```

---

## 🏗️ 주요 ITSM 플랫폼

### 1. ServiceNow

**특징**: 엔터프라이즈급, 워크플로우 자동화

```javascript
// ServiceNow REST API - 인시던트 생성
const createIncident = async () => {
  const response = await fetch('https://instance.service-now.com/api/now/table/incident', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Basic ' + btoa(username + ':' + password)
    },
    body: JSON.stringify({
      short_description: 'Database connection timeout',
      urgency: 1,
      impact: 1,
      category: 'Database',
      assignment_group: 'Database Team'
    })
  });

  const incident = await response.json();
  console.log('Incident created:', incident.result.number);
};
```

---

### 2. Jira Service Management

**특징**: Atlassian 생태계 통합, 개발팀 친화적

```python
from jira import JIRA

jira = JIRA(
    server='https://your-domain.atlassian.net',
    basic_auth=('email@example.com', 'api_token')
)

# 티켓 생성
issue = jira.create_issue(
    project='SD',
    summary='Application error on production',
    description='Users reporting 500 errors on checkout page',
    issuetype={'name': 'Incident'},
    priority={'name': 'High'},
    customfield_10001={'value': 'Production'}  # Environment
)

print(f"Created ticket: {issue.key}")

# 티켓 상태 변경
jira.transition_issue(issue, 'In Progress')

# 코멘트 추가
jira.add_comment(issue, 'Root cause identified: database connection pool exhausted')
```

---

### 3. Freshservice

**특징**: 사용하기 쉬움, 저렴, SaaS

---

## 📋 인시던트 관리 (Incident Management)

### 인시던트 라이프사이클

```yaml
1. Detection (탐지):
   - 모니터링 알람
   - 사용자 보고
   - 자동 티켓 생성

2. Logging (기록):
   - 티켓 생성
   - 증상 기록
   - 영향 범위 파악

3. Categorization (분류):
   - 카테고리 할당
   - 우선순위 결정
   - 담당팀 배정

4. Investigation (조사):
   - 원인 분석
   - 임시 조치
   - 해결 방안 수립

5. Resolution (해결):
   - 문제 해결
   - 정상 동작 확인
   - 문서화

6. Closure (종료):
   - 사용자 확인
   - 사후 검토
   - 티켓 닫기
```

### 우선순위 매트릭스

| 영향 \ 긴급도 | Critical | High | Medium | Low |
|--------------|----------|------|--------|-----|
| **Extensive** | P1 | P1 | P2 | P3 |
| **Significant** | P1 | P2 | P3 | P4 |
| **Moderate** | P2 | P3 | P4 | P5 |
| **Minor** | P3 | P4 | P5 | P5 |

**SLA 목표**:
```yaml
P1 (Critical):
  - 응답 시간: 15분
  - 해결 시간: 4시간

P2 (High):
  - 응답 시간: 1시간
  - 해결 시간: 8시간

P3 (Medium):
  - 응답 시간: 4시간
  - 해결 시간: 24시간

P4 (Low):
  - 응답 시간: 8시간
  - 해결 시간: 72시간
```

---

## 🔄 변경 관리 (Change Management)

```yaml
Standard Change (표준 변경):
  - 사전 승인된 변경
  - 낮은 위험
  - 예: 인증서 갱신, 패치 적용

Normal Change (일반 변경):
  - CAB 검토 필요
  - 중간 위험
  - 예: 소프트웨어 업그레이드

Emergency Change (긴급 변경):
  - 긴급 승인 프로세스
  - 높은 위험 허용
  - 예: 보안 패치, 장애 복구
```

### Change Request 템플릿

```yaml
Change Request:
  CR Number: CR2024-001
  Title: Upgrade PostgreSQL 14 to 15
  Type: Normal
  Priority: Medium
  Risk: Medium

  Description:
    - Current: PostgreSQL 14.5
    - Target: PostgreSQL 15.2
    - Reason: Performance improvements, security patches

  Impact Assessment:
    - Downtime: 30 minutes
    - Affected Users: 5000
    - Rollback Plan: Yes

  Implementation Plan:
    1. Backup database
    2. Stop application
    3. Upgrade PostgreSQL
    4. Test connections
    5. Start application

  Testing:
    - Unit tests
    - Integration tests
    - Smoke tests

  Approval:
    - Manager: Approved
    - CAB: Approved
    - Security: Approved

  Schedule:
    - Start: 2024-02-15 02:00 AM
    - End: 2024-02-15 02:30 AM
```

---

## 📊 CMDB (Configuration Management Database)

```yaml
Configuration Items (CI):
  Hardware:
    - Servers
    - Network devices
    - Storage

  Software:
    - Applications
    - Databases
    - Operating Systems

  Services:
    - Business services
    - IT services
    - Cloud services

  Documentation:
    - Runbooks
    - Procedures
    - Architecture diagrams

Relationships:
  - Runs on
  - Depends on
  - Connected to
  - Backed up by
```

---

## 🔗 ITSM 통합

```yaml
Monitoring → ITSM:
  - Prometheus 알람 → ServiceNow 티켓 자동 생성
  - CloudWatch 이벤트 → Jira 인시던트

SIEM → ITSM:
  - 보안 이벤트 → 보안 티켓 생성
  - 인시던트 대응 워크플로우 자동화

CI/CD → ITSM:
  - 배포 전 Change Request 생성
  - 배포 후 자동 종료

Collaboration:
  - Slack, Teams 통합
  - 티켓 업데이트 알림
  - ChatOps
```

---

## 📈 ITSM 메트릭

```yaml
Incident Management:
  - MTTR (Mean Time To Resolve): 평균 해결 시간
  - MTBF (Mean Time Between Failures): 평균 고장 간격
  - First Call Resolution Rate: 최초 해결률
  - SLA Compliance: SLA 준수율

Change Management:
  - Change Success Rate: 변경 성공률
  - Emergency Change Ratio: 긴급 변경 비율
  - Average Change Lead Time: 평균 변경 소요 시간

Service Desk:
  - Ticket Volume: 티켓 발생 건수
  - Backlog: 미해결 티켓
  - User Satisfaction: 사용자 만족도
```

---

## 🔒 Zone별 배치

| Zone | 배치 | 용도 |
|------|------|------|
| **Zone 0** | Very Common | ITSM 플랫폼 |
| **All Zones** | Common | 통합 및 자동화 |

---

## 🔗 관련 문서

- [Cross-Layer 정의](../00_CrossLayer_정의.md)
- [Monitoring](../01_Monitoring/00_Monitoring_정의.md)

---

**문서 끝**
