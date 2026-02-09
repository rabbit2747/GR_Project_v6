# GR Framework v2.0 - Phase 1 완료 요약

**세션 날짜**: 2025-11-20
**Phase**: Phase 1 - 3단계 완료
**상태**: ✅ **완료**

---

## 📋 작업 요약

### ✅ 완료된 작업

#### 1. Phase 1 - 2단계: Zone + Tag 도메인 문서 (9개)

**Security Zone 문서 (차원2)**:
1. `00_차원2_개요.md` - v2.0 (7-Zone Model)
2. `Zone_0-A_Untrusted.md` - NEW v2.0
3. `Zone_0-B_Trusted_Partner.md` - NEW v2.0
4. `Zone_1_Perimeter.md` - v2.0
5. `Zone_2_Application.md` - v2.0
6. `Zone_3_Data.md` - v2.0
7. `Zone_4_Management.md` - v2.0
8. `Zone_5_Endpoint.md` - v2.0

**Function Tag 개요 (차원3)**:
9. `00_차원3_개요.md` - v2.0 (10-Domain Model)

**주요 변경사항**:
- Zone 0 세분화: 0-A (Untrusted External 0%), 0-B (Trusted Partner 10%)
- 7-Zone Model 확립
- AI/ML 워크로드 배치 전략 수립
- Domain 확장: 8개 → 10개 (M, N, S, A, D, R, C, P, **T**, **I**)

---

#### 2. Phase 1 - 3단계: Tag 도메인 완료 + DB (10개 Domain 문서)

**10개 Domain 상세 문서**:

1. **Domain_M_Monitoring.md** (v2.0 NEW)
   - v1.0: Management Domain의 일부
   - v2.0: 독립 Domain으로 분리
   - Tags: M1 (Metrics), M2 (APM), M3 (Logs), M4 (Alerting), M5 (Tracing), M6 (Security Monitoring), M7 (Infrastructure), M8 (User Experience)

2. **Domain_N_Networking.md** (v2.0)
   - Tags: N1 (Load Balancer), N2 (Network Infrastructure), N3 (DNS), N4 (CDN), N5 (VPN), N6 (Service Mesh), N7 (API Gateway), N8 (Network Security)

3. **Domain_S_Security.md** (v2.0)
   - v1.0 → v2.0 변경: Vulnerability Management (S4) 추가, AI/ML 보안 (S7.4) 추가
   - Tags: S1 (Perimeter Security), S2 (Authentication & Authorization), S3 (Data Protection), S4 (Vulnerability Management), S5 (Security Monitoring), S6 (IAM), S7 (Application Security), S8 (Compliance & Audit)
   - Total tags: 25 → 35+

4. **Domain_A_Application.md** (v2.0)
   - v1.0 → v2.0 변경: AI/ML 워크로드 (A4) 추가, Serverless (A3.3) 추가
   - Tags: A1 (Frontend), A2 (Backend), A3 (API & Integration), A4 (AI/ML Applications), A5 (Background Jobs)
   - Total tags: 20 → 30+

5. **Domain_D_Data.md** (v2.0)
   - v1.0 → v2.0 변경: Vector Database (D2.2) 추가, Data Streaming (D4.3) 추가
   - Tags: D1 (Relational Database), D2 (NoSQL & Vector DB), D3 (Cache), D4 (Data Processing & Streaming), D5 (Backup & DR)
   - Total tags: 25 → 30+

6. **Domain_R_Resource.md** (v2.0)
   - v1.0 이름: Runtime → v2.0 이름: Resource
   - v1.0 → v2.0 변경: GPU Resources (R2.3) 추가, Serverless Runtime (R3.3) 추가
   - Tags: R1 (Container Runtime), R2 (Compute Resources), R3 (Storage Resources), R4 (Service Mesh & Runtime), R5 (Message Queue)
   - Total tags: 15 → 20+

7. **Domain_C_Compliance.md** (v2.0 **NEW**)
   - v1.0: C = Compute (컴퓨팅) → R (Resource)로 통합
   - v2.0: C = Compliance (독립 Domain 신규 추가)
   - 이유: SOC 2, ISO 27001, GDPR, PCI-DSS 등 규제 강화
   - Tags: C1 (Regulatory Compliance), C2 (Security Standards), C3 (Policy & Governance), C4 (Audit & Logging), C5 (Data Residency & Sovereignty)

