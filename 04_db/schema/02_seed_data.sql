-- GR Framework v2.0 - Seed Data
-- Purpose: Example data for vulnerability tracking and CVE-MITRE mapping
-- Database: PostgreSQL 15+

-- ============================================================================
-- 1. Tags (Domain별 주요 태그)
-- ============================================================================

-- Domain M: Monitoring
INSERT INTO tags (id, domain_id, name, name_ko, category, parent_tag_id) VALUES
('M1', 'M', 'Metrics Collection', '메트릭 수집', 'M1', NULL),
('M1.1', 'M', 'Infrastructure Metrics', '인프라 메트릭', 'M1', 'M1'),
('M1.2', 'M', 'Application Metrics', '애플리케이션 메트릭', 'M1', 'M1'),
('M2', 'M', 'APM', '애플리케이션 성능 모니터링', 'M2', NULL),
('M2.1', 'M', 'Backend APM', '백엔드 APM', 'M2', 'M2'),
('M2.3', 'M', 'Database APM', '데이터베이스 APM', 'M2', 'M2'),
('M6', 'M', 'Security Monitoring', '보안 모니터링', 'M6', NULL),
('M6.1', 'M', 'SIEM', 'SIEM', 'M6', 'M6');

-- Domain N: Networking
INSERT INTO tags (id, domain_id, name, name_ko, category, parent_tag_id) VALUES
('N1', 'N', 'Load Balancer', '로드 밸런서', 'N1', NULL),
('N1.2', 'N', 'Layer 7 Load Balancer', 'Layer 7 로드 밸런서', 'N1', 'N1'),
('N6', 'N', 'Service Mesh', '서비스 메시', 'N6', NULL),
('N6.2', 'N', 'Service Mesh Data Plane', '서비스 메시 데이터 플레인', 'N6', 'N6'),
('N7', 'N', 'API Gateway', 'API 게이트웨이', 'N7', NULL),
('N7.1', 'N', 'API Routing', 'API 라우팅', 'N7', 'N7'),
('N8', 'N', 'Network Security', '네트워크 보안', 'N8', NULL),
('N8.2', 'N', 'DDoS Protection', 'DDoS 보호', 'N8', 'N8');

-- Domain S: Security
INSERT INTO tags (id, domain_id, name, name_ko, category, parent_tag_id) VALUES
('S1', 'S', 'Perimeter Security', '경계 보안', 'S1', NULL),
('S1.1', 'S', 'WAF', 'WAF', 'S1', 'S1'),
('S2', 'S', 'Authentication & Authorization', '인증 및 인가', 'S2', NULL),
('S2.2', 'S', 'Authorization', '인가', 'S2', 'S2'),
('S2.2.3', 'S', 'OAuth 2.0 & JWT', 'OAuth 2.0 & JWT', 'S2', 'S2.2'),
('S3', 'S', 'Data Protection', '데이터 보호', 'S3', NULL),
('S3.1', 'S', 'Encryption in Transit', '전송 중 암호화', 'S3', 'S3'),
('S3.2', 'S', 'Encryption at Rest', '저장 암호화', 'S3', 'S3'),
('S4', 'S', 'Vulnerability Management', '취약점 관리', 'S4', NULL),
('S4.1', 'S', 'Vulnerability Scanning', '취약점 스캐닝', 'S4', 'S4'),
('S7', 'S', 'Application Security', '애플리케이션 보안', 'S7', NULL),
('S7.1', 'S', 'SAST', 'SAST', 'S7', 'S7');

-- Domain A: Application
INSERT INTO tags (id, domain_id, name, name_ko, category, parent_tag_id) VALUES
('A1', 'A', 'Frontend Applications', '프론트엔드 애플리케이션', 'A1', NULL),
('A1.1', 'A', 'Web Frontend (SPA)', '웹 프론트엔드 (SPA)', 'A1', 'A1'),
('A2', 'A', 'Backend Applications', '백엔드 애플리케이션', 'A2', NULL),
('A2.2', 'A', 'Microservices', '마이크로서비스', 'A2', 'A2'),
('A3', 'A', 'API & Integration', 'API 및 통합', 'A3', NULL),
('A3.1', 'A', 'RESTful API', 'RESTful API', 'A3', 'A3'),
('A4', 'A', 'AI/ML Applications', 'AI/ML 애플리케이션', 'A4', NULL),
('A4.2', 'A', 'RAG', 'RAG', 'A4', 'A4');

