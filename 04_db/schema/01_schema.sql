-- GR Framework v2.0 - Atomized Vulnerability Database Schema
-- Purpose: Relational schema for vulnerability tracking with CVE-MITRE mapping
-- Design: Atomized format (NO STIX native storage), convertible to STIX on-demand
-- Workflow: Crawling → Staging → Review → Scheduled Batch Insert → Production DB
-- Database: PostgreSQL 15+

-- ============================================================================
-- 1. 차원 테이블 (Dimension Tables)
-- ============================================================================

-- 1.1 Layer (9개: L0, L1-L7, Cross-Layer)
CREATE TABLE layers (
    id VARCHAR(20) PRIMARY KEY,           -- L0, L1, L2, ..., L7, Cross-Layer
    name VARCHAR(100) NOT NULL,           -- External, Perimeter, Application, ...
    name_ko VARCHAR(100),                 -- 외부, 경계, 애플리케이션, ...
    description TEXT,
    trust_level DECIMAL(3,1),             -- 0.0 ~ 100.0
    position INT NOT NULL,                -- 순서 (0-8)
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 1.2 Security Zone (7개: Zone 0-A, 0-B, 1-5)
CREATE TABLE zones (
    id VARCHAR(20) PRIMARY KEY,           -- Zone_0-A, Zone_0-B, Zone_1, ...
    name VARCHAR(100) NOT NULL,           -- Untrusted External, Trusted Partner, ...
    name_ko VARCHAR(100),                 -- 비신뢰 외부, 신뢰 파트너, ...
    description TEXT,
    trust_level DECIMAL(3,1) NOT NULL,    -- 0%, 10%, 30%, 50%, 80%, 90%, 20%
    allow_internet BOOLEAN DEFAULT FALSE, -- 인터넷 접근 허용 여부
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 1.3 Function Tag Domain (10개: M, N, S, A, D, R, C, P, T, I)
CREATE TABLE domains (
    id VARCHAR(10) PRIMARY KEY,           -- M, N, S, A, D, R, C, P, T, I
    name VARCHAR(100) NOT NULL,           -- Monitoring, Networking, Security, ...
    name_ko VARCHAR(100),                 -- 모니터링, 네트워킹, 보안, ...
    description TEXT,
    domain_type VARCHAR(50),              -- Capability, Control, Service
    version VARCHAR(10) DEFAULT 'v2.0',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 1.4 Function Tags (280+ tags)
CREATE TABLE tags (
    id VARCHAR(20) PRIMARY KEY,           -- M1.1, N1.2, S2.2.3, T2.1, I1.1, ...
    domain_id VARCHAR(10) REFERENCES domains(id),
    name VARCHAR(255) NOT NULL,           -- Infrastructure Metrics, Load Balancer, ...
    name_ko VARCHAR(255),                 -- 인프라 메트릭, 로드 밸런서, ...
    description TEXT,
    category VARCHAR(100),                -- M1 (Metrics Collection), S2 (Authentication), ...
    parent_tag_id VARCHAR(20) REFERENCES tags(id),  -- For hierarchical tags (S2 → S2.1 → S2.1.1)
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- 2. 컴포넌트 테이블 (Component Tables)
-- ============================================================================

-- 2.1 Components (인프라 구성요소)
CREATE TABLE components (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,           -- NGINX ALB, PostgreSQL User DB, React SPA, ...
    component_type VARCHAR(50),           -- Server, Database, Application, Network, ...
    description TEXT,
    layer_id VARCHAR(20) REFERENCES layers(id),
    zone_id VARCHAR(20) REFERENCES zones(id),
    primary_tag_id VARCHAR(20) REFERENCES tags(id),  -- 주요 기능 태그
    status VARCHAR(50) DEFAULT 'active',  -- active, deprecated, planned
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_components_layer_zone ON components(layer_id, zone_id);
CREATE INDEX idx_components_primary_tag ON components(primary_tag_id);

-- 2.2 Component-Tag Mapping (N:N relationship)
CREATE TABLE component_tags (
    id SERIAL PRIMARY KEY,
    component_id INT REFERENCES components(id) ON DELETE CASCADE,
    tag_id VARCHAR(20) REFERENCES tags(id),
    is_primary BOOLEAN DEFAULT FALSE,     -- 주요 기능 여부
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(component_id, tag_id)
);

CREATE INDEX idx_component_tags_component ON component_tags(component_id);
CREATE INDEX idx_component_tags_tag ON component_tags(tag_id);

-- ============================================================================
-- 3. Tech Stack 테이블 (CVE 매핑 핵심)
-- ============================================================================

-- 3.1 Tech Stack Components (T Domain)
CREATE TABLE tech_stack_components (
    id SERIAL PRIMARY KEY,
    tech_stack_tag VARCHAR(20) REFERENCES tags(id),  -- T2.1, T1.3, T3.1, ...
    name VARCHAR(255) NOT NULL,           -- PostgreSQL, FastAPI, NGINX, React, ...
    version VARCHAR(50) NOT NULL,         -- 15.4, 0.104.0, 1.25.0, 18.2.0, ...
    vendor VARCHAR(255),                  -- PostgreSQL Global Development Group, ...
    component_id INT REFERENCES components(id),  -- 연결된 구성요소
    layer_id VARCHAR(20) REFERENCES layers(id),
    zone_id VARCHAR(20) REFERENCES zones(id),
    status VARCHAR(50) DEFAULT 'active',  -- active, deprecated, EOL
    eol_date DATE,                        -- End of Life 날짜
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_tech_stack_tag ON tech_stack_components(tech_stack_tag);
CREATE INDEX idx_tech_stack_component ON tech_stack_components(component_id);
CREATE INDEX idx_tech_stack_layer_zone ON tech_stack_components(layer_id, zone_id);

-- ============================================================================
-- 4. CVE 테이블 (취약점 정보)
-- ============================================================================

-- 4.1 CVE (Common Vulnerabilities and Exposures)
CREATE TABLE cve (
    id SERIAL PRIMARY KEY,
    cve_id VARCHAR(20) UNIQUE NOT NULL,   -- CVE-2024-12345
    description TEXT,
    published_date DATE,
    last_modified_date DATE,
    cvss_v3_score DECIMAL(3,1),           -- 0.0 ~ 10.0
    cvss_v3_vector VARCHAR(255),          -- CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
    severity VARCHAR(20),                 -- Critical, High, Medium, Low
    exploitability VARCHAR(50),           -- Not Defined, Unproven, Proof of Concept, Functional, High
    cwe_id VARCHAR(20),                   -- CWE-79 (XSS), CWE-89 (SQL Injection), ...
    references TEXT[],                    -- URLs to references
    -- Batch Processing Fields
    import_status VARCHAR(50) DEFAULT 'active',  -- active, staged, archived
    data_source VARCHAR(100),             -- NVD, GitHub Advisory, MITRE, ...
    imported_at TIMESTAMP,                -- 실제 DB 등록 시간
    imported_by VARCHAR(255),             -- 등록한 사용자/시스템
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_cve_id ON cve(cve_id);
CREATE INDEX idx_cve_severity ON cve(severity);
CREATE INDEX idx_cve_score ON cve(cvss_v3_score DESC);
CREATE INDEX idx_cve_import_status ON cve(import_status);

-- 4.2 CVE-Tech Stack Mapping (CVE가 영향을 주는 기술 스택)
CREATE TABLE cve_tech_stack_mapping (
    id SERIAL PRIMARY KEY,
    cve_id VARCHAR(20) REFERENCES cve(cve_id) ON DELETE CASCADE,
    tech_stack_tag VARCHAR(20) REFERENCES tags(id),  -- T2.1, T1.3, ...
    tech_stack_component_id INT REFERENCES tech_stack_components(id),
    affected_versions VARCHAR(255),       -- "14.0 to 14.9", "< 18.2.0", ...
    fixed_version VARCHAR(50),            -- "14.10", "18.2.0", ...
    is_affected BOOLEAN DEFAULT TRUE,     -- 현재 시스템이 영향 받는지
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_cve_tech_stack_cve ON cve_tech_stack_mapping(cve_id);
CREATE INDEX idx_cve_tech_stack_tag ON cve_tech_stack_mapping(tech_stack_tag);
CREATE INDEX idx_cve_tech_stack_component ON cve_tech_stack_mapping(tech_stack_component_id);

-- 4.3 CVE-Component Mapping (CVE가 영향을 주는 구성요소)
CREATE TABLE cve_component_mapping (
    id SERIAL PRIMARY KEY,
    cve_id VARCHAR(20) REFERENCES cve(cve_id) ON DELETE CASCADE,
    component_id INT REFERENCES components(id) ON DELETE CASCADE,
    impact_assessment TEXT,               -- 영향 평가
    remediation_plan TEXT,                -- 해결 계획
    remediation_status VARCHAR(50),       -- Not Started, In Progress, Completed
    remediation_deadline DATE,            -- 패치 마감일 (SLA 기반)
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_cve_component_cve ON cve_component_mapping(cve_id);
CREATE INDEX idx_cve_component_component ON cve_component_mapping(component_id);

-- ============================================================================
-- 4.4 Staging Tables (배치 처리용)
-- ============================================================================

-- 4.4.1 Staging CVE (크롤링된 CVE 데이터 임시 저장)
CREATE TABLE staging_cve (
    id SERIAL PRIMARY KEY,
    cve_id VARCHAR(20),                   -- CVE-2024-xxxxx (중복 가능)
    raw_data JSONB NOT NULL,              -- 크롤링된 원본 JSON 데이터
    data_source VARCHAR(100) NOT NULL,    -- NVD, GitHub Advisory, MITRE, ...
    crawled_at TIMESTAMP DEFAULT NOW(),   -- 크롤링 시간
    status VARCHAR(50) DEFAULT 'pending', -- pending, reviewed, approved, rejected, imported
    reviewed_by VARCHAR(255),             -- 검토자
    reviewed_at TIMESTAMP,                -- 검토 시간
    rejection_reason TEXT,                -- 거부 사유
    notes TEXT,                           -- 검토 메모
    imported_to_production BOOLEAN DEFAULT FALSE,
    imported_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_staging_cve_cve_id ON staging_cve(cve_id);
CREATE INDEX idx_staging_cve_status ON staging_cve(status);
CREATE INDEX idx_staging_cve_source ON staging_cve(data_source);
CREATE INDEX idx_staging_cve_crawled ON staging_cve(crawled_at DESC);

-- 4.4.2 Staging MITRE Techniques (크롤링된 MITRE 데이터 임시 저장)
CREATE TABLE staging_mitre_techniques (
    id SERIAL PRIMARY KEY,
    technique_id VARCHAR(20),             -- T1190, T1078, ...
    tactic_id VARCHAR(10),                -- TA0001, TA0002, ...
    raw_data JSONB NOT NULL,              -- 크롤링된 원본 JSON 데이터
    data_source VARCHAR(100) NOT NULL,    -- MITRE ATT&CK, ...
    crawled_at TIMESTAMP DEFAULT NOW(),
    status VARCHAR(50) DEFAULT 'pending', -- pending, reviewed, approved, rejected, imported
    reviewed_by VARCHAR(255),
    reviewed_at TIMESTAMP,
    rejection_reason TEXT,
    notes TEXT,
    imported_to_production BOOLEAN DEFAULT FALSE,
    imported_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_staging_mitre_technique_id ON staging_mitre_techniques(technique_id);
CREATE INDEX idx_staging_mitre_status ON staging_mitre_techniques(status);
CREATE INDEX idx_staging_mitre_crawled ON staging_mitre_techniques(crawled_at DESC);

-- 4.4.3 Batch Processing Jobs (배치 작업 추적)
CREATE TABLE batch_processing_jobs (
    id SERIAL PRIMARY KEY,
    job_type VARCHAR(50) NOT NULL,        -- cve_import, mitre_import, tech_stack_update, ...
    job_name VARCHAR(255),                -- 작업 이름
    scheduled_time TIMESTAMP,             -- 예정 시간
    started_at TIMESTAMP,                 -- 시작 시간
    completed_at TIMESTAMP,               -- 완료 시간
    status VARCHAR(50) DEFAULT 'pending', -- pending, running, completed, failed, cancelled
    total_records INT,                    -- 처리 대상 레코드 수
    processed_records INT DEFAULT 0,      -- 처리된 레코드 수
    inserted_records INT DEFAULT 0,       -- 삽입된 레코드 수
    updated_records INT DEFAULT 0,        -- 업데이트된 레코드 수
    failed_records INT DEFAULT 0,         -- 실패한 레코드 수
    error_log TEXT,                       -- 에러 로그
    executed_by VARCHAR(255),             -- 실행한 사용자/시스템
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_batch_jobs_type ON batch_processing_jobs(job_type);
CREATE INDEX idx_batch_jobs_status ON batch_processing_jobs(status);
CREATE INDEX idx_batch_jobs_scheduled ON batch_processing_jobs(scheduled_time DESC);

-- 4.4.4 Crawling Schedule (크롤링 스케줄 관리)
CREATE TABLE crawling_schedule (
    id SERIAL PRIMARY KEY,
    source VARCHAR(100) NOT NULL,         -- NVD, GitHub Advisory, MITRE, ...
    crawl_type VARCHAR(50) NOT NULL,      -- cve, mitre_techniques, tech_stack, ...
    schedule_cron VARCHAR(100),           -- 크론 표현식: "0 2 * * *" (매일 02:00)
    is_enabled BOOLEAN DEFAULT TRUE,      -- 활성화 여부
    last_crawl_at TIMESTAMP,              -- 마지막 크롤링 시간
    next_crawl_at TIMESTAMP,              -- 다음 크롤링 예정 시간
    last_job_id INT REFERENCES batch_processing_jobs(id),  -- 마지막 작업 ID
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_crawling_schedule_source ON crawling_schedule(source);
CREATE INDEX idx_crawling_schedule_enabled ON crawling_schedule(is_enabled);
CREATE INDEX idx_crawling_schedule_next_crawl ON crawling_schedule(next_crawl_at);

-- ============================================================================
-- 5. MITRE ATT&CK 테이블
-- ============================================================================

-- 5.1 MITRE ATT&CK Tactics
CREATE TABLE mitre_tactics (
    id VARCHAR(10) PRIMARY KEY,           -- TA0001, TA0002, ...
    name VARCHAR(255) NOT NULL,           -- Initial Access, Execution, ...
    name_ko VARCHAR(255),                 -- 초기 침투, 실행, ...
    description TEXT,
    url VARCHAR(500),                     -- MITRE ATT&CK URL
    created_at TIMESTAMP DEFAULT NOW()
);

-- 5.2 MITRE ATT&CK Techniques
CREATE TABLE mitre_techniques (
    id VARCHAR(20) PRIMARY KEY,           -- T1190, T1078, T1110, ...
    tactic_id VARCHAR(10) REFERENCES mitre_tactics(id),
    name VARCHAR(255) NOT NULL,           -- Exploit Public-Facing Application, Valid Accounts, ...
    name_ko VARCHAR(255),                 -- 공개 애플리케이션 취약점 악용, 유효 계정, ...
    description TEXT,
    is_sub_technique BOOLEAN DEFAULT FALSE,
    parent_technique_id VARCHAR(20) REFERENCES mitre_techniques(id),
    url VARCHAR(500),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_mitre_techniques_tactic ON mitre_techniques(tactic_id);

-- 5.3 MITRE ATT&CK - CVE Mapping
CREATE TABLE mitre_cve_mapping (
    id SERIAL PRIMARY KEY,
    technique_id VARCHAR(20) REFERENCES mitre_techniques(id),
    cve_id VARCHAR(20) REFERENCES cve(cve_id),
    relationship_type VARCHAR(50),        -- exploits, enables, related
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(technique_id, cve_id)
);

CREATE INDEX idx_mitre_cve_technique ON mitre_cve_mapping(technique_id);
CREATE INDEX idx_mitre_cve_cve ON mitre_cve_mapping(cve_id);

-- 5.4 MITRE ATT&CK - Tag Mapping (Detection/Mitigation)
CREATE TABLE mitre_tag_mapping (
    id SERIAL PRIMARY KEY,
    technique_id VARCHAR(20) REFERENCES mitre_techniques(id),
    tag_id VARCHAR(20) REFERENCES tags(id),
    mapping_type VARCHAR(50),             -- detection, mitigation, affected
    detection_method TEXT,                -- 탐지 방법
    mitigation_method TEXT,               -- 완화 방법
    affected_layers TEXT[],               -- {L1, L2, L3}
    affected_zones TEXT[],                -- {Zone 1, Zone 2}
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_mitre_tag_technique ON mitre_tag_mapping(technique_id);
CREATE INDEX idx_mitre_tag_tag ON mitre_tag_mapping(tag_id);

-- 5.5 MITRE ATT&CK - Tech Stack Mapping
CREATE TABLE mitre_tech_stack_mapping (
    id SERIAL PRIMARY KEY,
    technique_id VARCHAR(20) REFERENCES mitre_techniques(id),
    tech_stack_tag VARCHAR(20) REFERENCES tags(id),  -- T2.1, T3.1, ...
    attack_vector TEXT,                   -- HTTP/2 Rapid Reset, SQL Injection, ...
    affected_layers TEXT[],
    affected_zones TEXT[],
    detection_tags TEXT[],                -- {S1.1, M6.2, ...} - Detection 가능한 태그
    mitigation_tags TEXT[],               -- {S3.1, N8.2, ...} - 완화 가능한 태그
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_mitre_tech_stack_technique ON mitre_tech_stack_mapping(technique_id);
CREATE INDEX idx_mitre_tech_stack_tag ON mitre_tech_stack_mapping(tech_stack_tag);

-- ============================================================================
-- 6. Interface 테이블 (I Domain)
-- ============================================================================

-- 6.1 Interface Mappings (통신 프로토콜)
CREATE TABLE interface_mappings (
    id SERIAL PRIMARY KEY,
    interface_tag VARCHAR(20) REFERENCES tags(id),  -- I1.1, I2.1, I3.2, ...
    protocol VARCHAR(100) NOT NULL,       -- HTTPS, gRPC, Kafka Protocol, ...
    port INT,                             -- 443, 5432, 9092, ...
    format VARCHAR(50),                   -- JSON, Protobuf, Binary, ...
    encryption_tag VARCHAR(20) REFERENCES tags(id),  -- S3.1 (TLS)
    auth_tag VARCHAR(20) REFERENCES tags(id),        -- S2.2.3 (JWT), I4.1 (OAuth)
    source_component_id INT REFERENCES components(id),
    target_component_id INT REFERENCES components(id),
    source_layer VARCHAR(20) REFERENCES layers(id),
    source_zone VARCHAR(20) REFERENCES zones(id),
    target_layer VARCHAR(20) REFERENCES layers(id),
    target_zone VARCHAR(20) REFERENCES zones(id),
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_interface_tag ON interface_mappings(interface_tag);
CREATE INDEX idx_interface_source ON interface_mappings(source_component_id);
CREATE INDEX idx_interface_target ON interface_mappings(target_component_id);

-- ============================================================================
-- 7. 보안 통제 테이블
-- ============================================================================

-- 7.1 Security Controls (보안 통제 구현)
CREATE TABLE security_controls (
    id SERIAL PRIMARY KEY,
    control_tag VARCHAR(20) REFERENCES tags(id),  -- S1.1, S2.2.3, S3.1, ...
    component_id INT REFERENCES components(id),
    implementation_status VARCHAR(50),    -- Implemented, Planned, Not Applicable
    effectiveness VARCHAR(50),            -- High, Medium, Low
    last_audit_date DATE,
    next_audit_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_security_controls_tag ON security_controls(control_tag);
CREATE INDEX idx_security_controls_component ON security_controls(component_id);

-- 7.2 Compliance Mappings (규제 준수)
CREATE TABLE compliance_mappings (
    id SERIAL PRIMARY KEY,
    compliance_tag VARCHAR(20) REFERENCES tags(id),  -- C1.1, C2.1, C2.2, ...
    framework VARCHAR(100),               -- GDPR, SOC 2, ISO 27001, PCI-DSS, ...
    control_id VARCHAR(100),              -- SOC2_CC6.1, ISO27001_A.9.1.1, ...
    component_id INT REFERENCES components(id),
    compliance_status VARCHAR(50),        -- Compliant, Non-Compliant, In Progress
    evidence_url TEXT,
    last_audit_date DATE,
    next_audit_date DATE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_compliance_tag ON compliance_mappings(compliance_tag);
CREATE INDEX idx_compliance_framework ON compliance_mappings(framework);

-- ============================================================================
-- 8. 감사 및 이력 테이블
-- ============================================================================

-- 8.1 Audit Log (변경 이력)
CREATE TABLE audit_log (
    id SERIAL PRIMARY KEY,
    entity_type VARCHAR(100),             -- Component, CVE, TechStack, ...
    entity_id INT,
    action VARCHAR(50),                   -- CREATE, UPDATE, DELETE, PATCH
    changed_by VARCHAR(255),              -- User or System
    changes JSONB,                        -- {"old": {...}, "new": {...}}
    timestamp TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_audit_log_entity ON audit_log(entity_type, entity_id);
CREATE INDEX idx_audit_log_timestamp ON audit_log(timestamp DESC);

-- 8.2 Vulnerability Assessment History
CREATE TABLE vulnerability_assessments (
    id SERIAL PRIMARY KEY,
    assessment_date DATE NOT NULL,
    scanner VARCHAR(100),                 -- Nessus, AWS Inspector, Snyk, ...
    total_vulnerabilities INT,
    critical_count INT,
    high_count INT,
    medium_count INT,
    low_count INT,
    scan_duration_seconds INT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_vulnerability_assessments_date ON vulnerability_assessments(assessment_date DESC);

-- ============================================================================
-- 9. 유틸리티 Views
-- ============================================================================

-- 9.1 View: CVE Impact Summary
CREATE VIEW v_cve_impact_summary AS
SELECT
    c.cve_id,
    c.cvss_v3_score,
    c.severity,
    c.exploitability,
    COUNT(DISTINCT ccm.component_id) AS affected_components_count,
    COUNT(DISTINCT ctsm.tech_stack_component_id) AS affected_tech_stacks_count,
    STRING_AGG(DISTINCT comp.name, ', ') AS affected_components,
    STRING_AGG(DISTINCT ts.name || ' ' || ts.version, ', ') AS affected_tech_stacks
FROM cve c
LEFT JOIN cve_component_mapping ccm ON c.cve_id = ccm.cve_id
LEFT JOIN components comp ON ccm.component_id = comp.id
LEFT JOIN cve_tech_stack_mapping ctsm ON c.cve_id = ctsm.cve_id
LEFT JOIN tech_stack_components ts ON ctsm.tech_stack_component_id = ts.id
WHERE ccm.remediation_status != 'Completed' OR ccm.remediation_status IS NULL
GROUP BY c.cve_id, c.cvss_v3_score, c.severity, c.exploitability
ORDER BY c.cvss_v3_score DESC;

-- 9.2 View: Component Security Posture
CREATE VIEW v_component_security_posture AS
SELECT
    c.id,
    c.name,
    c.layer_id,
    c.zone_id,
    COUNT(DISTINCT ccm.cve_id) AS total_cve_count,
    COUNT(DISTINCT CASE WHEN cve.severity = 'Critical' THEN ccm.cve_id END) AS critical_cve_count,
    COUNT(DISTINCT CASE WHEN cve.severity = 'High' THEN ccm.cve_id END) AS high_cve_count,
    COUNT(DISTINCT sc.id) AS security_controls_count,
    STRING_AGG(DISTINCT t.id, ', ') AS tags
FROM components c
LEFT JOIN cve_component_mapping ccm ON c.id = ccm.component_id AND ccm.remediation_status != 'Completed'
LEFT JOIN cve ON ccm.cve_id = cve.cve_id
LEFT JOIN security_controls sc ON c.id = sc.component_id
LEFT JOIN component_tags ct ON c.id = ct.component_id
LEFT JOIN tags t ON ct.tag_id = t.id
GROUP BY c.id, c.name, c.layer_id, c.zone_id;

-- 9.3 View: MITRE ATT&CK Coverage
CREATE VIEW v_mitre_attack_coverage AS
SELECT
    mt.id AS technique_id,
    mt.name AS technique_name,
    mta.name AS tactic_name,
    COUNT(DISTINCT mtag.tag_id) AS detection_tag_count,
    STRING_AGG(DISTINCT CASE WHEN mtag.mapping_type = 'detection' THEN t.name END, ', ') AS detection_methods,
    STRING_AGG(DISTINCT CASE WHEN mtag.mapping_type = 'mitigation' THEN t.name END, ', ') AS mitigation_methods
FROM mitre_techniques mt
JOIN mitre_tactics mta ON mt.tactic_id = mta.id
LEFT JOIN mitre_tag_mapping mtag ON mt.id = mtag.technique_id
LEFT JOIN tags t ON mtag.tag_id = t.id
GROUP BY mt.id, mt.name, mta.name
ORDER BY mta.id, mt.id;

-- ============================================================================
-- 10. 초기 데이터 삽입 (Seed Data는 별도 파일)
-- ============================================================================

-- Layer 데이터
INSERT INTO layers (id, name, name_ko, trust_level, position) VALUES
('L0', 'External', '외부', 0.0, 0),
('L1', 'Perimeter', '경계', 30.0, 1),
('L2', 'Application', '애플리케이션', 50.0, 2),
('L3', 'Data', '데이터', 80.0, 3),
('L4', 'Management', '관리', 90.0, 4),
('L5', 'Endpoint', '엔드포인트', 20.0, 5),
('L6', 'Validation', '검증', 85.0, 6),
('L7', 'Coordination', '조정', 95.0, 7),
('Cross-Layer', 'Cross-Layer', '레이어 간', NULL, 8);

-- Zone 데이터
INSERT INTO zones (id, name, name_ko, trust_level, allow_internet) VALUES
('Zone_0-A', 'Untrusted External', '비신뢰 외부', 0.0, TRUE),
('Zone_0-B', 'Trusted Partner', '신뢰 파트너', 10.0, TRUE),
('Zone_1', 'Perimeter', '경계', 30.0, TRUE),
('Zone_2', 'Application', '애플리케이션', 50.0, FALSE),
('Zone_3', 'Data', '데이터', 80.0, FALSE),
('Zone_4', 'Management', '관리', 90.0, FALSE),
('Zone_5', 'Endpoint', '엔드포인트', 20.0, TRUE);

-- Domain 데이터
INSERT INTO domains (id, name, name_ko, domain_type) VALUES
('M', 'Monitoring', '모니터링', 'Capability'),
('N', 'Networking', '네트워킹', 'Capability'),
('S', 'Security', '보안', 'Control'),
('A', 'Application', '애플리케이션', 'Capability'),
('D', 'Data', '데이터', 'Capability'),
('R', 'Resource', '리소스', 'Capability'),
('C', 'Compliance', '컴플라이언스', 'Control'),
('P', 'Platform', '플랫폼', 'Service'),
('T', 'Tech Stack', '기술 스택', 'Reference'),
('I', 'Interface', '인터페이스', 'Reference');

-- Tags (예시, 전체는 별도 seed data 파일에서)
INSERT INTO tags (id, domain_id, name, name_ko, category) VALUES
('M1', 'M', 'Metrics Collection', '메트릭 수집', 'M1'),
('M1.1', 'M', 'Infrastructure Metrics', '인프라 메트릭', 'M1'),
('N1', 'N', 'Load Balancer', '로드 밸런서', 'N1'),
('N1.2', 'N', 'Layer 7 Load Balancer', 'Layer 7 로드 밸런서', 'N1'),
('S1', 'S', 'Perimeter Security', '경계 보안', 'S1'),
('S1.1', 'S', 'WAF', 'WAF', 'S1'),
('T2', 'T', 'Databases', '데이터베이스', 'T2'),
('T2.1', 'T', 'PostgreSQL', 'PostgreSQL', 'T2'),
('I1', 'I', 'HTTP-based Protocols', 'HTTP 기반 프로토콜', 'I1'),
('I1.1', 'I', 'RESTful API', 'RESTful API', 'I1');

-- ============================================================================
-- End of Schema
-- ============================================================================