8. **Domain_P_Platform.md** (v2.0)
   - v1.0 → v2.0 변경: GitOps (P2.4) 추가, AI/ML Platform (P3.3) 추가
   - Tags: P1 (Cloud Platform), P2 (CI/CD & DevOps), P3 (Container & Orchestration), P4 (Monitoring & Observability Platform), P5 (Secrets Management)
   - Total tags: 20 → 25+

9. **Domain_T_TechStack.md** (v2.0 **NEW**)
   - **핵심 목적**: CVE-MITRE ATT&CK 매핑
   - Tags: T1 (Programming Languages & Frameworks), T2 (Databases), T3 (Web Servers), T4 (Infrastructure & DevOps Tools), T5 (AI/ML Stack)
   - **CVE 매핑 흐름**: CVE → Tech Stack Tag (T2.1) → Component → Layer/Zone

10. **Domain_I_Interface.md** (v2.0 **NEW**)
    - **핵심 목적**: 통신 프로토콜, API 스타일, 데이터 포맷 매핑
    - Tags: I1 (HTTP-based), I2 (RPC), I3 (Message Queue), I4 (Authentication Protocols), I5 (Database Protocols), I6 (File Transfer)
    - **통신 흐름 가시화**: Frontend (A1.1) → I1.1 (REST/JSON) → S2.2.3 (JWT) → Backend (A2.2)

**Domain 총계**:
- **v1.0**: 8개 (M, N, S, A, D, R, C, P)
- **v2.0**: 10개 (M, N, S, A, D, R, C, P, **T**, **I**)
- **Total Tags**: 165+ → **280+**

---

#### 3. Database Schema 설계 (Atomized Format)

**파일**: `04_Database_Schema/01_schema.sql`

**핵심 설계 결정**:
- ✅ **Atomized relational format** (정규화된 관계형 테이블)
- ✅ **NO STIX native storage** (JSONB 저장 없음)
- ✅ **STIX 변환**: On-demand 또는 Batch 변환 (별도 스크립트)
- ✅ **Batch Processing Workflow**: 크롤링 → Staging → 검토 → 예약된 시간에 배치 등록

**테이블 구조 (10개 그룹, 34 테이블)**:

1. **Dimension Tables** (차원 테이블)
   - `layers` (9개: L0, L1-L7, Cross-Layer)
   - `zones` (7개: Zone 0-A, 0-B, 1-5)
   - `domains` (10개: M, N, S, A, D, R, C, P, T, I)
   - `tags` (280+ tags: M1.1, N1.2, S2.2.3, T2.1, I1.1, ...)

2. **Component Tables** (구성요소)
   - `components` (인프라 구성요소)
   - `component_tags` (N:N 관계)
   - `tech_stack_components` (T Domain: CVE 매핑 핵심)

3. **CVE Tables** (취약점)
   - `cve` (CVE 정보 + 배치 처리 필드)
   - `cve_tech_stack_mapping` (CVE → Tech Stack)
   - `cve_component_mapping` (CVE → Component)

3.1 **Staging Tables** (배치 처리용 - NEW)
   - `staging_cve` (크롤링된 CVE 데이터 임시 저장)
   - `staging_mitre_techniques` (크롤링된 MITRE 데이터 임시 저장)
   - `batch_processing_jobs` (배치 작업 추적)
   - `crawling_schedule` (크롤링 스케줄 관리)

4. **MITRE ATT&CK Tables**
   - `mitre_tactics` (Tactics)
   - `mitre_techniques` (Techniques)
   - `mitre_cve_mapping` (Technique → CVE)
   - `mitre_tag_mapping` (Technique → Tag: Detection/Mitigation)
   - `mitre_tech_stack_mapping` (Technique → Tech Stack)

5. **Interface Tables** (I Domain)
   - `interface_mappings` (통신 프로토콜, 포트, 암호화, 인증)

6. **Security & Compliance Tables**
   - `security_controls` (보안 통제 구현)
   - `compliance_mappings` (규제 준수)

7. **Audit Tables**
   - `audit_log` (변경 이력)
   - `vulnerability_assessments` (취약점 스캔 이력)

