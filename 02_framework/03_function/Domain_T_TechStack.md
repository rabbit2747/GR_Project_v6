# Domain T: Tech Stack (기술 스택)

**버전**: v2.0 (NEW)
**최종 수정**: 2025-11-20
**목적**: CVE-MITRE ATT&CK 매핑, 기술 스택 버전 관리

---

## 1. Domain 개요

### 1.1 정의
Tech Stack Domain은 **소프트웨어 구성요소의 구체적 기술 스택**을 나타내며, **CVE 취약점 매핑의 핵심 Domain**입니다.

### 1.2 v2.0 신규 추가 사유
**핵심 목적**: CVE 취약점을 구체적 기술 스택에 매핑

```
기존 (v1.0):
  CVE-2024-12345 → PostgreSQL 취약점
  문제: PostgreSQL이 어느 Layer/Zone의 어떤 컴포넌트인지 불명확

신규 (v2.0):
  CVE-2024-12345 → T2.1 (PostgreSQL) → D1.1 (RDBMS) → L3, Zone 3
  해결: 구체적 기술 스택 → 기능 → Layer/Zone 매핑 완성
```

### 1.3 핵심 목표
1. **CVE 매핑**: 취약점 → 기술 스택 → 영향 범위 파악
2. **버전 관리**: 모든 구성요소의 버전 추적
3. **패치 우선순위**: CVSS + 영향 범위 기반 우선순위

---

## 2. Tag 체계

### Tag 구조
```
T + [숫자] + (선택적 서브 카테고리)
예: T1.3 (Python/FastAPI), T2.1 (PostgreSQL)
```

---

## 3. Tag 상세 정의

### T1: Programming Languages & Frameworks

**목적**: 애플리케이션 프레임워크 CVE 매핑

**구성 요소**:
- **T1.1**: JavaScript/TypeScript
  - React, Vue.js, Angular
  - Node.js, Express, NestJS

- **T1.2**: Java/Kotlin
  - Spring Boot, Spring Cloud
  - Tomcat, JBoss

- **T1.3**: Python
  - FastAPI, Django, Flask
  - Celery, pandas

- **T1.4**: Go
  - Gin, Echo, Fiber

- **T1.5**: Ruby
  - Rails, Sinatra

**CVE 매핑 예시**:
```yaml
CVE-2024-12345: React <18.2.0 XSS Vulnerability
  Tech Stack Tag: T1.1 (React)
  Affected Components:
    - Frontend SPA (A1.1) → L5, Zone 5
    - Tags: [T1.1, A1.1, I1.1]

  Severity: Medium (CVSS 6.5)
  Impact:
    - XSS in user profile page
    - 10,000 users potentially affected

  Remediation:
    - Upgrade: React 18.1.0 → 18.2.0
    - Workaround: DOMPurify for user input
    - Timeline: 7 days (Medium severity SLA)
```

---

### T2: Databases

**목적**: 데이터베이스 CVE 매핑

**구성 요소**:
- **T2.1**: PostgreSQL
  - PostgreSQL 15.4, 14.10, 13.13
  - Extensions: pgvector, PostGIS

- **T2.2**: MongoDB
  - MongoDB 6.0, 5.0

- **T2.3**: Redis
  - Redis 7.0, 6.2

- **T2.4**: MySQL/MariaDB
  - MySQL 8.0, MariaDB 10.6

**CVE 매핑 예시**:
```yaml
CVE-2024-67890: PostgreSQL 14.0 SQL Injection
  Tech Stack Tag: T2.1 (PostgreSQL 14.0)
  Affected Components:
    - User Database (D1.1) → L3, Zone 3
    - Order Database (D1.1) → L3, Zone 3
    - Tags: [T2.1, D1.1, S3.2]

  Severity: Critical (CVSS 9.8)
  Exploitability: Public exploit available
  Impact:
    - Unauthenticated SQL injection
    - Full database compromise possible
    - 2 instances affected

  Remediation:
    - Emergency Patch: PostgreSQL 14.0 → 14.10
    - Timeline: 24 hours (Critical SLA)
    - Rollback Plan: Snapshot restore
    - Verification: Re-scan with AWS Inspector (S4.1)
```

---

### T3: Web Servers & Reverse Proxies