-- Domain D: Data
INSERT INTO tags (id, domain_id, name, name_ko, category, parent_tag_id) VALUES
('D1', 'D', 'Relational Database', '관계형 데이터베이스', 'D1', NULL),
('D1.1', 'D', 'RDBMS', 'RDBMS', 'D1', 'D1'),
('D2', 'D', 'NoSQL & Vector Database', 'NoSQL 및 벡터 데이터베이스', 'D2', NULL),
('D2.2', 'D', 'Vector Database', '벡터 데이터베이스', 'D2', 'D2');

-- Domain T: Tech Stack
INSERT INTO tags (id, domain_id, name, name_ko, category, parent_tag_id) VALUES
('T1', 'T', 'Programming Languages & Frameworks', '프로그래밍 언어 및 프레임워크', 'T1', NULL),
('T1.1', 'T', 'JavaScript/TypeScript', 'JavaScript/TypeScript', 'T1', 'T1'),
('T1.3', 'T', 'Python', 'Python', 'T1', 'T1'),
('T2', 'T', 'Databases', '데이터베이스', 'T2', NULL),
('T2.1', 'T', 'PostgreSQL', 'PostgreSQL', 'T2', 'T2'),
('T3', 'T', 'Web Servers & Reverse Proxies', '웹 서버 및 리버스 프록시', 'T3', NULL),
('T3.1', 'T', 'NGINX', 'NGINX', 'T3', 'T3'),
('T3.3', 'T', 'Envoy Proxy', 'Envoy Proxy', 'T3', 'T3');

-- Domain I: Interface
INSERT INTO tags (id, domain_id, name, name_ko, category, parent_tag_id) VALUES
('I1', 'I', 'HTTP-based Protocols', 'HTTP 기반 프로토콜', 'I1', NULL),
('I1.1', 'I', 'RESTful API (HTTP)', 'RESTful API (HTTP)', 'I1', 'I1'),
('I2', 'I', 'RPC', 'RPC', 'I2', NULL),
('I2.1', 'I', 'gRPC', 'gRPC', 'I2', 'I2'),
('I4', 'I', 'Authentication Protocols', '인증 프로토콜', 'I4', NULL),
('I4.1', 'I', 'OAuth 2.0', 'OAuth 2.0', 'I4', 'I4'),
('I5', 'I', 'Database Protocols', '데이터베이스 프로토콜', 'I5', NULL),
('I5.1', 'I', 'PostgreSQL Wire Protocol', 'PostgreSQL Wire Protocol', 'I5', 'I5');

-- ============================================================================
-- 2. Components (실제 인프라 구성요소)
-- ============================================================================

-- Zone 1: Perimeter (L1)
INSERT INTO components (name, component_type, layer_id, zone_id, primary_tag_id, description) VALUES
('NGINX ALB', 'Load Balancer', 'L1', 'Zone_1', 'N1.2', 'Application Load Balancer for HTTPS traffic'),
('Cloudflare WAF', 'Firewall', 'L1', 'Zone_1', 'S1.1', 'Web Application Firewall for DDoS and attack protection'),
('Kong API Gateway', 'API Gateway', 'L1', 'Zone_1', 'N7.1', 'API Gateway for routing and authentication');

-- Zone 2: Application (L2)
INSERT INTO components (name, component_type, layer_id, zone_id, primary_tag_id, description) VALUES
('User Service', 'Microservice', 'L2', 'Zone_2', 'A2.2', 'User management microservice (FastAPI)'),
('Order Service', 'Microservice', 'L2', 'Zone_2', 'A2.2', 'Order processing microservice (FastAPI)'),
('Payment Service', 'Microservice', 'L2', 'Zone_2', 'A2.2', 'Payment processing microservice (FastAPI)'),
('Envoy Sidecar Proxy', 'Proxy', 'L2', 'Zone_2', 'N6.2', 'Service mesh data plane proxy');