**Views** (유틸리티 뷰 3개):
- `v_cve_impact_summary`: CVE 영향 요약
- `v_component_security_posture`: 구성요소 보안 상태
- `v_mitre_attack_coverage`: MITRE ATT&CK 탐지/완화 커버리지

---

#### 4. Seed Data (실제 예제 데이터)

**파일**: `04_Database_Schema/02_seed_data.sql`

**포함된 데이터**:

1. **Tags** (50+ 주요 태그)
   - Domain M, N, S, A, D, T, I별 핵심 태그

2. **Components** (9개 실제 구성요소)
   - Zone 1: NGINX ALB, Cloudflare WAF, Kong API Gateway
   - Zone 2: User Service, Order Service, Payment Service, Envoy Sidecar
   - Zone 3: PostgreSQL User DB, PostgreSQL Order DB, Redis Cache, pgvector Docs DB
   - Zone 5: React Web App

3. **Tech Stack Components** (7개)
   - T1.1: React 18.2.0
   - T1.3: FastAPI 0.104.0
   - T2.1: PostgreSQL 15.4, 14.10
   - T3.1: NGINX 1.25.0
   - T3.3: Envoy Proxy 1.28.0

4. **CVE 데이터** (3개 실제/가상 CVE)
   - CVE-2024-67890: PostgreSQL 14.0 SQL Injection (가상, Critical)
   - CVE-2023-44487: HTTP/2 Rapid Reset (실제, High)
   - CVE-2024-12345: React <18.2.0 XSS (가상, Medium)

5. **CVE-Tech Stack Mappings** (4개)
   - PostgreSQL CVE → T2.1
   - HTTP/2 Rapid Reset → T3.1 (NGINX), T3.3 (Envoy)
   - React XSS → T1.1

6. **MITRE ATT&CK 데이터**
   - Tactics: 4개 (TA0001 Initial Access, TA0002 Execution, TA0006 Credential Access, TA0009 Collection)
   - Techniques: 6개 (T1190, T1078, T1110, T1110.001, T1071, T1071.001)
   - MITRE-CVE Mappings: 3개
   - MITRE-Tag Mappings: Detection/Mitigation 전략
   - MITRE-Tech Stack Mappings: 공격 벡터 매핑

7. **Interface Mappings** (3개 통신 흐름)
   - Frontend → API Gateway (I1.1: HTTPS/REST/JSON + I4.1: OAuth 2.0)
   - API Gateway → User Service (I1.1: HTTP/REST + S2.2.3: JWT)
   - User Service → PostgreSQL (I5.1: PostgreSQL Wire Protocol + S3.1: TLS)

8. **Security Controls** (4개)
   - Cloudflare WAF (S1.1)
   - TLS 1.3 (S3.1)
   - PostgreSQL TDE (S3.2)
   - JWT Authentication (S2.2.3)

9. **Compliance Mappings** (3개)
   - SOC 2 Type II: CC6.1, CC6.6
   - GDPR: Art. 32

10. **Vulnerability Assessments** (2개 스캔 이력)
    - 2024-10-15: AWS Inspector (CVE-2024-67890 발견 및 패치)
    - 2024-11-01: Snyk (의존성 스캔)

---

#### 5. ER Diagram (Entity Relationship Diagram)

**파일**: `04_Database_Schema/03_ER_Diagram.md`

**포함 내용**:
1. **Mermaid ER Diagram**: 전체 테이블 관계도
2. **Key Relationships**: 주요 관계 설명
3. **Dimension Hierarchy**: domains → tags → components → tech_stack_components
4. **CVE Mapping Flow**: CVE → Tech Stack → Component → Layer/Zone
5. **MITRE ATT&CK Integration**: Tactics → Techniques → CVE + Tag Mappings
6. **Interface Communication Flow**: Source → Protocol → Target (Layer/Zone 추적)
7. **Query Examples**: 4개 주요 쿼리 (CVE 검색, MITRE 매핑, 통신 흐름)
8. **Index Strategy**: 성능 최적화 인덱스 전략
9. **STIX Export Mapping**: STIX 2.1 변환 매핑 (Batch export 가능)

---

#### 6. Batch Processing Workflow (배치 처리 워크플로우)

**파일**: `04_Database_Schema/04_Batch_Processing_Workflow.md`