**목적**: 웹 서버 CVE 매핑

**구성 요소**:
- **T3.1**: NGINX
  - NGINX 1.25.0, OpenResty

- **T3.2**: Apache HTTP Server
  - Apache 2.4

- **T3.3**: Envoy Proxy
  - Envoy 1.28.0

**CVE 매핑 예시**:
```yaml
CVE-2023-44487: HTTP/2 Rapid Reset (NGINX, Envoy)
  Tech Stack Tags:
    - T3.1 (NGINX 1.24.0)
    - T3.3 (Envoy 1.27.0)

  Affected Components:
    - ALB (N1.2) → L1, Zone 1: NGINX
    - Service Mesh (N6.2) → L2, Zone 2: Envoy
    - Tags: [T3.1, N1.2] + [T3.3, N6.2]

  Severity: High (CVSS 7.5)
  Impact: DDoS attack via HTTP/2 RST_STREAM

  Remediation:
    - NGINX: 1.24.0 → 1.25.2
    - Envoy: 1.27.0 → 1.28.0
    - Config: Limit http2_max_concurrent_streams 100
    - Monitoring: Track h2 stream resets (M1.2)
```

---

### T4: Infrastructure & DevOps Tools

**목적**: 인프라 도구 CVE 매핑

**구성 요소**:
- **T4.1**: Docker/Containerd
  - Docker 24.0, containerd 1.7

- **T4.2**: Authentication (Keycloak, Auth0)
- **T4.3**: API Gateway (Kong, Tyk)
- **T4.4**: Kubernetes
  - Kubernetes 1.28, 1.27

- **T4.5**: Monitoring (Prometheus, Grafana)
- **T4.6**: Service Mesh (Istio, Linkerd)
- **T4.7**: Secrets Management (Vault, AWS Secrets Manager)
- **T4.8**: IaC (Terraform, Pulumi)
- **T4.9**: GitOps (ArgoCD, Flux)

**CVE 매핑 예시**:
```yaml
CVE-2024-11111: Kubernetes <1.28.0 Privilege Escalation
  Tech Stack Tag: T4.4 (Kubernetes 1.27.5)
  Affected Components:
    - EKS Cluster (P3.2) → L2, Zone 2
    - Tags: [T4.4, P3.2, R2.2]

  Severity: High (CVSS 8.1)
  Impact:
    - Pod escape to node
    - 10 worker nodes affected

  Remediation:
    - Upgrade: EKS 1.27.5 → 1.28.0
    - Timeline: 7 days (High SLA)
    - Testing: Staging cluster first
```

---

### T5: AI/ML Stack (v2.0 신규)

**목적**: AI/ML 관련 CVE 매핑

**구성 요소**:
- **T5.1**: ML Frameworks
  - PyTorch 2.1, TensorFlow 2.15
  - ONNX Runtime 1.16

- **T5.2**: LLM APIs
  - OpenAI API, Anthropic Claude API
  - Hugging Face Transformers

- **T5.3**: Vector Databases
  - pgvector 0.5.1, Weaviate 1.24
  - Pinecone, Milvus

- **T5.4**: GPU Drivers & CUDA
  - NVIDIA Driver 535.x, CUDA 12.2

**CVE 매핑 예시**:
```yaml
CVE-2024-88888: PyTorch <2.1.0 Model Poisoning
  Tech Stack Tag: T5.1 (PyTorch 2.0.1)
  Affected Components:
    - ML Training (A4.3) → L2, Zone 2
    - Model Serving (A4.1) → L2, Zone 2
    - Tags: [T5.1, A4.1, A4.3, R2.3]

  Severity: High (CVSS 7.8)
  Impact:
    - Malicious model weights
    - 3 GPU instances affected

  Remediation:
    - Upgrade: PyTorch 2.0.1 → 2.1.2
    - Validation: Re-train models
    - Security: Model signing (S7.4)
```

---

## 4. CVE-to-Tech Stack 매핑 흐름