-- Zone 3: Data (L3)
INSERT INTO components (name, component_type, layer_id, zone_id, primary_tag_id, description) VALUES
('PostgreSQL User DB', 'Database', 'L3', 'Zone_3', 'D1.1', 'Primary user database (PostgreSQL 15.4)'),
('PostgreSQL Order DB', 'Database', 'L3', 'Zone_3', 'D1.1', 'Order database (PostgreSQL 14.10)'),
('Redis Cache', 'Cache', 'L3', 'Zone_3', 'D2.2', 'Redis cluster for caching (Redis 7.0)'),
('pgvector Docs DB', 'Vector Database', 'L3', 'Zone_3', 'D2.2', 'Vector database for RAG (pgvector 0.5.1)');

-- Zone 5: Endpoint (L5)
INSERT INTO components (name, component_type, layer_id, zone_id, primary_tag_id, description) VALUES
('React Web App', 'Frontend', 'L5', 'Zone_5', 'A1.1', 'React SPA (React 18.2.0, TypeScript 5.0)');

-- ============================================================================
-- 3. Component-Tag Mappings
-- ============================================================================

-- NGINX ALB tags
INSERT INTO component_tags (component_id, tag_id, is_primary) VALUES
(1, 'N1.2', TRUE),  -- Layer 7 Load Balancer
(1, 'S3.1', FALSE),  -- TLS
(1, 'M1.2', FALSE),  -- Metrics
(1, 'I1.1', FALSE);  -- HTTP/HTTPS

-- User Service tags
INSERT INTO component_tags (component_id, tag_id, is_primary) VALUES
(4, 'A2.2', TRUE),   -- Microservice
(4, 'S2.2.3', FALSE),  -- JWT auth
(4, 'M2.1', FALSE),  -- APM
(4, 'I1.1', FALSE);  -- REST API

-- PostgreSQL User DB tags
INSERT INTO component_tags (component_id, tag_id, is_primary) VALUES
(8, 'D1.1', TRUE),   -- RDBMS
(8, 'S3.2', FALSE),  -- Encryption at Rest
(8, 'M2.3', FALSE);  -- Database APM

-- ============================================================================
-- 4. Tech Stack Components
-- ============================================================================

INSERT INTO tech_stack_components (tech_stack_tag, name, version, vendor, component_id, layer_id, zone_id) VALUES
-- React (Frontend)
('T1.1', 'React', '18.2.0', 'Meta (Facebook)', 9, 'L5', 'Zone_5'),

-- FastAPI (Backend)
('T1.3', 'FastAPI', '0.104.0', 'Sebastián Ramírez', 4, 'L2', 'Zone_2'),
('T1.3', 'FastAPI', '0.104.0', 'Sebastián Ramírez', 5, 'L2', 'Zone_2'),
('T1.3', 'FastAPI', '0.104.0', 'Sebastián Ramírez', 6, 'L2', 'Zone_2'),

-- PostgreSQL (Database)
('T2.1', 'PostgreSQL', '15.4', 'PostgreSQL Global Development Group', 8, 'L3', 'Zone_3'),
('T2.1', 'PostgreSQL', '14.10', 'PostgreSQL Global Development Group', 9, 'L3', 'Zone_3'),

-- NGINX (Load Balancer)
('T3.1', 'NGINX', '1.25.0', 'F5 Networks', 1, 'L1', 'Zone_1'),

-- Envoy (Service Mesh)
('T3.3', 'Envoy Proxy', '1.28.0', 'Envoy Project', 7, 'L2', 'Zone_2');

-- ============================================================================
-- 5. CVE 데이터 (실제 CVE 예시)
-- ============================================================================

-- CVE-2024-67890: PostgreSQL 14.0 SQL Injection (가상 예시)
INSERT INTO cve (cve_id, description, published_date, last_modified_date, cvss_v3_score, cvss_v3_vector, severity, exploitability, cwe_id, references) VALUES
('CVE-2024-67890',
 'SQL Injection vulnerability in PostgreSQL versions 14.0 to 14.9 allows unauthenticated attackers to execute arbitrary SQL commands via crafted input in certain query parameters.',
 '2024-10-15',
 '2024-10-20',
 9.8,
 'CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H',
 'Critical',
 'Functional',
 'CWE-89',
 ARRAY['https://nvd.nist.gov/vuln/detail/CVE-2024-67890', 'https://www.postgresql.org/support/security/']);