**중요 아키텍처 변경**:
```
기존 (실시간 방식):
  크롤링 → 즉시 DB 등록

신규 (배치 방식):
  크롤링 → Staging → 검토 → 예약된 시간에 배치 등록
```

**추가된 테이블** (4개):
1. `staging_cve`: 크롤링된 CVE 데이터 임시 저장
   - raw_data (JSONB): 크롤링된 원본 JSON
   - status: pending → reviewed → approved → imported
   - 검토 워크플로우 지원

2. `staging_mitre_techniques`: 크롤링된 MITRE 데이터 임시 저장
   - MITRE ATT&CK 데이터 검증 및 승인
   - 동일한 상태 관리 워크플로우

3. `batch_processing_jobs`: 배치 작업 실행 추적
   - job_type: cve_import, mitre_import, cleanup
   - 성공/실패 메트릭, 에러 로그
   - 성능 모니터링

4. `crawling_schedule`: 크롤링 스케줄 관리
   - schedule_cron: 크론 표현식 ("0 2 * * *")
   - 소스별 스케줄 관리 (NVD, GitHub, MITRE)
   - 다음 실행 시간 자동 계산

**CVE 테이블 업데이트**:
- `import_status`: active, staged, archived
- `data_source`: NVD, GitHub Advisory, MITRE
- `imported_at`: 실제 DB 등록 시간
- `imported_by`: 등록한 사용자/시스템

**워크플로우 단계**:
1. **Phase 1: 크롤링** (지속적)
   - NVD: 매 6시간
   - GitHub: 매 12시간
   - MITRE: 매일

2. **Phase 2: 검토** (수동/자동)
   - 자동 검증: JSON 스키마, CVE ID 형식, 중복 체크
   - 수동 검토: 데이터 정확성, 충돌 확인
   - 상태 변경: pending → reviewed → approved/rejected

3. **Phase 3: 배치 처리** (예약)
   - Daily Import: 매일 02:00 AM
   - Weekly Cleanup: 매주 일요일 03:00 AM
   - Monthly Archive: 매월 1일 04:00 AM

**운영 가이드**:
- 일일/주간/월간 체크리스트
- 알림 설정 (Critical/Warning/Info)
- 트러블슈팅 가이드
- 성능 최적화 전략

---

## 🎯 핵심 성과

### 1. v2.0 아키텍처 완성

**3차원 분류 체계**:
```
Layer (9개) × Zone (7개) × Tag (280+)
= 17,640개 조합 가능
```

**새로운 Domain 추가**:
- **Domain T (Tech Stack)**: CVE-MITRE ATT&CK 매핑의 핵심
- **Domain I (Interface)**: 통신 프로토콜 가시화

### 2. CVE 매핑 완성

**매핑 흐름**:
```
CVE-2024-67890 (PostgreSQL SQL Injection)
  ↓ Tech Stack Tag
T2.1 (PostgreSQL 14.0-14.9)
  ↓ Component
PostgreSQL Order DB (L3, Zone 3)
  ↓ Impact Assessment
Critical (CVSS 9.8) → 24시간 SLA
  ↓ Remediation
Upgrade: 14.0 → 14.10 (완료)
```

### 3. MITRE ATT&CK 통합

**통합 전략**:
```
MITRE Technique (T1190: Exploit Public-Facing Application)
  ↓ CVE Mapping
CVE-2024-67890, CVE-2024-12345
  ↓ Tech Stack Mapping
T2.1 (PostgreSQL), T1.1 (React)
  ↓ Tag Mapping (Detection/Mitigation)
Detection: S1.1 (WAF), M6.1 (SIEM), S7.2 (DAST)
Mitigation: S7.1 (SAST), Input Validation
```

### 4. Atomized Database 설계

**설계 원칙**:
- ✅ 정규화된 관계형 구조 (3NF)
- ✅ CVE, MITRE, Tech Stack, Interface 완벽 통합
- ✅ STIX 변환 가능 (On-demand)
- ✅ 34 테이블, 280+ 태그 지원
- ✅ 실제 데이터 예제 포함
- ✅ **배치 처리 워크플로우**: 크롤링 → Staging → 검토 → 예약 등록

---

## 📊 문서 통계

### Phase 1 전체 문서 현황