```
CVE 발견 → Tech Stack 식별 → 영향 범위 분석 → 우선순위 결정 → 패치 실행

예시:
CVE-2024-67890 (PostgreSQL 14.0 SQL Injection)
  ↓
T2.1 (PostgreSQL 14.0) 식별
  ↓
영향 받는 컴포넌트 검색:
  - User Database (D1.1, L3, Zone 3)
  - Order Database (D1.1, L3, Zone 3)
  ↓
우선순위 결정:
  - Severity: Critical (CVSS 9.8)
  - Exploitability: Public exploit
  - Impact: 2 production databases
  - SLA: 24 hours
  ↓
패치 실행:
  1. Create snapshot (D5.1)
  2. Test in staging
  3. Rolling update: 14.0 → 14.10
  4. Verify with scan (S4.1)
  5. Update vulnerability DB
```

---

## 5. 데이터베이스 스키마 (Atomized Format)

**Tech Stack 테이블** (CVE 매핑 핵심):
```sql
CREATE TABLE tech_stack_components (
    id SERIAL PRIMARY KEY,
    tech_stack_tag VARCHAR(10) NOT NULL,  -- T2.1, T1.3, etc.
    name VARCHAR(255) NOT NULL,            -- PostgreSQL, FastAPI
    version VARCHAR(50) NOT NULL,          -- 14.0, 0.104.0
    vendor VARCHAR(255),                   -- PostgreSQL Global Development Group
    component_id INT REFERENCES components(id),  -- 연결된 구성요소
    layer_id VARCHAR(10),                  -- L3
    zone_id VARCHAR(10),                   -- Zone 3
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE cve_tech_stack_mapping (
    id SERIAL PRIMARY KEY,
    cve_id VARCHAR(20) NOT NULL,           -- CVE-2024-67890
    tech_stack_tag VARCHAR(10) NOT NULL,   -- T2.1
    tech_stack_component_id INT REFERENCES tech_stack_components(id),
    affected_versions VARCHAR(255),        -- 14.0 to 14.9
    fixed_version VARCHAR(50),             -- 14.10
    cvss_score DECIMAL(3,1),               -- 9.8
    severity VARCHAR(20),                  -- Critical
    exploitability VARCHAR(50),            -- Public exploit available
    created_at TIMESTAMP DEFAULT NOW()
);

-- CVE 검색 쿼리 예시
SELECT
    c.cve_id,
    c.cvss_score,
    c.severity,
    t.tech_stack_tag,
    t.name,
    t.version,
    t.layer_id,
    t.zone_id,
    comp.name AS component_name
FROM cve_tech_stack_mapping c
JOIN tech_stack_components t ON c.tech_stack_component_id = t.id
JOIN components comp ON t.component_id = comp.id
WHERE t.tech_stack_tag = 'T2.1'  -- PostgreSQL
AND c.severity IN ('Critical', 'High')
ORDER BY c.cvss_score DESC;
```

---

## 6. MITRE ATT&CK 통합

```sql
CREATE TABLE mitre_attack_tech_stack (
    id SERIAL PRIMARY KEY,
    technique_id VARCHAR(20) NOT NULL,     -- T1190
    tech_stack_tag VARCHAR(10) NOT NULL,   -- T3.1 (NGINX)
    attack_vector TEXT,                    -- HTTP/2 Rapid Reset
    affected_layers TEXT[],                -- {L1, L2}
    affected_zones TEXT[],                 -- {Zone 1, Zone 2}
    detection_methods TEXT[],              -- {WAF logs, Rate limit monitoring}
    mitigation_tags TEXT[]                 -- {S1.1, N8.2, M1.2}
);
```

---

## 7. Layer/Zone 연관성

| Tech Stack Tag | Domain | Layer | Zone |
|---------------|--------|-------|------|
| T1.1 (React) | A1.1 | L5 | Zone 5 |
| T1.3 (FastAPI) | A2.2 | L2 | Zone 2 |
| T2.1 (PostgreSQL) | D1.1 | L3 | Zone 3 |
| T3.1 (NGINX) | N1.2 | L1 | Zone 1 |
| T4.4 (Kubernetes) | P3.2 | L2 | Zone 2 |
| T5.1 (PyTorch) | A4.3 | L2 | Zone 2 |

---

## 8. 다음 단계

- **Domain S (Security)**: S4.1과 통합 (Vulnerability Scanning)
- **Domain C (Compliance)**: CVE 패치 SLA 준수 추적
- **All Domains**: 모든 Domain의 CVE 매핑 완성

---

**문서 종료**