-- CVE-2023-44487: HTTP/2 Rapid Reset (실제 CVE)
INSERT INTO cve (cve_id, description, published_date, last_modified_date, cvss_v3_score, cvss_v3_vector, severity, exploitability, cwe_id, references) VALUES
('CVE-2023-44487',
 'The HTTP/2 protocol allows a denial of service (server resource consumption) because request cancellation can reset many streams quickly, as exploited in the wild in August through October 2023.',
 '2023-10-10',
 '2023-10-13',
 7.5,
 'CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H',
 'High',
 'High',
 'CWE-400',
 ARRAY['https://nvd.nist.gov/vuln/detail/CVE-2023-44487', 'https://blog.cloudflare.com/technical-breakdown-http2-rapid-reset-ddos-attack/']);

-- CVE-2024-12345: React <18.2.0 XSS (가상 예시)
INSERT INTO cve (cve_id, description, published_date, last_modified_date, cvss_v3_score, cvss_v3_vector, severity, exploitability, cwe_id, references) VALUES
('CVE-2024-12345',
 'Cross-Site Scripting (XSS) vulnerability in React versions prior to 18.2.0 allows remote attackers to inject arbitrary web script or HTML via user-generated content.',
 '2024-09-01',
 '2024-09-05',
 6.5,
 'CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:U/C:L/I:L/A:N',
 'Medium',
 'Proof of Concept',
 'CWE-79',
 ARRAY['https://nvd.nist.gov/vuln/detail/CVE-2024-12345', 'https://github.com/facebook/react/security/advisories/']);

-- ============================================================================
-- 6. CVE-Tech Stack Mappings
-- ============================================================================

-- PostgreSQL CVE mapping
INSERT INTO cve_tech_stack_mapping (cve_id, tech_stack_tag, tech_stack_component_id, affected_versions, fixed_version, is_affected) VALUES
('CVE-2024-67890', 'T2.1', 5, '14.0 to 14.9', '14.10', FALSE);  -- Already patched to 14.10

-- HTTP/2 Rapid Reset (NGINX, Envoy)
INSERT INTO cve_tech_stack_mapping (cve_id, tech_stack_tag, tech_stack_component_id, affected_versions, fixed_version, is_affected) VALUES
('CVE-2023-44487', 'T3.1', 6, '< 1.25.2', '1.25.2', FALSE),  -- NGINX already patched
('CVE-2023-44487', 'T3.3', 7, '< 1.28.0', '1.28.0', FALSE);  -- Envoy already patched

-- React XSS
INSERT INTO cve_tech_stack_mapping (cve_id, tech_stack_tag, tech_stack_component_id, affected_versions, fixed_version, is_affected) VALUES
('CVE-2024-12345', 'T1.1', 1, '< 18.2.0', '18.2.0', FALSE);  -- React already at 18.2.0

-- ============================================================================
-- 7. CVE-Component Mappings
-- ============================================================================

-- PostgreSQL Order DB affected (가상 예시, 실제로는 이미 패치됨)
INSERT INTO cve_component_mapping (cve_id, component_id, impact_assessment, remediation_plan, remediation_status, remediation_deadline) VALUES
('CVE-2024-67890', 9, 'Critical SQL Injection vulnerability. Full database compromise possible.', 'Emergency patch: Upgrade PostgreSQL 14.0 → 14.10', 'Completed', '2024-10-25');

-- React Web App (XSS)
INSERT INTO cve_component_mapping (cve_id, component_id, impact_assessment, remediation_plan, remediation_status, remediation_deadline) VALUES
('CVE-2024-12345', 9, 'XSS vulnerability in user profile page. 10,000 users potentially affected.', 'Upgrade React 18.1.0 → 18.2.0. Apply DOMPurify for user input.', 'Completed', '2024-09-15');

-- ============================================================================
-- 8. MITRE ATT&CK 데이터
-- ============================================================================

-- Tactics
INSERT INTO mitre_tactics (id, name, name_ko, description, url) VALUES
('TA0001', 'Initial Access', '초기 침투', 'The adversary is trying to get into your network.', 'https://attack.mitre.org/tactics/TA0001/'),
('TA0002', 'Execution', '실행', 'The adversary is trying to run malicious code.', 'https://attack.mitre.org/tactics/TA0002/'),
('TA0006', 'Credential Access', '자격 증명 접근', 'The adversary is trying to steal account names and passwords.', 'https://attack.mitre.org/tactics/TA0006/'),
('TA0009', 'Collection', '수집', 'The adversary is trying to gather data of interest.', 'https://attack.mitre.org/tactics/TA0009/');