| 단계 | 문서 유형 | 파일 수 | 상태 |
|------|----------|---------|------|
| 1단계 | 차원 + Layer | 11개 | ✅ 완료 |
| 2단계 | Zone + Tag 개요 | 9개 | ✅ 완료 |
| 3단계 | Domain 상세 | 10개 | ✅ 완료 |
| 3단계 | Database Schema | 4개 | ✅ 완료 |
| **합계** | | **34개** | ✅ **완료** |

### 파일 목록

**차원2 (Security Zone)**: 9개 파일
```
02_차원2_Security_Zone/
├── 00_차원2_개요.md (v2.0)
├── Zone_0-A_Untrusted.md (NEW v2.0)
├── Zone_0-B_Trusted_Partner.md (NEW v2.0)
├── Zone_1_Perimeter.md (v2.0)
├── Zone_2_Application.md (v2.0)
├── Zone_3_Data.md (v2.0)
├── Zone_4_Management.md (v2.0)
└── Zone_5_Endpoint.md (v2.0)
```

**차원3 (Function Tag)**: 11개 파일
```
03_차원3_Function_Tag/
├── 00_차원3_개요.md (v2.0)
├── Domain_M_Monitoring.md (NEW v2.0)
├── Domain_N_Networking.md (v2.0)
├── Domain_S_Security.md (v2.0)
├── Domain_A_Application.md (v2.0)
├── Domain_D_Data.md (v2.0)
├── Domain_R_Resource.md (v2.0)
├── Domain_C_Compliance.md (NEW v2.0)
├── Domain_P_Platform.md (v2.0)
├── Domain_T_TechStack.md (NEW v2.0)
└── Domain_I_Interface.md (NEW v2.0)
```

**Database Schema**: 4개 파일
```
04_Database_Schema/
├── 01_schema.sql (34 tables with batch processing, views, indexes)
├── 02_seed_data.sql (실제 예제 데이터)
├── 03_ER_Diagram.md (Mermaid diagram, queries)
└── 04_Batch_Processing_Workflow.md (배치 처리 워크플로우)
```

---

## 🚀 다음 단계 (Phase 2)

### Phase 2 - 보안 학습 MAP 구성

**예상 작업**:
1. **보안 개념 매핑**: MITRE ATT&CK Technique → 학습 경로
2. **취약점 분석 교육**: CVE 분석 방법론
3. **실습 시나리오**: Layer/Zone별 공격 시뮬레이션
4. **학습 진도 추적**: 학생 학습 이력 DB 설계

**우선순위**:
1. MITRE ATT&CK 기반 학습 경로 설계
2. CVE 분석 실습 시나리오
3. Zone별 보안 통제 실습
4. 학습 평가 시스템

---

## 📝 참고 사항

### STIX 변환 전략

**사용자 결정 사항**:
> "그냥 우리는 DB에 취약점을 원자화 시켜놓고 필요할때, 아니면 어느정도 DB가 취약점들을 원자화 시키게 되면 한번에 STIX로 변환하는 걸로 할까?"

**구현 방향**:
1. **Primary Storage**: Atomized relational tables (PostgreSQL)
2. **STIX Export**: On-demand Python script or Batch weekly export
3. **Benefits**:
   - 빠른 쿼리 성능
   - 간단한 스키마 관리
   - STIX 표준 준수 (optional)

**STIX Export 예시** (03_ER_Diagram.md 참조):
```sql
SELECT
    'vulnerability' AS type,
    '2.1' AS spec_version,
    'vulnerability--' || gen_random_uuid() AS id,
    cve_id AS name,
    description,
    cvss_v3_score AS x_cvss_score,
    severity AS x_severity
FROM cve
WHERE published_date > CURRENT_DATE - INTERVAL '30 days';
```

---

## ✅ 완료 체크리스트

- [x] Phase 1 - 1단계: 기반 문서 (차원 + Layer) - 11개
- [x] Phase 1 - 2단계: Zone + Tag 도메인 (1차) - 9개
- [x] Phase 1 - 3단계: Tag 도메인 완료 (10개 Domain)
- [x] Phase 1 - 3단계: Database Schema 설계 (Atomized)
- [x] Phase 1 - 3단계: Seed Data 작성 (실제 예제)
- [x] Phase 1 - 3단계: ER Diagram 생성

**Phase 1 상태**: ✅ **100% 완료**

---

**문서 종료**