-- Techniques
INSERT INTO mitre_techniques (id, tactic_id, name, name_ko, description, is_sub_technique, parent_technique_id, url) VALUES
('T1190', 'TA0001', 'Exploit Public-Facing Application', '공개 애플리케이션 취약점 악용', 'Adversaries may attempt to exploit a weakness in an Internet-facing host or system.', FALSE, NULL, 'https://attack.mitre.org/techniques/T1190/'),
('T1078', 'TA0001', 'Valid Accounts', '유효 계정', 'Adversaries may obtain and abuse credentials of existing accounts.', FALSE, NULL, 'https://attack.mitre.org/techniques/T1078/'),
('T1110', 'TA0006', 'Brute Force', '무차별 대입 공격', 'Adversaries may use brute force techniques to gain access to accounts.', FALSE, NULL, 'https://attack.mitre.org/techniques/T1110/'),
('T1110.001', 'TA0006', 'Password Guessing', '비밀번호 추측', 'Adversaries may use brute force techniques to attempt access by guessing passwords.', TRUE, 'T1110', 'https://attack.mitre.org/techniques/T1110/001/'),
('T1071', 'TA0002', 'Application Layer Protocol', '애플리케이션 계층 프로토콜', 'Adversaries may communicate using OSI application layer protocols.', FALSE, NULL, 'https://attack.mitre.org/techniques/T1071/'),
('T1071.001', 'TA0002', 'Web Protocols', '웹 프로토콜', 'Adversaries may communicate using application layer protocols associated with web traffic.', TRUE, 'T1071', 'https://attack.mitre.org/techniques/T1071/001/');

-- ============================================================================
-- 9. MITRE-CVE Mappings
-- ============================================================================

INSERT INTO mitre_cve_mapping (technique_id, cve_id, relationship_type) VALUES
('T1190', 'CVE-2024-67890', 'exploits'),  -- SQL Injection exploits public-facing app
('T1190', 'CVE-2024-12345', 'exploits'),  -- XSS exploits public-facing app
('T1071.001', 'CVE-2023-44487', 'exploits');  -- HTTP/2 uses web protocols

-- ============================================================================
-- 10. MITRE-Tag Mappings (Detection/Mitigation)
-- ============================================================================

-- T1190 (Exploit Public-Facing Application) detection and mitigation
INSERT INTO mitre_tag_mapping (technique_id, tag_id, mapping_type, detection_method, mitigation_method, affected_layers, affected_zones) VALUES
('T1190', 'S1.1', 'mitigation', 'WAF logs analysis', 'WAF rules for SQL Injection, XSS, OWASP Top 10', ARRAY['L1'], ARRAY['Zone 1']),
('T1190', 'S7.2', 'detection', 'DAST scanning (OWASP ZAP)', 'Regular DAST scans in staging environment', ARRAY['L2'], ARRAY['Zone 2']),
('T1190', 'M6.1', 'detection', 'SIEM correlation rules', 'Monitor for suspicious patterns in logs', ARRAY['L4'], ARRAY['Zone 4']);

-- T1110.001 (Brute Force: Password Guessing) detection and mitigation
INSERT INTO mitre_tag_mapping (technique_id, tag_id, mapping_type, detection_method, mitigation_method, affected_layers, affected_zones) VALUES
('T1110.001', 'S2.2.3', 'mitigation', 'Failed login attempts', 'MFA enforcement, Rate limiting', ARRAY['L1', 'L2'], ARRAY['Zone 1', 'Zone 2']),
('T1110.001', 'M6.1', 'detection', 'SIEM alerts on failed login spikes', 'Alert on >50 failed attempts in 5 minutes', ARRAY['L4'], ARRAY['Zone 4']);

-- ============================================================================
-- 11. MITRE-Tech Stack Mappings
-- ============================================================================

INSERT INTO mitre_tech_stack_mapping (technique_id, tech_stack_tag, attack_vector, affected_layers, affected_zones, detection_tags, mitigation_tags) VALUES
('T1190', 'T2.1', 'SQL Injection (PostgreSQL)', ARRAY['L3'], ARRAY['Zone 3'], ARRAY['S4.1', 'M6.1'], ARRAY['S1.1', 'S7.1'}),
('T1190', 'T1.1', 'XSS (React)', ARRAY['L5'], ARRAY['Zone 5'], ARRAY['S7.2', 'M6.1'], ARRAY['S1.1', 'S7.1'}),
('T1071.001', 'T3.1', 'HTTP/2 Rapid Reset (NGINX)', ARRAY['L1', 'L2'], ARRAY['Zone 1', 'Zone 2'], ARRAY['M1.2', 'M6.2'], ARRAY['N8.2', 'S1.2'});

-- ============================================================================
-- 12. Interface Mappings
-- ============================================================================

-- Frontend → API Gateway (HTTPS/REST/JSON)
INSERT INTO interface_mappings (interface_tag, protocol, port, format, encryption_tag, auth_tag, source_component_id, target_component_id, source_layer, source_zone, target_layer, target_zone, description) VALUES
('I1.1', 'HTTPS', 443, 'JSON', 'S3.1', 'I4.1', 9, 3, 'L5', 'Zone_5', 'L1', 'Zone_1', 'React SPA → Kong API Gateway via HTTPS with OAuth 2.0');

-- API Gateway → User Service (HTTP/REST or gRPC)
INSERT INTO interface_mappings (interface_tag, protocol, port, format, encryption_tag, auth_tag, source_component_id, target_component_id, source_layer, source_zone, target_layer, target_zone, description) VALUES
('I1.1', 'HTTP', 8000, 'JSON', 'S3.1', 'S2.2.3', 3, 4, 'L1', 'Zone_1', 'L2', 'Zone_2', 'Kong → User Service via HTTP with JWT validation (mTLS via Service Mesh)');

-- User Service → PostgreSQL (PostgreSQL Wire Protocol)
INSERT INTO interface_mappings (interface_tag, protocol, port, format, encryption_tag, auth_tag, source_component_id, target_component_id, source_layer, source_zone, target_layer, target_zone, description) VALUES
('I5.1', 'PostgreSQL Wire Protocol', 5432, 'Binary', 'S3.1', NULL, 4, 8, 'L2', 'Zone_2', 'L3', 'Zone_3', 'User Service → PostgreSQL User DB via TLS encrypted connection');

-- ============================================================================
-- 13. Security Controls
-- ============================================================================

INSERT INTO security_controls (control_tag, component_id, implementation_status, effectiveness, last_audit_date, next_audit_date, notes) VALUES
('S1.1', 2, 'Implemented', 'High', '2024-10-01', '2024-12-01', 'Cloudflare WAF with OWASP Core Rule Set'),
('S3.1', 1, 'Implemented', 'High', '2024-09-15', '2024-11-15', 'TLS 1.3 with Let''s Encrypt certificate'),
('S3.2', 8, 'Implemented', 'High', '2024-10-10', '2025-01-10', 'PostgreSQL TDE with AWS KMS'),
('S2.2.3', 4, 'Implemented', 'Medium', '2024-09-20', '2024-12-20', 'JWT authentication with RS256 signing');

-- ============================================================================
-- 14. Compliance Mappings
-- ============================================================================

INSERT INTO compliance_mappings (compliance_tag, framework, control_id, component_id, compliance_status, evidence_url, last_audit_date, next_audit_date) VALUES
('C2.1', 'SOC 2 Type II', 'CC6.1', 2, 'Compliant', 'https://example.com/evidence/soc2-cc6.1', '2024-08-01', '2025-08-01'),
('C2.1', 'SOC 2 Type II', 'CC6.6', 8, 'Compliant', 'https://example.com/evidence/soc2-cc6.6', '2024-08-01', '2025-08-01'),
('C1.1', 'GDPR', 'Art. 32', 8, 'Compliant', 'https://example.com/evidence/gdpr-art32', '2024-07-01', '2025-07-01');

-- ============================================================================
-- 15. Vulnerability Assessment History
-- ============================================================================

INSERT INTO vulnerability_assessments (assessment_date, scanner, total_vulnerabilities, critical_count, high_count, medium_count, low_count, scan_duration_seconds, notes) VALUES
('2024-10-15', 'AWS Inspector', 15, 1, 3, 8, 3, 1800, 'Monthly vulnerability scan. CVE-2024-67890 detected in PostgreSQL 14.0 (Order DB). Emergency patch applied within 24 hours.'),
('2024-11-01', 'Snyk', 8, 0, 2, 5, 1, 900, 'Dependency scan. All High and Critical issues patched.');

-- ============================================================================
-- 16. Staging Tables (Batch Processing Examples)
-- ============================================================================

-- 16.1 Crawling Schedule Setup
INSERT INTO crawling_schedule (source, crawl_type, schedule_cron, is_enabled, last_crawl_at, next_crawl_at, description) VALUES
('NVD', 'cve', '0 */6 * * *', TRUE, '2025-11-20 06:00:00', '2025-11-20 12:00:00', 'NVD CVE 데이터 크롤링 (6시간마다)'),
('GitHub Advisory', 'cve', '0 */12 * * *', TRUE, '2025-11-20 00:00:00', '2025-11-20 12:00:00', 'GitHub Security Advisory 크롤링 (12시간마다)'),
('MITRE ATT&CK', 'mitre_techniques', '0 2 * * *', TRUE, '2025-11-20 02:00:00', '2025-11-21 02:00:00', 'MITRE ATT&CK 기법 크롤링 (매일 02:00)');

-- 16.2 Staging CVE (크롤링된 데이터 예제)
INSERT INTO staging_cve (cve_id, raw_data, data_source, status, crawled_at, reviewed_by, reviewed_at, notes) VALUES
('CVE-2024-99999', '{"id": "CVE-2024-99999", "description": "Buffer overflow in OpenSSL 3.0.0-3.0.9", "cvss_v3_score": 8.1, "severity": "High", "published_date": "2024-11-15", "cwe_id": "CWE-120"}'::jsonb,
 'NVD', 'approved', '2025-11-20 06:30:00', 'admin@example.com', '2025-11-20 09:00:00', 'Verified against NVD official data'),

('CVE-2024-88888', '{"id": "CVE-2024-88888", "description": "XSS vulnerability in Vue.js < 3.3.8", "cvss_v3_score": 6.1, "severity": "Medium", "published_date": "2024-11-18", "cwe_id": "CWE-79"}'::jsonb,
 'GitHub Advisory', 'pending', '2025-11-20 08:00:00', NULL, NULL, NULL),

('CVE-2024-77777', '{"id": "CVE-2024-77777", "description": "Duplicate entry - already exists", "cvss_v3_score": 9.8}'::jsonb,
 'NVD', 'rejected', '2025-11-20 06:45:00', 'admin@example.com', '2025-11-20 09:15:00', 'Already imported as CVE-2024-67890');

-- 16.3 Staging MITRE Techniques
INSERT INTO staging_mitre_techniques (technique_id, tactic_id, raw_data, data_source, status, crawled_at, reviewed_by, reviewed_at) VALUES
('T1059', 'TA0002', '{"id": "T1059", "name": "Command and Scripting Interpreter", "tactic_id": "TA0002", "description": "Adversaries may abuse command and script interpreters..."}'::jsonb,
 'MITRE ATT&CK', 'approved', '2025-11-20 02:15:00', 'auto-validator', '2025-11-20 02:30:00'),

('T1059.001', 'TA0002', '{"id": "T1059.001", "name": "PowerShell", "tactic_id": "TA0002", "parent_technique_id": "T1059", "is_sub_technique": true}'::jsonb,
 'MITRE ATT&CK', 'pending', '2025-11-20 02:20:00', NULL, NULL);

-- 16.4 Batch Processing Jobs
INSERT INTO batch_processing_jobs (job_type, job_name, scheduled_time, started_at, completed_at, status, total_records, processed_records, inserted_records, updated_records, failed_records, executed_by) VALUES
('cve_import', 'Daily CVE Import - 2025-11-20', '2025-11-20 02:00:00', '2025-11-20 02:00:15', '2025-11-20 02:05:30', 'completed', 15, 15, 12, 2, 1, 'batch-scheduler'),
('mitre_import', 'Daily MITRE Import - 2025-11-20', '2025-11-20 02:10:00', '2025-11-20 02:10:05', '2025-11-20 02:12:45', 'completed', 8, 8, 7, 1, 0, 'batch-scheduler'),
('cve_import', 'Daily CVE Import - 2025-11-19', '2025-11-19 02:00:00', '2025-11-19 02:00:10', '2025-11-19 02:08:20', 'completed', 20, 20, 18, 1, 1, 'batch-scheduler');

-- ============================================================================
-- End of Seed Data
-- ============================================================================
