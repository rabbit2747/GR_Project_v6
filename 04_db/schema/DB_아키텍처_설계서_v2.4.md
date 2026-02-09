# GR DB 아키텍처 설계서 v2.4
# GR Database Architecture Specification v2.4

> **"PostgreSQL + Neo4j + Pinecone 하이브리드 아키텍처 + MITRE ATT&CK 통합 + 버전 관리 시스템 + 단계별 구현 로드맵 + 실무 리스크 대응"**

---

## 📋 문서 정보

| 항목 | 내용 |
|------|------|
| **문서명** | GR DB 아키텍처 설계서 v2.4 |
| **버전** | 2.4 (2025-01-26) |
| **목적** | GR DB의 물리적 아키텍처, 스키마, API 명세를 정의 |
| **대상 독자** | 개발팀, 데이터 엔지니어, 시스템 아키텍트 |
| **선행 문서** | GR_생태계_마스터플랜_v2.2.md |
| **이전 버전** | v2.3 (DB_아키텍처_설계서_v2.3.md) |
| **주요 변경** | 실무 리스크 대응 전략 추가 (CPE 정규화, 동기화 전략, 버전 비교 로직) |

---

## 🎯 1. 아키텍처 개요

### 설계 철학

**"Each Database for Its Strength"**

GR DB는 단일 데이터베이스가 아닌 **3개 특화 DB의 조합**입니다. 각 DB는 자신이 가장 잘하는 일만 수행합니다.

| Database | 강점 | 약점 | GR에서의 역할 |
|----------|------|------|--------------|
| **PostgreSQL** | ACID, 트랜잭션, 복잡한 조인 | 관계 탐색 느림 | 제품 기본 정보 (불변 팩트) |
| **Neo4j** | 그래프 쿼리, 관계 탐색 | 대용량 데이터 적재 느림 | Zone/Layer/Tag 관계, 공격 경로 |
| **Pinecone** | 벡터 검색, 유사도 계산 | 정형 데이터 저장 불가 | AI/RAG, 제품 유사도 검색 |

---

### 전체 아키텍처 다이어그램

```
┌──────────────────────────────────────────────────────────────┐
│                      Client Applications                      │
│  (자동화 진단 솔루션, GR IaC, GR Atlas, External API Users)    │
└────────────────────────┬─────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────────┐
│                    API Gateway (FastAPI)                      │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  Route Layer                                           │  │
│  │  - /products/* → PostgreSQL                           │  │
│  │  - /graph/* → Neo4j                                   │  │
│  │  - /search/* → Pinecone                               │  │
│  │  - /combined/* → All (통합 쿼리)                       │  │
│  └────────────────────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  Business Logic Layer                                  │  │
│  │  - Data Validation                                     │  │
│  │  - Authorization (API Key, JWT)                        │  │
│  │  - Result Aggregation (Multi-DB 결과 통합)             │  │
│  └────────────────────────────────────────────────────────┘  │
└────────┬─────────────────────┬────────────────────┬──────────┘
         │                     │                    │
         ▼                     ▼                    ▼
┌─────────────────┐  ┌──────────────────┐  ┌─────────────────┐
│  PostgreSQL     │  │     Neo4j        │  │    Pinecone     │
│  (RDS/Aurora)   │  │  (AuraDB/Self)   │  │  (Serverless)   │
├─────────────────┤  ├──────────────────┤  ├─────────────────┤
│ products        │  │ (:Product)       │  │ product_vectors │
│ vendors         │  │ (:Archetype)     │  │ archetype_vecs  │
│ licenses        │  │ (:Layer)         │  │                 │
│ versions        │  │ (:Zone)          │  │ Index:          │
│ cves            │  │ (:Tag)           │  │ - Dimension: 1536│
│                 │  │ [:HAS_ARCHETYPE] │  │ - Metric: cosine│
│                 │  │ [:LOCATED_IN]    │  │                 │
│                 │  │ [:TAGGED_WITH]   │  │                 │
└─────────────────┘  └──────────────────┘  └─────────────────┘
         │                     │                    │
         └─────────────────────┴────────────────────┘
                              │
                              ▼
                   ┌──────────────────────┐
                   │   Data Sync Layer    │
                   │ (Change Data Capture)│
                   │  - PostgreSQL → Neo4j│
                   │  - PostgreSQL → Pinec│
                   └──────────────────────┘
```

---

## 🗄️ 2. PostgreSQL: Master Database

### 역할 및 책임

**Primary Role**: 제품의 불변 정보(Immutable Facts) 저장 및 관리

**저장 데이터**:
- 제품 기본 정보 (이름, 벤더, 라이선스)
- 버전 히스토리
- CVE 매핑 정보
- 메타데이터 (생성일, 수정일, 검증 상태)

**선택 이유**:
- ACID 보장 → 데이터 무결성 필수
- 복잡한 JOIN 쿼리 지원 → 리포팅에 유리
- 성숙한 생태계 → AWS RDS, 백업, 복구 등 운영 도구 풍부

---

### 스키마 설계

#### 2.1 products (제품 마스터)

```sql
CREATE TABLE products (
    -- 기본 식별자
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- 제품 정보 (버전 독립적)
    name VARCHAR(200) NOT NULL,
    name_en VARCHAR(200),                        -- 영문명 (검색용)
    vendor_id UUID REFERENCES vendors(id),       -- FK: 벤더

    -- 보안 식별자 (제품 레벨, 버전 와일드카드)
    cpe_product VARCHAR(500),                    -- "cpe:2.3:a:redis:redis:*:*:*:*:*:*:*:*"

    -- 기술 정보 (제품 공통)
    primary_language VARCHAR(50),                -- 주 개발 언어 (Java, Python 등)
    runtime_dependency VARCHAR(100),             -- JVM, Node.js 등
    architecture_support TEXT[],                 -- [x86_64, ARM64, ...]

    -- 라이선스 (제품 공통, 버전별로 변경될 수도 있음)
    license_id UUID REFERENCES licenses(id),     -- FK: 라이선스
    license_text TEXT,                           -- 라이선스 전문

    -- URL 정보 (제품 공통)
    homepage_url TEXT,
    source_url TEXT,                             -- GitHub, GitLab 등
    documentation_url TEXT,

    -- 설명 (제품 공통)
    description TEXT,                            -- 한글 설명
    description_en TEXT,                         -- 영문 설명

    -- 메타데이터
    verified BOOLEAN DEFAULT FALSE,              -- 전문가 검증 완료 여부
    verification_date TIMESTAMP,
    data_quality_score DECIMAL(3,2),             -- 0.00 ~ 1.00

    -- 감사 정보
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    -- 제약 조건
    CONSTRAINT products_name_unique UNIQUE(name, vendor_id)
);

-- 인덱스
CREATE INDEX idx_products_vendor ON products(vendor_id);
CREATE INDEX idx_products_cpe ON products(cpe_product);
CREATE INDEX idx_products_language ON products(primary_language);
CREATE INDEX idx_products_verified ON products(verified) WHERE verified = TRUE;
CREATE INDEX idx_products_name_search ON products USING gin(to_tsvector('english', name || ' ' || description_en));
```

**샘플 데이터 (Redis)**:
```sql
INSERT INTO products (name, name_en, vendor_id, cpe_product, primary_language,
                      license_id, homepage_url, source_url,
                      description, description_en, verified)
VALUES (
    'Redis',
    'Redis',
    (SELECT id FROM vendors WHERE name = 'Redis Ltd.'),
    'cpe:2.3:a:redis:redis:*:*:*:*:*:*:*:*',  -- 제품 레벨 CPE (버전 와일드카드)
    'C',
    (SELECT id FROM licenses WHERE code = 'RSALv2'),
    'https://redis.io',
    'https://github.com/redis/redis',
    '인메모리 데이터 구조 저장소. 데이터베이스, 캐시, 메시지 브로커로 사용됨',
    'In-memory data structure store, used as database, cache, and message broker',
    TRUE
);
```

---

#### 2.2 product_aliases (제품 별칭) 🆕

**Purpose**: CPE 정규화 및 제품명 별칭 관리 (벤더 변경, 표기 불일치 대응)

> ⚠️ **실무 리스크 대응**: NVD의 CPE 데이터는 벤더명 변경(Sun → Oracle), 표기 불일치(httpd vs Apache Web Server) 등으로 인해 신뢰도가 낮습니다. 이 테이블은 다양한 별칭을 하나의 제품으로 매핑하여 검색 정확도를 보장합니다.

```sql
CREATE TABLE product_aliases (
    -- 기본 식별자
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,

    -- 별칭 정보
    alias_type VARCHAR(50) NOT NULL,           -- 'canonical', 'common_name', 'legacy_name', 'cpe', 'legacy_cpe', 'typo'
    alias_value VARCHAR(500) NOT NULL,         -- 별칭 값

    -- 메타데이터
    is_primary BOOLEAN DEFAULT FALSE,          -- 대표 명칭 여부 (alias_type별로 1개만)
    source VARCHAR(100),                       -- 'nvd', 'manual', 'vendor', 'community'
    confidence DECIMAL(3,2) DEFAULT 1.00,      -- 매핑 신뢰도 (0.00 ~ 1.00)
    notes TEXT,                                -- 별칭 추가 사유

    -- 감사 정보
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    created_by VARCHAR(100),

    -- 제약 조건
    CONSTRAINT product_aliases_unique UNIQUE(product_id, alias_type, alias_value)
);

-- 인덱스
CREATE INDEX idx_product_aliases_product ON product_aliases(product_id);
CREATE INDEX idx_product_aliases_type ON product_aliases(alias_type);
CREATE INDEX idx_product_aliases_value ON product_aliases(alias_value);
CREATE INDEX idx_product_aliases_search ON product_aliases USING gin(to_tsvector('english', alias_value));

-- alias_type별 primary는 1개만 허용
CREATE UNIQUE INDEX idx_product_aliases_primary
ON product_aliases(product_id, alias_type)
WHERE is_primary = TRUE;
```

**alias_type 분류**:
| alias_type | 설명 | 예시 |
|------------|------|------|
| `canonical` | 공식 정규 명칭 | "Apache HTTP Server" |
| `common_name` | 일반적으로 사용되는 이름 | "httpd", "Apache" |
| `legacy_name` | 과거 명칭 (벤더 변경 등) | "Sun Java" → "Oracle Java" |
| `cpe` | 현재 유효한 CPE | "cpe:2.3:a:apache:http_server:*" |
| `legacy_cpe` | 과거 CPE (deprecated) | "cpe:2.3:a:apache:httpd:*" |
| `typo` | 흔한 오타/변형 | "Ngingx" (Nginx 오타) |

**샘플 데이터 (Apache HTTP Server)**:
```sql
-- Apache HTTP Server의 다양한 별칭
INSERT INTO product_aliases (product_id, alias_type, alias_value, is_primary, source, notes)
VALUES
    -- 정규 명칭
    ((SELECT id FROM products WHERE name = 'Apache HTTP Server'),
     'canonical', 'Apache HTTP Server', TRUE, 'vendor', '공식 명칭'),

    -- 일반적 명칭들
    ((SELECT id FROM products WHERE name = 'Apache HTTP Server'),
     'common_name', 'httpd', TRUE, 'community', '가장 흔한 약칭'),
    ((SELECT id FROM products WHERE name = 'Apache HTTP Server'),
     'common_name', 'Apache', FALSE, 'community', NULL),
    ((SELECT id FROM products WHERE name = 'Apache HTTP Server'),
     'common_name', 'Apache Web Server', FALSE, 'community', NULL),
    ((SELECT id FROM products WHERE name = 'Apache HTTP Server'),
     'common_name', 'Apache2', FALSE, 'community', 'Debian/Ubuntu 패키지명'),

    -- CPE
    ((SELECT id FROM products WHERE name = 'Apache HTTP Server'),
     'cpe', 'cpe:2.3:a:apache:http_server:*:*:*:*:*:*:*:*', TRUE, 'nvd', '현재 NVD CPE'),
    ((SELECT id FROM products WHERE name = 'Apache HTTP Server'),
     'legacy_cpe', 'cpe:2.3:a:apache:httpd:*:*:*:*:*:*:*:*', FALSE, 'nvd', '과거 CPE');

-- Oracle Java의 벤더 변경 예시
INSERT INTO product_aliases (product_id, alias_type, alias_value, is_primary, source, notes)
VALUES
    ((SELECT id FROM products WHERE name = 'Oracle Java'),
     'canonical', 'Oracle Java', TRUE, 'vendor', '현재 공식 명칭'),
    ((SELECT id FROM products WHERE name = 'Oracle Java'),
     'legacy_name', 'Sun Java', TRUE, 'manual', '2010년 Oracle 인수 전 명칭'),
    ((SELECT id FROM products WHERE name = 'Oracle Java'),
     'legacy_name', 'Sun Microsystems Java', FALSE, 'manual', NULL),
    ((SELECT id FROM products WHERE name = 'Oracle Java'),
     'legacy_cpe', 'cpe:2.3:a:sun:jdk:*:*:*:*:*:*:*:*', FALSE, 'nvd', 'Sun 시절 CPE');
```

**별칭 검색 함수**:
```sql
-- 별칭으로 제품 ID 찾기
CREATE OR REPLACE FUNCTION find_product_by_alias(search_term VARCHAR)
RETURNS TABLE(product_id UUID, product_name VARCHAR, match_type VARCHAR, confidence DECIMAL) AS $$
BEGIN
    RETURN QUERY
    SELECT
        pa.product_id,
        p.name,
        pa.alias_type,
        pa.confidence
    FROM product_aliases pa
    JOIN products p ON pa.product_id = p.id
    WHERE LOWER(pa.alias_value) = LOWER(search_term)
       OR pa.alias_value ILIKE '%' || search_term || '%'
    ORDER BY
        CASE WHEN LOWER(pa.alias_value) = LOWER(search_term) THEN 0 ELSE 1 END,
        pa.confidence DESC,
        pa.is_primary DESC;
END;
$$ LANGUAGE plpgsql;

-- 사용 예시
-- SELECT * FROM find_product_by_alias('httpd');
-- SELECT * FROM find_product_by_alias('Sun Java');
```

---

#### 2.3 product_versions (제품 버전)

**Purpose**: 같은 제품의 다른 버전들을 관리 (버전별 기능, 취약점, EOL 등이 다름)

```sql
CREATE TABLE product_versions (
    -- 기본 식별자
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,

    -- 버전 정보
    version VARCHAR(50) NOT NULL,                -- "7.0.5", "2.17.1", "1.24.0"
    version_major INT NOT NULL,                  -- 7
    version_minor INT NOT NULL,                  -- 0
    version_patch INT NOT NULL,                  -- 5
    version_prerelease VARCHAR(50),              -- "beta1", "rc2", "alpha"

    -- 버전별 CPE (정확한 버전 명시)
    cpe VARCHAR(500),                            -- "cpe:2.3:a:redis:redis:7.0.5:*:*:*:*:*:*:*"

    -- 버전별 메타데이터
    release_date DATE,                           -- 출시일
    eol_date DATE,                               -- End of Life
    support_status VARCHAR(50),                  -- "active", "lts", "eol", "deprecated"
    is_lts BOOLEAN DEFAULT FALSE,                -- Long-Term Support 여부
    is_stable BOOLEAN DEFAULT TRUE,              -- Stable vs Beta/RC

    -- 버전별 기능 변경
    major_features JSONB,                        -- ["Functions", "ACL v2", "Cluster improvements"]
    breaking_changes JSONB,                      -- ["Removed EVAL command", "Changed config format"]
    security_improvements JSONB,                 -- ["Fixed buffer overflow", "Added TLS 1.3"]

    -- 버전별 기술 정보
    min_os_version VARCHAR(100),                 -- "Linux 3.10+", "Windows Server 2016+"
    dependencies JSONB,                          -- {"openssl": ">=1.1.1", "glibc": ">=2.17"}

    -- 다운로드 정보
    download_url TEXT,                           -- 공식 다운로드 URL
    checksum_sha256 VARCHAR(64),                 -- 파일 무결성 검증용
    package_size_mb DECIMAL(10,2),               -- 패키지 크기 (MB)

    -- 메타데이터
    verified BOOLEAN DEFAULT FALSE,
    verification_date TIMESTAMP,

    -- 감사 정보
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    -- 제약 조건
    CONSTRAINT product_versions_unique UNIQUE(product_id, version),
    CONSTRAINT version_components_check CHECK (
        version_major >= 0 AND
        version_minor >= 0 AND
        version_patch >= 0
    )
);

-- 인덱스
CREATE INDEX idx_product_versions_product ON product_versions(product_id);
CREATE INDEX idx_product_versions_version ON product_versions(version);
CREATE INDEX idx_product_versions_major ON product_versions(version_major, version_minor, version_patch);
CREATE INDEX idx_product_versions_eol ON product_versions(eol_date) WHERE eol_date IS NOT NULL;
CREATE INDEX idx_product_versions_support ON product_versions(support_status);
CREATE INDEX idx_product_versions_lts ON product_versions(is_lts) WHERE is_lts = TRUE;
```

**샘플 데이터 (Redis 버전들)**:
```sql
-- Redis 5.0.14 (구버전)
INSERT INTO product_versions (
    product_id, version, version_major, version_minor, version_patch,
    cpe, release_date, eol_date, support_status, is_lts,
    major_features, download_url, verified
)
VALUES (
    (SELECT id FROM products WHERE name = 'Redis'),
    '5.0.14', 5, 0, 14,
    'cpe:2.3:a:redis:redis:5.0.14:*:*:*:*:*:*:*',
    '2021-10-04', '2024-03-31', 'eol', FALSE,
    '["Streams", "Sorted Set blocking operations", "ZPOPMIN/ZPOPMAX"]'::jsonb,
    'https://download.redis.io/releases/redis-5.0.14.tar.gz',
    TRUE
);

-- Redis 6.2.14 (LTS)
INSERT INTO product_versions (
    product_id, version, version_major, version_minor, version_patch,
    cpe, release_date, eol_date, support_status, is_lts,
    major_features, security_improvements, download_url, verified
)
VALUES (
    (SELECT id FROM products WHERE name = 'Redis'),
    '6.2.14', 6, 2, 14,
    'cpe:2.3:a:redis:redis:6.2.14:*:*:*:*:*:*:*',
    '2023-10-18', '2026-12-31', 'lts', TRUE,
    '["ACL improvements", "SSL/TLS", "Threaded I/O", "CLIENT TRACKING"]'::jsonb,
    '["CVE-2023-28856 patch", "Integer overflow fixes"]'::jsonb,
    'https://download.redis.io/releases/redis-6.2.14.tar.gz',
    TRUE
);

-- Redis 7.0.15 (최신 안정)
INSERT INTO product_versions (
    product_id, version, version_major, version_minor, version_patch,
    cpe, release_date, eol_date, support_status, is_lts,
    major_features, breaking_changes, download_url, verified
)
VALUES (
    (SELECT id FROM products WHERE name = 'Redis'),
    '7.0.15', 7, 0, 15,
    'cpe:2.3:a:redis:redis:7.0.15:*:*:*:*:*:*:*',
    '2024-01-09', NULL, 'active', FALSE,
    '["Functions", "ACL v2", "Cluster improvements", "Command introspection"]'::jsonb,
    '["Removed CONFIG RESETSTAT", "Changed default maxmemory-policy"]'::jsonb,
    'https://download.redis.io/releases/redis-7.0.15.tar.gz',
    TRUE
);

-- Redis 7.2.4 (Edge, 최신 기능)
INSERT INTO product_versions (
    product_id, version, version_major, version_minor, version_patch,
    cpe, release_date, support_status, is_stable,
    major_features, download_url, verified
)
VALUES (
    (SELECT id FROM products WHERE name = 'Redis'),
    '7.2.4', 7, 2, 4,
    'cpe:2.3:a:redis:redis:7.2.4:*:*:*:*:*:*:*',
    '2024-01-09', 'active', TRUE,
    '["Improved eviction", "Hash field expiration", "Probabilistic data structures"]'::jsonb,
    'https://download.redis.io/releases/redis-7.2.4.tar.gz',
    TRUE
);
```

---

#### 2.4 vendors (벤더/개발사)

```sql
CREATE TABLE vendors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL UNIQUE,
    name_en VARCHAR(200),

    -- 회사 정보
    country VARCHAR(2),                          -- ISO 3166-1 alpha-2
    company_type VARCHAR(50),                    -- 'Foundation', 'Commercial', 'Open Source'

    -- URL
    website_url TEXT,
    github_org TEXT,

    -- 보안 신뢰도
    security_trust_score DECIMAL(3,2),           -- 0.00 ~ 1.00

    -- 메타
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 샘플 데이터
INSERT INTO vendors (name, name_en, country, company_type, website_url, github_org)
VALUES
    ('Redis Ltd.', 'Redis Ltd.', 'US', 'Commercial', 'https://redis.com', 'redis'),
    ('Apache Software Foundation', 'Apache Software Foundation', 'US', 'Foundation', 'https://apache.org', 'apache'),
    ('Nginx Inc.', 'Nginx Inc.', 'US', 'Commercial', 'https://nginx.com', 'nginx');
```

---

#### 2.5 licenses (라이선스)

```sql
CREATE TABLE licenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE,            -- 'MIT', 'Apache-2.0', 'GPL-3.0'
    name VARCHAR(200),
    name_en VARCHAR(200),

    -- 분류
    category VARCHAR(50),                        -- 'Permissive', 'Copyleft', 'Proprietary'
    osi_approved BOOLEAN,                        -- OSI 승인 여부

    -- 제약 사항
    commercial_use_allowed BOOLEAN,
    modification_allowed BOOLEAN,
    distribution_allowed BOOLEAN,
    patent_grant BOOLEAN,

    -- 의무 사항
    require_attribution BOOLEAN,
    require_source_disclosure BOOLEAN,

    -- URL
    license_url TEXT,

    created_at TIMESTAMP DEFAULT NOW()
);
```

---

#### 2.6 archetypes (역할 정의)

**Purpose**: 제품이 인프라에서 수행하는 역할 (같은 제품도 버전에 따라 다른 역할 가능)

```sql
CREATE TABLE archetypes (
    -- 기본 식별자
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- 제품 및 버전 연결 🆕
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    version_id UUID REFERENCES product_versions(id) ON DELETE SET NULL,  -- NULL이면 모든 버전에 적용

    -- 또는 버전 범위 지정 (semantic versioning)
    min_version VARCHAR(50),                     -- "7.0.0" (이 버전 이상)
    max_version VARCHAR(50),                     -- "8.0.0" (이 버전 미만)

    -- Archetype 정보
    role VARCHAR(200) NOT NULL,                  -- "In-Memory Cache", "Message Broker"

    -- GR Framework 분류
    layer VARCHAR(10) NOT NULL,                  -- "L5", "L6", "L7"
    zone VARCHAR(20) NOT NULL,                   -- "Zone2", "Zone3"

    -- Function Tags
    primary_tag VARCHAR(20) NOT NULL,            -- "D3.1" (In-Memory Cache)
    secondary_tags JSONB,                        -- ["P2.1", "M1.3"]

    -- 역할 상세
    use_case TEXT,                               -- 사용 시나리오 설명
    deployment_pattern VARCHAR(100),             -- "Standalone", "Cluster", "Replicated"

    -- 메타데이터
    confidence DECIMAL(3,2) DEFAULT 0.95,        -- Archetype 추론 신뢰도
    verified BOOLEAN DEFAULT FALSE,
    verification_date TIMESTAMP,

    -- 감사 정보
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    created_by VARCHAR(100),

    -- 제약 조건
    CONSTRAINT archetype_role_unique UNIQUE(product_id, version_id, role),
    CONSTRAINT version_range_check CHECK (
        (version_id IS NOT NULL) OR
        (min_version IS NOT NULL AND max_version IS NOT NULL) OR
        (version_id IS NULL AND min_version IS NULL AND max_version IS NULL)
    )
);

CREATE INDEX idx_archetypes_product ON archetypes(product_id);
CREATE INDEX idx_archetypes_version ON archetypes(version_id);
CREATE INDEX idx_archetypes_layer ON archetypes(layer);
CREATE INDEX idx_archetypes_zone ON archetypes(zone);
CREATE INDEX idx_archetypes_primary_tag ON archetypes(primary_tag);
CREATE INDEX idx_archetypes_secondary_tags ON archetypes USING GIN(secondary_tags);
```

**샘플 데이터 (Redis 버전별 Archetype)**:

```sql
-- Redis 5.x: 기본 캐시 역할만
INSERT INTO archetypes (product_id, min_version, max_version, role, layer, zone, primary_tag, use_case)
VALUES (
    (SELECT id FROM products WHERE name = 'Redis'),
    '5.0.0', '6.0.0',
    'Simple Cache',
    'L5', 'Zone2',
    'D3.1',  -- In-Memory Cache
    'Application-level caching for fast data access'
);

-- Redis 6.x: SSL/TLS 추가, Zone3도 가능
INSERT INTO archetypes (product_id, min_version, max_version, role, layer, zone, primary_tag, secondary_tags, use_case)
VALUES (
    (SELECT id FROM products WHERE name = 'Redis'),
    '6.0.0', '7.0.0',
    'Secure Cache',
    'L5', 'Zone3',  -- SSL/TLS로 Zone3 가능
    'D3.1',
    '["S2.2", "P2.1"]'::jsonb,  -- SSL/TLS (S2.2), Performance (P2.1)
    'Encrypted caching with ACL for sensitive data'
);

-- Redis 7.x: Functions 추가, Application Runtime 역할도 가능
INSERT INTO archetypes (product_id, min_version, max_version, role, layer, zone, primary_tag, secondary_tags, use_case)
VALUES (
    (SELECT id FROM products WHERE name = 'Redis'),
    '7.0.0', '8.0.0',
    'Advanced Cache + Functions',
    'L5', 'Zone2',
    'D3.1',
    '["A1.7", "S2.2", "P2.1"]'::jsonb,  -- Functions (A1.7), SSL (S2.2), Performance (P2.1)
    'Cache with server-side computation using Functions'
);

-- Redis 7.x의 또 다른 역할: Message Queue
INSERT INTO archetypes (product_id, min_version, max_version, role, layer, zone, primary_tag, secondary_tags, use_case)
VALUES (
    (SELECT id FROM products WHERE name = 'Redis'),
    '7.0.0', '8.0.0',
    'Message Broker',
    'L6', 'Zone2',  -- Runtime 레이어
    'R3.2',  -- Message Queue
    '["I1.4"]'::jsonb,  -- Pub/Sub Protocol
    'Event-driven architecture with Pub/Sub and Streams'
);
```

---

#### 2.7 cves (CVE 취약점)

**Purpose**: CVE 취약점 정보 (제품-버전 매핑은 별도 테이블로 분리)

```sql
CREATE TABLE cves (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- CVE 식별자
    cve_id VARCHAR(20) NOT NULL UNIQUE,          -- 'CVE-2023-12345'

    -- 취약점 정보
    severity VARCHAR(20),                        -- 'Critical', 'High', 'Medium', 'Low'
    cvss_score DECIMAL(3,1),                     -- 0.0 ~ 10.0
    cvss_vector TEXT,                            -- CVSS v3.1 벡터

    -- 설명
    description TEXT,
    description_en TEXT,

    -- 공격 유형 (CVSS 메트릭)
    attack_vector VARCHAR(50),                   -- 'Network', 'Local', 'Physical'
    attack_complexity VARCHAR(50),               -- 'Low', 'High'
    privileges_required VARCHAR(50),             -- 'None', 'Low', 'High'
    user_interaction VARCHAR(50),                -- 'None', 'Required'
    scope VARCHAR(50),                           -- 'Unchanged', 'Changed'

    -- 영향 (Impact)
    confidentiality_impact VARCHAR(20),          -- 'None', 'Low', 'High'
    integrity_impact VARCHAR(20),
    availability_impact VARCHAR(20),

    -- CWE (Common Weakness Enumeration)
    cwe_id VARCHAR(20),                          -- 'CWE-79', 'CWE-89'
    cwe_name VARCHAR(200),                       -- 'SQL Injection', 'XSS'

    -- 날짜
    published_date DATE,
    last_modified_date DATE,

    -- URL
    nvd_url TEXT,
    references JSONB,                            -- [{"url": "...", "source": "vendor"}]

    -- 메타
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_cves_cve_id ON cves(cve_id);
CREATE INDEX idx_cves_severity ON cves(severity);
CREATE INDEX idx_cves_cvss ON cves(cvss_score DESC);
CREATE INDEX idx_cves_published ON cves(published_date DESC);
CREATE INDEX idx_cves_cwe ON cves(cwe_id);
```

---

#### 2.8 cve_product_versions (CVE-제품 버전 매핑)

**Purpose**: CVE가 영향을 미치는 제품 버전 범위 매핑

> ⚠️ **실무 리스크 대응**: 버전 문자열 비교는 SQL로 정확히 수행하기 어렵습니다 ("10.0" < "2.0" 문제). 정수형 컬럼을 분리하여 정확한 범위 검색을 보장합니다.

```sql
CREATE TABLE cve_product_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- CVE 및 제품 연결
    cve_id UUID NOT NULL REFERENCES cves(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,

    -- 영향받는 버전 범위 (문자열 - 표시용)
    affected_version_start VARCHAR(50),          -- "2.0-beta9" (포함)
    affected_version_end VARCHAR(50),            -- "2.15.0" (포함)

    -- 🆕 영향받는 버전 범위 (정수형 - 비교용)
    affected_start_major INT,                    -- 2
    affected_start_minor INT,                    -- 0
    affected_start_patch INT,                    -- 0
    affected_start_prerelease VARCHAR(50),       -- "beta9"
    affected_end_major INT,                      -- 2
    affected_end_minor INT,                      -- 15
    affected_end_patch INT,                      -- 0
    affected_end_prerelease VARCHAR(50),         -- NULL (정식 릴리스)

    -- 또는 정확한 버전 리스트
    affected_versions JSONB,                     -- ["2.14.0", "2.14.1", "2.15.0"]

    -- 또는 버전 조건 (복잡한 경우)
    version_condition VARCHAR(200),              -- ">= 2.0 AND < 2.16 AND != 2.12.2"

    -- 수정된 버전
    fixed_version VARCHAR(50),                   -- "2.17.0" (이 버전부터 안전)
    fixed_version_id UUID REFERENCES product_versions(id) ON DELETE SET NULL,

    -- 플랫폼/아키텍처 제한
    affected_platforms JSONB,                    -- ["Linux", "Windows"]
    affected_architectures JSONB,                -- ["x86_64", "ARM64"]

    -- 매핑 메타데이터
    confidence DECIMAL(3,2) DEFAULT 1.00,        -- 매핑 신뢰도 (0.00 ~ 1.00)
    source VARCHAR(100),                         -- "NVD", "Vendor Advisory", "GitHub Security"
    verification_status VARCHAR(50) DEFAULT 'unverified',  -- 'verified', 'unverified', 'disputed'

    -- 감사 정보
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    created_by VARCHAR(100),

    -- 제약 조건
    CONSTRAINT cve_product_unique UNIQUE(cve_id, product_id, affected_version_start, affected_version_end),
    CONSTRAINT version_range_valid CHECK (
        (affected_version_start IS NOT NULL AND affected_version_end IS NOT NULL) OR
        (affected_versions IS NOT NULL) OR
        (version_condition IS NOT NULL)
    )
);

CREATE INDEX idx_cve_product_versions_cve ON cve_product_versions(cve_id);
CREATE INDEX idx_cve_product_versions_product ON cve_product_versions(product_id);
CREATE INDEX idx_cve_product_versions_fixed ON cve_product_versions(fixed_version_id);
CREATE INDEX idx_cve_product_versions_confidence ON cve_product_versions(confidence);

-- 🆕 버전 범위 비교용 인덱스 (정수형)
CREATE INDEX idx_cve_product_versions_start ON cve_product_versions(
    product_id, affected_start_major, affected_start_minor, affected_start_patch
);
CREATE INDEX idx_cve_product_versions_end ON cve_product_versions(
    product_id, affected_end_major, affected_end_minor, affected_end_patch
);
```

**🆕 버전 비교 함수**:

> ⚠️ **실무 리스크 대응**: 문자열 버전 비교의 한계를 해결하기 위한 정수 기반 비교 함수입니다.

```sql
-- 버전이 범위 내에 있는지 확인하는 함수
CREATE OR REPLACE FUNCTION version_in_range(
    check_major INT, check_minor INT, check_patch INT,
    start_major INT, start_minor INT, start_patch INT,
    end_major INT, end_minor INT, end_patch INT
) RETURNS BOOLEAN AS $$
BEGIN
    -- (major, minor, patch) 튜플 비교
    RETURN (check_major, check_minor, check_patch) >= (start_major, start_minor, start_patch)
       AND (check_major, check_minor, check_patch) <= (end_major, end_minor, end_patch);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 버전 문자열을 파싱하여 정수로 변환하는 함수
CREATE OR REPLACE FUNCTION parse_version(version_str VARCHAR)
RETURNS TABLE(major INT, minor INT, patch INT, prerelease VARCHAR) AS $$
DECLARE
    parts TEXT[];
    version_main VARCHAR;
    prerelease_part VARCHAR;
BEGIN
    -- prerelease 분리 (예: "2.0-beta9" → "2.0", "beta9")
    IF position('-' in version_str) > 0 THEN
        version_main := split_part(version_str, '-', 1);
        prerelease_part := split_part(version_str, '-', 2);
    ELSE
        version_main := version_str;
        prerelease_part := NULL;
    END IF;

    -- 버전 번호 파싱
    parts := string_to_array(version_main, '.');

    major := COALESCE(parts[1]::INT, 0);
    minor := COALESCE(parts[2]::INT, 0);
    patch := COALESCE(parts[3]::INT, 0);
    prerelease := prerelease_part;

    RETURN NEXT;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 특정 제품 버전이 CVE에 영향받는지 확인
CREATE OR REPLACE FUNCTION is_version_affected(
    p_product_id UUID,
    p_version VARCHAR
) RETURNS TABLE(
    cve_id VARCHAR,
    severity VARCHAR,
    cvss_score DECIMAL,
    affected_range VARCHAR
) AS $$
DECLARE
    v_major INT;
    v_minor INT;
    v_patch INT;
BEGIN
    -- 버전 파싱
    SELECT major, minor, patch INTO v_major, v_minor, v_patch
    FROM parse_version(p_version);

    -- 영향받는 CVE 조회
    RETURN QUERY
    SELECT
        c.cve_id,
        c.severity,
        c.cvss_score,
        cpv.affected_version_start || ' ~ ' || cpv.affected_version_end AS affected_range
    FROM cve_product_versions cpv
    JOIN cves c ON cpv.cve_id = c.id
    WHERE cpv.product_id = p_product_id
      AND version_in_range(
          v_major, v_minor, v_patch,
          cpv.affected_start_major, cpv.affected_start_minor, cpv.affected_start_patch,
          cpv.affected_end_major, cpv.affected_end_minor, cpv.affected_end_patch
      )
    ORDER BY c.cvss_score DESC;
END;
$$ LANGUAGE plpgsql;

-- 사용 예시
-- SELECT * FROM is_version_affected(
--     (SELECT id FROM products WHERE name = 'Apache Log4j'),
--     '2.14.0'
-- );
```

**샘플 데이터 (Log4Shell - CVE-2021-44228)**:

```sql
-- 1. CVE 등록
INSERT INTO cves (
    cve_id, severity, cvss_score, cvss_vector,
    description, description_en,
    attack_vector, attack_complexity, privileges_required, user_interaction,
    confidentiality_impact, integrity_impact, availability_impact,
    cwe_id, cwe_name,
    published_date, nvd_url
)
VALUES (
    'CVE-2021-44228',
    'Critical', 10.0,
    'CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H',
    'Apache Log4j2 JNDI 인젝션 취약점. 원격 코드 실행 가능',
    'Apache Log4j2 JNDI injection vulnerability allowing remote code execution',
    'Network', 'Low', 'None', 'None',
    'High', 'High', 'High',
    'CWE-502', 'Deserialization of Untrusted Data',
    '2021-12-10',
    'https://nvd.nist.gov/vuln/detail/CVE-2021-44228'
);

-- 2. Apache Log4j 제품 등록 (이미 있다고 가정)

-- 3. CVE-제품 버전 매핑
INSERT INTO cve_product_versions (
    cve_id, product_id,
    affected_version_start, affected_version_end,
    fixed_version,
    confidence, source, verification_status
)
VALUES (
    (SELECT id FROM cves WHERE cve_id = 'CVE-2021-44228'),
    (SELECT id FROM products WHERE name = 'Apache Log4j'),
    '2.0-beta9',  -- 영향받는 최소 버전
    '2.15.0',     -- 영향받는 최대 버전 (포함)
    '2.17.0',     -- 수정된 버전
    1.00,         -- 100% 확실
    'NVD',
    'verified'
);

-- 4. 예외 버전 (영향 없음) - 별도 레코드
INSERT INTO cve_product_versions (
    cve_id, product_id,
    affected_versions,  -- 특정 버전만
    confidence, source, verification_status
)
VALUES (
    (SELECT id FROM cves WHERE cve_id = 'CVE-2021-44228'),
    (SELECT id FROM products WHERE name = 'Apache Log4j'),
    '["2.12.2", "2.12.3", "2.3.1"]'::jsonb,  -- 이 버전들은 안전
    1.00,
    'Apache Security Advisory',
    'verified'
);
```

---

### 쿼리 예시 (버전 관리 포함) 🆕

**예시 1: 특정 제품의 모든 버전과 지원 상태 조회**
```sql
SELECT
    p.name,
    pv.version,
    pv.support_status,
    pv.is_lts,
    pv.release_date,
    pv.eol_date,
    CASE
        WHEN pv.eol_date IS NULL THEN 'Active'
        WHEN pv.eol_date < CURRENT_DATE THEN 'EOL'
        WHEN pv.eol_date < CURRENT_DATE + INTERVAL '6 months' THEN 'EOL Soon'
        ELSE 'Supported'
    END AS lifecycle_status
FROM products p
JOIN product_versions pv ON p.id = pv.product_id
WHERE p.name = 'Redis'
ORDER BY pv.version_major DESC, pv.version_minor DESC, pv.version_patch DESC;
```

**예시 2: 특정 버전이 영향받는 CVE 조회**
```sql
-- "Redis 6.2.7이 어떤 CVE에 취약한가?"
SELECT
    c.cve_id,
    c.severity,
    c.cvss_score,
    c.description,
    cpv.affected_version_start,
    cpv.affected_version_end,
    cpv.fixed_version
FROM cves c
JOIN cve_product_versions cpv ON c.id = cpv.cve_id
JOIN products p ON cpv.product_id = p.id
WHERE p.name = 'Redis'
  AND '6.2.7' BETWEEN cpv.affected_version_start AND cpv.affected_version_end
ORDER BY c.cvss_score DESC;
```

**예시 3: 제품별 Critical CVE 개수 및 최고 CVSS 점수**
```sql
SELECT
    p.name,
    COUNT(DISTINCT c.cve_id) AS critical_cve_count,
    MAX(c.cvss_score) AS max_cvss,
    string_agg(DISTINCT c.cve_id, ', ' ORDER BY c.cvss_score DESC) AS cve_list
FROM products p
JOIN cve_product_versions cpv ON p.id = cpv.product_id
JOIN cves c ON cpv.cve_id = c.id
WHERE c.severity = 'Critical'
GROUP BY p.id, p.name
HAVING COUNT(DISTINCT c.cve_id) > 0
ORDER BY critical_cve_count DESC, max_cvss DESC;
```

**예시 4: 버전별 Archetype 및 CVE 조회**
```sql
-- "Redis 7.0.15의 역할과 취약점"
SELECT
    p.name,
    pv.version,
    a.role,
    a.layer,
    a.zone,
    a.primary_tag,
    COUNT(DISTINCT c.cve_id) AS cve_count,
    array_agg(DISTINCT c.cve_id ORDER BY c.cvss_score DESC) AS cves
FROM products p
JOIN product_versions pv ON p.id = pv.product_id
LEFT JOIN archetypes a ON p.id = a.product_id
    AND pv.version >= a.min_version
    AND pv.version < a.max_version
LEFT JOIN cve_product_versions cpv ON p.id = cpv.product_id
    AND pv.version BETWEEN cpv.affected_version_start AND cpv.affected_version_end
LEFT JOIN cves c ON cpv.cve_id = c.id
WHERE p.name = 'Redis' AND pv.version = '7.0.15'
GROUP BY p.id, p.name, pv.id, pv.version, a.id, a.role, a.layer, a.zone, a.primary_tag;
```

**예시 5: EOL 임박 버전 (6개월 이내)**
```sql
SELECT
    p.name,
    pv.version,
    pv.support_status,
    pv.eol_date,
    (pv.eol_date - CURRENT_DATE) AS days_until_eol,
    COUNT(DISTINCT c.cve_id) FILTER (WHERE c.severity IN ('Critical', 'High')) AS high_risk_cves
FROM products p
JOIN product_versions pv ON p.id = pv.product_id
LEFT JOIN cve_product_versions cpv ON p.id = cpv.product_id
    AND pv.version BETWEEN cpv.affected_version_start AND cpv.affected_version_end
LEFT JOIN cves c ON cpv.cve_id = c.id
WHERE pv.eol_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '6 months'
GROUP BY p.id, p.name, pv.id, pv.version, pv.support_status, pv.eol_date
ORDER BY pv.eol_date, high_risk_cves DESC;
```

---

#### 2.9 MITRE ATT&CK Integration Tables

**Purpose**: CVE → MITRE → GR Framework 3-Way 통합

```sql
-- MITRE ATT&CK Technique 테이블
CREATE TABLE mitre_techniques (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    technique_id VARCHAR(20) UNIQUE NOT NULL,  -- T1190, T1059.007 등
    name VARCHAR(200) NOT NULL,
    tactic VARCHAR(50),                        -- Initial Access, Execution 등

    -- GR Framework 매핑
    common_layers JSONB,                       -- ["L2", "L7"]
    common_zones JSONB,                        -- ["Zone1", "Zone2"]
    affected_tags JSONB,                       -- ["N2.1", "S3.4", "A1.5"]

    description TEXT,
    mitigation TEXT,
    detection TEXT,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- MITRE Technique 검색 인덱스
CREATE INDEX idx_mitre_technique_id ON mitre_techniques(technique_id);
CREATE INDEX idx_mitre_tactic ON mitre_techniques(tactic);
CREATE INDEX idx_mitre_layers ON mitre_techniques USING GIN(common_layers);
CREATE INDEX idx_mitre_zones ON mitre_techniques USING GIN(common_zones);
CREATE INDEX idx_mitre_tags ON mitre_techniques USING GIN(affected_tags);

-- CVE-MITRE 매핑 테이블
CREATE TABLE cve_mitre_mapping (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cve_id UUID REFERENCES cves(id) ON DELETE CASCADE,
    technique_id UUID REFERENCES mitre_techniques(id) ON DELETE CASCADE,

    -- 매핑 컨텍스트
    confidence DECIMAL(3,2) CHECK (confidence BETWEEN 0.00 AND 1.00),  -- 매핑 신뢰도
    exploit_chain_order INT,                   -- 공격 체인에서의 순서 (1, 2, 3...)
    notes TEXT,                                -- 매핑 근거 설명

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),

    UNIQUE(cve_id, technique_id)
);

-- CVE-MITRE 매핑 인덱스
CREATE INDEX idx_cve_mitre_cve ON cve_mitre_mapping(cve_id);
CREATE INDEX idx_cve_mitre_technique ON cve_mitre_mapping(technique_id);
CREATE INDEX idx_cve_mitre_confidence ON cve_mitre_mapping(confidence);

-- CVE 테이블에 GR Framework 컨텍스트 추가
ALTER TABLE cves ADD COLUMN vulnerable_layers JSONB;
ALTER TABLE cves ADD COLUMN vulnerable_zones JSONB;
ALTER TABLE cves ADD COLUMN vulnerable_tags JSONB;

-- CVE GR 컨텍스트 인덱스
CREATE INDEX idx_cve_layers ON cves USING GIN(vulnerable_layers);
CREATE INDEX idx_cve_zones ON cves USING GIN(vulnerable_zones);
CREATE INDEX idx_cve_tags ON cves USING GIN(vulnerable_tags);
```

**예시 데이터: Log4Shell (CVE-2021-44228)**

```sql
-- 1. MITRE Technique 등록
INSERT INTO mitre_techniques (technique_id, name, tactic, common_layers, common_zones, affected_tags, description, mitigation, detection)
VALUES
('T1190', 'Exploit Public-Facing Application', 'Initial Access',
 '["L2", "L7"]'::jsonb,
 '["Zone1", "Zone2"]'::jsonb,
 '["N2.1", "A1.5", "T1.1"]'::jsonb,
 'Adversaries may attempt to take advantage of a weakness in an Internet-facing computer or program using software, data, or commands in order to cause unintended or unanticipated behavior.',
 'Update software, use Web Application Firewall (WAF), implement proper input validation',
 'Monitor application logs for unusual patterns, detect known exploit signatures via IDS/IPS'),

('T1059.007', 'Command and Scripting Interpreter: JavaScript', 'Execution',
 '["L6", "L7"]'::jsonb,
 '["Zone2", "Zone3"]'::jsonb,
 '["T1.4", "A1.5"]'::jsonb,
 'Adversaries may abuse various implementations of JavaScript for execution.',
 'Restrict execution environments, use sandboxing, implement script signing',
 'Monitor for suspicious JavaScript execution, log runtime events'),

('T1003', 'OS Credential Dumping', 'Credential Access',
 '["L5", "L3"]'::jsonb,
 '["Zone3", "Zone4"]'::jsonb,
 '["T2.1", "S2.1"]'::jsonb,
 'Adversaries may attempt to dump credentials to obtain account login and credential material.',
 'Implement credential guard, use hardware security modules, monitor access to credential stores',
 'Detect unusual process access to credential stores, monitor LSASS access');

-- 2. CVE 등록 with GR Context
INSERT INTO cves (cve_id, description, severity, cvss_score, published_date,
                  vulnerable_layers, vulnerable_zones, vulnerable_tags)
VALUES
('CVE-2021-44228',
 'Apache Log4j2 2.0-beta9 through 2.15.0 (excluding security releases 2.12.2, 2.12.3, and 2.3.1) JNDI features used in configuration, log messages, and parameters do not protect against attacker controlled LDAP and other JNDI related endpoints.',
 'Critical',
 10.0,
 '2021-12-10',
 '["L2", "L6", "L7"]'::jsonb,
 '["Zone1", "Zone2", "Zone3"]'::jsonb,
 '["A1.5", "T1.1", "T2.4", "N2.1"]'::jsonb);

-- 3. CVE-MITRE 매핑
INSERT INTO cve_mitre_mapping (cve_id, technique_id, confidence, exploit_chain_order, notes)
SELECT
    c.id,
    m.id,
    0.95,
    1,
    'Log4Shell allows remote code execution via JNDI injection'
FROM cves c, mitre_techniques m
WHERE c.cve_id = 'CVE-2021-44228' AND m.technique_id = 'T1190';

INSERT INTO cve_mitre_mapping (cve_id, technique_id, confidence, exploit_chain_order, notes)
SELECT
    c.id,
    m.id,
    0.90,
    2,
    'Execution occurs via malicious LDAP response containing Java code'
FROM cves c, mitre_techniques m
WHERE c.cve_id = 'CVE-2021-44228' AND m.technique_id = 'T1059.007';

INSERT INTO cve_mitre_mapping (cve_id, technique_id, confidence, exploit_chain_order, notes)
SELECT
    c.id,
    m.id,
    0.85,
    3,
    'After initial compromise, attackers often pivot to credential dumping'
FROM cves c, mitre_techniques m
WHERE c.cve_id = 'CVE-2021-44228' AND m.technique_id = 'T1003';
```

**복합 쿼리 예시: CVE + MITRE + GR Framework**

```sql
-- Zone 1에서 Zone 3까지 공격 가능한 CVE 찾기
SELECT
    c.cve_id,
    c.description,
    c.cvss_score,
    c.vulnerable_zones,
    array_agg(DISTINCT m.technique_id ORDER BY m.technique_id) AS attack_techniques,
    array_agg(DISTINCT m.tactic ORDER BY m.tactic) AS tactics
FROM cves c
JOIN cve_mitre_mapping cm ON c.id = cm.cve_id
JOIN mitre_techniques m ON cm.technique_id = m.id
WHERE c.vulnerable_zones ?| array['Zone1', 'Zone2', 'Zone3']
GROUP BY c.id, c.cve_id, c.description, c.cvss_score, c.vulnerable_zones
ORDER BY c.cvss_score DESC;

-- 특정 Layer와 Zone 조합에서 발생 가능한 공격 기법 찾기
SELECT
    m.technique_id,
    m.name,
    m.tactic,
    m.common_layers,
    m.common_zones,
    count(DISTINCT c.cve_id) AS related_cve_count
FROM mitre_techniques m
LEFT JOIN cve_mitre_mapping cm ON m.id = cm.technique_id
LEFT JOIN cves c ON cm.cve_id = c.id
WHERE m.common_layers ?| array['L7']
  AND m.common_zones ?| array['Zone2']
GROUP BY m.id, m.technique_id, m.name, m.tactic, m.common_layers, m.common_zones
ORDER BY related_cve_count DESC;
```

---

## 🕸️ 3. Neo4j: Graph Database

### 역할 및 책임

**Primary Role**: Zone, Layer, Tag 간의 관계 및 공격 경로 탐색

**저장 데이터**:
- 노드: Product, Archetype, Layer, Zone, Tag
- 관계: HAS_ARCHETYPE, LOCATED_IN, TAGGED_WITH, COMMUNICATES_WITH, DEPENDS_ON

**선택 이유**:
- 그래프 쿼리 최적화 → "Zone 1에서 Zone 3까지의 경로" 같은 질문에 최적
- Cypher 언어 → 직관적인 패턴 매칭
- MITRE ATT&CK 공격 경로 시뮬레이션에 적합

---

### 노드 모델

#### 3.1 Product 노드

```cypher
CREATE CONSTRAINT product_id IF NOT EXISTS
FOR (p:Product) REQUIRE p.id IS UNIQUE;

// 노드 예시
CREATE (p:Product {
  id: '550e8400-e29b-41d4-a716-446655440000',
  name: 'Redis',
  vendor: 'Redis Ltd.',
  cpe: 'cpe:2.3:a:redis:redis:*:*:*:*:*:*:*:*'
})
```

---

#### 3.2 Archetype 노드 (핵심)

```cypher
CREATE CONSTRAINT archetype_id IF NOT EXISTS
FOR (a:Archetype) REQUIRE a.id IS UNIQUE;

// Redis의 3가지 Archetype
CREATE (a1:Archetype {
  id: 'arch-redis-cache',
  role: 'In-Memory Cache',
  layer: 'L5',
  zone: 'Zone2',
  primary_tag: 'D3.1',
  secondary_tags: ['P2.1', 'M1.3'],
  use_case: 'Application-level caching for fast data access'
})

CREATE (a2:Archetype {
  id: 'arch-redis-session',
  role: 'Session Store',
  layer: 'L5',
  zone: 'Zone3',
  primary_tag: 'D3.3',
  secondary_tags: ['S2.2'],
  use_case: 'Persistent session management with encryption'
})

CREATE (a3:Archetype {
  id: 'arch-redis-pubsub',
  role: 'Message Broker',
  layer: 'L6',
  zone: 'Zone2',
  primary_tag: 'R3.2',
  secondary_tags: ['I1.4'],
  use_case: 'Pub/Sub messaging queue for event-driven architecture'
})
```

---

#### 3.3 Layer, Zone, Tag 노드

```cypher
// Layer 노드
CREATE (l5:Layer {code: 'L5', name: 'Data Services', order: 5})
CREATE (l6:Layer {code: 'L6', name: 'Runtime Environment', order: 6})

// Zone 노드
CREATE (z2:Zone {code: 'Zone2', name: 'Application', trust_level: 30})
CREATE (z3:Zone {code: 'Zone3', name: 'Data', trust_level: 60})

// Tag 노드
CREATE (t1:Tag {code: 'D3.1', domain: 'D', name: 'In-Memory Cache'})
CREATE (t2:Tag {code: 'D3.3', domain: 'D', name: 'Session Store'})
CREATE (t3:Tag {code: 'R3.2', domain: 'R', name: 'Message Queue'})
```

---

### 관계 모델

#### 3.4 관계 정의

```cypher
// Product → Archetype
MATCH (p:Product {id: '550e8400-e29b-41d4-a716-446655440000'})
MATCH (a:Archetype {id: 'arch-redis-cache'})
CREATE (p)-[:HAS_ARCHETYPE {confidence: 0.95}]->(a)

// Archetype → Layer
MATCH (a:Archetype {id: 'arch-redis-cache'})
MATCH (l:Layer {code: 'L5'})
CREATE (a)-[:LOCATED_IN]->(l)

// Archetype → Zone
MATCH (a:Archetype {id: 'arch-redis-cache'})
MATCH (z:Zone {code: 'Zone2'})
CREATE (a)-[:BELONGS_TO]->(z)

// Archetype → Tag (Primary)
MATCH (a:Archetype {id: 'arch-redis-cache'})
MATCH (t:Tag {code: 'D3.1'})
CREATE (a)-[:TAGGED_WITH {type: 'primary'}]->(t)

// Archetype → Tag (Secondary)
MATCH (a:Archetype {id: 'arch-redis-cache'})
MATCH (t:Tag {code: 'P2.1'})
CREATE (a)-[:TAGGED_WITH {type: 'secondary'}]->(t)
```

---

#### 3.5 Attack Path 노드 및 관계 🆕

**Purpose**: MITRE ATT&CK 기반 Zone-to-Zone 공격 경로 시뮬레이션

```cypher
// Attack Path 노드 생성
CREATE CONSTRAINT attack_path_id IF NOT EXISTS
FOR (ap:AttackPath) REQUIRE ap.id IS UNIQUE;

// Log4Shell 공격 경로 예시
CREATE (ap:AttackPath {
  id: 'path-log4shell-001',
  name: 'Log4Shell Exploitation Chain',
  severity: 'Critical',

  start_zone: 'Zone1',
  end_zone: 'Zone3',

  cves: ['CVE-2021-44228'],
  mitre_techniques: ['T1190', 'T1059.007', 'T1003'],

  affected_layers: ['L2', 'L7', 'L5'],
  affected_products: ['Apache Log4j', 'Tomcat', 'PostgreSQL'],

  description: 'Initial access via public web server → Code execution via Log4j → Lateral movement to database',
  estimated_time: '30 minutes',
  detection_difficulty: 'Medium'
})

// Zone-to-Zone 공격 관계 생성
MATCH (z1:Zone {code: 'Zone1'}), (z2:Zone {code: 'Zone2'})
CREATE (z1)-[:ATTACK_PATH {
  technique: 'T1190',
  technique_name: 'Exploit Public-Facing Application',
  cve: 'CVE-2021-44228',
  difficulty: 'Low',
  time_to_exploit: '5 minutes',
  detection_difficulty: 'Medium',

  prerequisites: ['Vulnerable Log4j version', 'Internet-facing web server'],
  indicators: ['Unusual JNDI lookups', 'Outbound LDAP connections'],
  mitigation: 'Update Log4j to 2.17.0+, Block outbound LDAP'
}]->(z2)

MATCH (z2:Zone {code: 'Zone2'}), (z3:Zone {code: 'Zone3'})
CREATE (z2)-[:ATTACK_PATH {
  technique: 'T1059.007',
  technique_name: 'Command and Scripting Interpreter',
  cve: 'CVE-2021-44228',
  difficulty: 'Medium',
  time_to_exploit: '15 minutes',
  detection_difficulty: 'High',

  prerequisites: ['Initial foothold in Zone2', 'Database credentials'],
  indicators: ['Suspicious process execution', 'Unusual database queries'],
  mitigation: 'Network segmentation, Database access controls'
}]->(z3)

// MITRE Technique 노드 생성
CREATE (t1:MITRETechnique {
  id: 'T1190',
  name: 'Exploit Public-Facing Application',
  tactic: 'Initial Access',
  platforms: ['Linux', 'Windows'],

  common_layers: ['L2', 'L7'],
  common_zones: ['Zone0-A', 'Zone1'],

  detection_methods: ['Network IDS', 'Application logs', 'WAF alerts'],
  mitigation_methods: ['Patch management', 'Input validation', 'WAF deployment']
})

CREATE (t2:MITRETechnique {
  id: 'T1059.007',
  name: 'Command and Scripting Interpreter: JavaScript',
  tactic: 'Execution',
  platforms: ['Linux', 'Windows'],

  common_layers: ['L6', 'L7'],
  common_zones: ['Zone2', 'Zone3'],

  detection_methods: ['Runtime monitoring', 'Script execution logs'],
  mitigation_methods: ['Application whitelisting', 'Script signing']
})

// Attack Path → MITRE Technique 관계
MATCH (ap:AttackPath {id: 'path-log4shell-001'})
MATCH (t:MITRETechnique {id: 'T1190'})
CREATE (ap)-[:USES_TECHNIQUE {order: 1, critical: true}]->(t)

MATCH (ap:AttackPath {id: 'path-log4shell-001'})
MATCH (t:MITRETechnique {id: 'T1059.007'})
CREATE (ap)-[:USES_TECHNIQUE {order: 2, critical: true}]->(t)

// CVE 노드와 Attack Path 연결
CREATE (cve:CVE {
  id: 'CVE-2021-44228',
  description: 'Apache Log4j2 JNDI injection vulnerability',
  cvss_score: 10.0,
  severity: 'Critical',
  published_date: '2021-12-10',

  vulnerable_layers: ['L2', 'L6', 'L7'],
  vulnerable_zones: ['Zone1', 'Zone2', 'Zone3']
})

MATCH (ap:AttackPath {id: 'path-log4shell-001'})
MATCH (cve:CVE {id: 'CVE-2021-44228'})
CREATE (ap)-[:EXPLOITS_CVE]->(cve)
```

**Attack Path 쿼리 패턴**

```cypher
// 1. 특정 Zone에서 시작하는 모든 공격 경로 찾기
MATCH path = (start:Zone {code: 'Zone1'})-[:ATTACK_PATH*1..5]->(end:Zone)
RETURN start.code AS from_zone,
       end.code AS to_zone,
       [rel IN relationships(path) | rel.technique_name] AS attack_chain,
       [rel IN relationships(path) | rel.difficulty] AS difficulty_levels,
       LENGTH(path) AS hop_count
ORDER BY hop_count;

// 2. 특정 CVE를 악용하는 공격 경로 찾기
MATCH (ap:AttackPath)-[:EXPLOITS_CVE]->(cve:CVE {id: 'CVE-2021-44228'})
MATCH (ap)-[:USES_TECHNIQUE]->(t:MITRETechnique)
RETURN ap.name,
       ap.start_zone,
       ap.end_zone,
       collect(t.name) AS techniques,
       ap.severity,
       ap.estimated_time;

// 3. Zone X에서 Zone Y까지의 최단 공격 경로 찾기
MATCH path = shortestPath(
  (z1:Zone {code: 'Zone1'})-[:ATTACK_PATH*1..10]->(z2:Zone {code: 'Zone4'})
)
RETURN path,
       LENGTH(path) AS hop_count,
       [rel IN relationships(path) | rel.technique] AS mitre_techniques,
       [rel IN relationships(path) | rel.cve] AS exploited_cves;

// 4. 특정 Layer에 영향을 주는 공격 기법 찾기
MATCH (t:MITRETechnique)
WHERE 'L7' IN t.common_layers
MATCH (ap:AttackPath)-[:USES_TECHNIQUE]->(t)
RETURN t.id,
       t.name,
       t.tactic,
       count(ap) AS attack_path_count,
       collect(DISTINCT ap.name) AS related_attacks
ORDER BY attack_path_count DESC;

// 5. CVE + MITRE + Attack Path 통합 분석
MATCH (cve:CVE)-[:MAPPED_TO]->(t:MITRETechnique)
MATCH (ap:AttackPath)-[:USES_TECHNIQUE]->(t)
MATCH (ap)-[:EXPLOITS_CVE]->(cve)
WHERE cve.cvss_score >= 9.0
RETURN cve.id,
       cve.cvss_score,
       t.name AS mitre_technique,
       ap.name AS attack_scenario,
       ap.start_zone,
       ap.end_zone,
       ap.estimated_time
ORDER BY cve.cvss_score DESC;
```

---

### 주요 쿼리 패턴

#### 쿼리 1: Zone 간 공격 경로 탐색

```cypher
// Zone 1에서 Zone 3까지 도달 가능한 모든 경로 찾기
MATCH path = (z1:Zone {code: 'Zone1'})<-[:BELONGS_TO]-(a1:Archetype)
             -[:COMMUNICATES_WITH*1..5]-
             (a2:Archetype)-[:BELONGS_TO]->(z3:Zone {code: 'Zone3'})
RETURN path, LENGTH(path) AS hop_count
ORDER BY hop_count
LIMIT 10
```

#### 쿼리 2: 특정 제품의 모든 가능한 역할 조회

```cypher
MATCH (p:Product {name: 'Nginx'})-[:HAS_ARCHETYPE]->(a:Archetype)
MATCH (a)-[:LOCATED_IN]->(l:Layer)
MATCH (a)-[:BELONGS_TO]->(z:Zone)
MATCH (a)-[:TAGGED_WITH {type: 'primary'}]->(t:Tag)
RETURN p.name, a.role, l.code, z.code, t.code
```

#### 쿼리 3: Layer 7에 있는 모든 Java 기반 제품

```cypher
MATCH (p:Product {primary_language: 'Java'})-[:HAS_ARCHETYPE]->(a:Archetype)
      -[:LOCATED_IN]->(l:Layer {code: 'L7'})
RETURN p.name, a.role, p.cpe
```

#### 쿼리 4: CVE 영향 받는 모든 Archetype 찾기

```cypher
// Log4j 취약점 예시
MATCH (p:Product)-[:HAS_CVE]->(c:CVE {cve_id: 'CVE-2021-44228'})
MATCH (p)-[:HAS_ARCHETYPE]->(a:Archetype)
MATCH (a)-[:BELONGS_TO]->(z:Zone)
RETURN p.name, a.role, z.code, c.severity
```

---

## 🔍 4. Pinecone: Vector Database

### 역할 및 책임

**Primary Role**: AI/RAG를 위한 시맨틱 검색 및 유사도 계산

**저장 데이터**:
- 제품 설명 임베딩 (OpenAI ada-002, 1536차원)
- Archetype 설명 임베딩
- 메타데이터 (product_id, archetype_id, layer, zone, tags)

**선택 이유**:
- 관리형 서비스 → 운영 부담 최소화
- 밀리초 단위 검색 → 실시간 RAG 가능
- 메타데이터 필터링 → "Zone 2에 배치 가능한 캐시 찾기" 같은 복합 쿼리 지원

---

### 인덱스 설계

#### 4.1 product_vectors 인덱스

```python
import pinecone
from openai import OpenAI

# Pinecone 초기화
pinecone.init(api_key="YOUR_API_KEY", environment="us-west1-gcp")

# 인덱스 생성
index_name = "gr-products"
pinecone.create_index(
    name=index_name,
    dimension=1536,              # OpenAI ada-002 embedding size
    metric="cosine",             # 코사인 유사도
    metadata_config={
        "indexed": ["vendor", "layer", "zone", "primary_tag", "language"]
    }
)

index = pinecone.Index(index_name)
```

#### 4.2 벡터 업서트 (Upsert)

```python
from openai import OpenAI
client = OpenAI(api_key="YOUR_OPENAI_KEY")

# 1. 제품 설명을 임베딩
product_description = """
Redis is an in-memory data structure store, used as a database,
cache, and message broker. It supports data structures such as
strings, hashes, lists, sets, sorted sets with range queries,
bitmaps, hyperloglogs, geospatial indexes, and streams.
"""

response = client.embeddings.create(
    model="text-embedding-ada-002",
    input=product_description
)
embedding = response.data[0].embedding  # 1536차원 벡터

# 2. Pinecone에 업서트
index.upsert(vectors=[
    {
        "id": "product-550e8400-e29b-41d4-a716-446655440000",
        "values": embedding,
        "metadata": {
            "product_id": "550e8400-e29b-41d4-a716-446655440000",
            "name": "Redis",
            "vendor": "Redis Ltd.",
            "type": "product"
        }
    }
])
```

#### 4.3 Archetype 벡터 업서트

```python
# Redis Cache Archetype 임베딩
archetype_description = """
Redis used as an in-memory cache for application-level performance optimization.
Typically deployed in Layer 5 (Data Services), Zone 2 (Application Zone).
Supports high-speed read/write operations with sub-millisecond latency.
"""

response = client.embeddings.create(
    model="text-embedding-ada-002",
    input=archetype_description
)
arch_embedding = response.data[0].embedding

index.upsert(vectors=[
    {
        "id": "archetype-arch-redis-cache",
        "values": arch_embedding,
        "metadata": {
            "archetype_id": "arch-redis-cache",
            "product_id": "550e8400-e29b-41d4-a716-446655440000",
            "product_name": "Redis",
            "role": "In-Memory Cache",
            "layer": "L5",
            "zone": "Zone2",
            "primary_tag": "D3.1",
            "type": "archetype"
        }
    }
])
```

---

### 쿼리 예시

#### 쿼리 1: 유사 제품 찾기

```python
# 사용자 질문: "Nginx와 비슷한 제품 찾아줘"
query_text = "Web server and reverse proxy with load balancing capabilities"

# 임베딩
query_embedding = client.embeddings.create(
    model="text-embedding-ada-002",
    input=query_text
).data[0].embedding

# 검색
results = index.query(
    vector=query_embedding,
    top_k=10,
    include_metadata=True,
    filter={"type": {"$eq": "product"}}  # 제품만 검색
)

for match in results.matches:
    print(f"{match.metadata['name']}: {match.score:.4f}")
```

**출력 예시**:
```
Nginx: 0.9234
Apache HTTP Server: 0.9102
HAProxy: 0.8876
Traefik: 0.8654
Envoy: 0.8543
```

#### 쿼리 2: Zone + Tag 필터링 검색

```python
# 사용자 질문: "Zone 2에 배치 가능한 캐시 솔루션 추천해줘"
query_text = "Fast caching solution for application layer"

query_embedding = client.embeddings.create(
    model="text-embedding-ada-002",
    input=query_text
).data[0].embedding

results = index.query(
    vector=query_embedding,
    top_k=5,
    include_metadata=True,
    filter={
        "type": {"$eq": "archetype"},
        "zone": {"$eq": "Zone2"},
        "primary_tag": {"$in": ["D3.1", "D3.2", "D3.3"]}  # Cache 관련 태그
    }
)

for match in results.matches:
    print(f"{match.metadata['product_name']} ({match.metadata['role']}): {match.score:.4f}")
```

**출력 예시**:
```
Redis (In-Memory Cache): 0.9456
Memcached (Distributed Cache): 0.9123
Hazelcast (In-Memory Data Grid): 0.8901
```

---

## 🔄 5. 데이터 동기화 전략 (Data Synchronization)

> ⚠️ **실무 리스크 대응**: 실시간 CDC(Debezium)는 구현 복잡도가 높고 트랜잭션 불일치 시 데이터 정합성 문제가 발생합니다. 초기 단계에서는 **Outbox Pattern + Batch Sync**로 시작하고, 규모가 커지면 CDC로 전환하는 것을 권장합니다.

### 🆕 동기화 전략 단계별 적용

| 단계 | 전략 | 복잡도 | 지연 시간 | 적용 시점 |
|------|------|--------|----------|----------|
| **v0** | PostgreSQL Only | 낮음 | N/A | Phase 1-2 초반 |
| **v1 초기** | Outbox Pattern + Batch Sync | 중간 | 1-5분 | v1 전환 시 |
| **v1 성숙** | CDC (Debezium) | 높음 | 1-5초 | 실시간 필요 시 |

### 🆕 Outbox Pattern 아키텍처 (권장: v1 초기)

```
PostgreSQL (Source of Truth)
         │
         ├─ BEGIN TRANSACTION
         │    ├─ INSERT/UPDATE products
         │    └─ INSERT sync_outbox (동일 트랜잭션)
         │── COMMIT
         │
         ▼
┌────────────────────────┐
│  Outbox Processor      │
│  (5분 주기 배치)        │
│  - 트랜잭션 보장        │
│  - 재시도 로직 포함      │
└────────┬───────────────┘
         │
         ├──────────────┬──────────────┐
         ▼              ▼              ▼
    ┌─────────┐   ┌─────────┐   ┌─────────┐
    │  Sync   │   │  Sync   │   │  Sync   │
    │  Worker │   │  Worker │   │  Worker │
    │  (Neo4j)│   │(Pinecone│   │  (Cache)│
    └─────────┘   └─────────┘   └─────────┘
```

### 🆕 sync_outbox 테이블 (Outbox Pattern)

```sql
CREATE TABLE sync_outbox (
    -- 기본 식별자
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- 동기화 대상 정보
    entity_type VARCHAR(50) NOT NULL,            -- 'product', 'archetype', 'cve', 'product_alias'
    entity_id UUID NOT NULL,                     -- 대상 엔티티 ID
    operation VARCHAR(20) NOT NULL,              -- 'INSERT', 'UPDATE', 'DELETE'

    -- 동기화 대상 DB
    target_db VARCHAR(20) NOT NULL,              -- 'neo4j', 'pinecone', 'all'

    -- 페이로드 (동기화에 필요한 데이터)
    payload JSONB NOT NULL,                      -- {"name": "Redis", "description": "...", ...}

    -- 상태 관리
    status VARCHAR(20) DEFAULT 'pending',        -- 'pending', 'processing', 'completed', 'failed'
    retry_count INT DEFAULT 0,                   -- 재시도 횟수
    max_retries INT DEFAULT 3,                   -- 최대 재시도 횟수
    last_error TEXT,                             -- 마지막 에러 메시지

    -- 처리 시간
    created_at TIMESTAMP DEFAULT NOW(),
    processed_at TIMESTAMP,                      -- 처리 완료 시간
    next_retry_at TIMESTAMP,                     -- 다음 재시도 예정 시간

    -- 제약 조건
    CONSTRAINT valid_status CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
    CONSTRAINT valid_operation CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
    CONSTRAINT valid_target CHECK (target_db IN ('neo4j', 'pinecone', 'all'))
);

-- 인덱스
CREATE INDEX idx_sync_outbox_status ON sync_outbox(status) WHERE status IN ('pending', 'failed');
CREATE INDEX idx_sync_outbox_entity ON sync_outbox(entity_type, entity_id);
CREATE INDEX idx_sync_outbox_created ON sync_outbox(created_at);
CREATE INDEX idx_sync_outbox_next_retry ON sync_outbox(next_retry_at) WHERE status = 'failed';

-- 오래된 완료 레코드 자동 삭제 (30일 이상)
CREATE INDEX idx_sync_outbox_cleanup ON sync_outbox(processed_at)
WHERE status = 'completed';
```

### 🆕 Outbox 트리거 함수

```sql
-- products 테이블에 Outbox 트리거 추가
CREATE OR REPLACE FUNCTION fn_products_outbox_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO sync_outbox (entity_type, entity_id, operation, target_db, payload)
        VALUES (
            'product',
            NEW.id,
            'INSERT',
            'all',
            jsonb_build_object(
                'id', NEW.id,
                'name', NEW.name,
                'name_en', NEW.name_en,
                'description_en', NEW.description_en,
                'vendor_id', NEW.vendor_id,
                'primary_language', NEW.primary_language
            )
        );
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO sync_outbox (entity_type, entity_id, operation, target_db, payload)
        VALUES (
            'product',
            NEW.id,
            'UPDATE',
            'all',
            jsonb_build_object(
                'id', NEW.id,
                'name', NEW.name,
                'name_en', NEW.name_en,
                'description_en', NEW.description_en,
                'vendor_id', NEW.vendor_id,
                'primary_language', NEW.primary_language,
                'changed_fields', (
                    SELECT jsonb_object_agg(key, value)
                    FROM jsonb_each(to_jsonb(NEW))
                    WHERE to_jsonb(NEW) -> key != to_jsonb(OLD) -> key
                )
            )
        );
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO sync_outbox (entity_type, entity_id, operation, target_db, payload)
        VALUES (
            'product',
            OLD.id,
            'DELETE',
            'all',
            jsonb_build_object('id', OLD.id, 'name', OLD.name)
        );
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 트리거 생성
CREATE TRIGGER trg_products_outbox
AFTER INSERT OR UPDATE OR DELETE ON products
FOR EACH ROW EXECUTE FUNCTION fn_products_outbox_trigger();

-- archetypes 테이블에도 동일한 트리거 추가
CREATE OR REPLACE FUNCTION fn_archetypes_outbox_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO sync_outbox (entity_type, entity_id, operation, target_db, payload)
        VALUES (
            'archetype',
            NEW.id,
            'INSERT',
            'all',
            jsonb_build_object(
                'id', NEW.id,
                'product_id', NEW.product_id,
                'role', NEW.role,
                'layer', NEW.layer,
                'zone', NEW.zone,
                'primary_tag', NEW.primary_tag,
                'secondary_tags', NEW.secondary_tags
            )
        );
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO sync_outbox (entity_type, entity_id, operation, target_db, payload)
        VALUES ('archetype', NEW.id, 'UPDATE', 'all', to_jsonb(NEW));
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO sync_outbox (entity_type, entity_id, operation, target_db, payload)
        VALUES ('archetype', OLD.id, 'DELETE', 'all', jsonb_build_object('id', OLD.id));
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_archetypes_outbox
AFTER INSERT OR UPDATE OR DELETE ON archetypes
FOR EACH ROW EXECUTE FUNCTION fn_archetypes_outbox_trigger();
```

### 🆕 Outbox Processor (Python)

```python
import psycopg2
from neo4j import GraphDatabase
import pinecone
from openai import OpenAI
from datetime import datetime, timedelta
import logging

logger = logging.getLogger(__name__)

class OutboxProcessor:
    """
    Outbox Pattern 기반 동기화 프로세서
    - 5분 주기로 실행 (cron 또는 Celery Beat)
    - 트랜잭션 보장
    - 자동 재시도 (최대 3회, exponential backoff)
    """

    def __init__(self):
        self.pg_conn = psycopg2.connect("postgresql://...")
        self.neo4j_driver = GraphDatabase.driver("bolt://...", auth=("user", "pass"))
        pinecone.init(api_key="...", environment="...")
        self.pinecone_index = pinecone.Index("gr-products")
        self.openai_client = OpenAI(api_key="...")

    def process_pending_events(self, batch_size: int = 100):
        """pending 상태의 이벤트 처리"""
        with self.pg_conn.cursor() as cur:
            # 1. pending 이벤트 조회 (FOR UPDATE SKIP LOCKED로 동시성 제어)
            cur.execute("""
                SELECT id, entity_type, entity_id, operation, target_db, payload
                FROM sync_outbox
                WHERE status = 'pending'
                   OR (status = 'failed' AND retry_count < max_retries AND next_retry_at <= NOW())
                ORDER BY created_at
                LIMIT %s
                FOR UPDATE SKIP LOCKED
            """, (batch_size,))

            events = cur.fetchall()

            for event in events:
                event_id, entity_type, entity_id, operation, target_db, payload = event
                try:
                    # 2. 상태를 processing으로 변경
                    cur.execute("""
                        UPDATE sync_outbox SET status = 'processing' WHERE id = %s
                    """, (event_id,))
                    self.pg_conn.commit()

                    # 3. 동기화 수행
                    self._sync_event(entity_type, operation, target_db, payload)

                    # 4. 성공 시 completed로 변경
                    cur.execute("""
                        UPDATE sync_outbox
                        SET status = 'completed', processed_at = NOW()
                        WHERE id = %s
                    """, (event_id,))
                    self.pg_conn.commit()

                    logger.info(f"Synced: {entity_type}/{entity_id} - {operation}")

                except Exception as e:
                    # 5. 실패 시 재시도 예약
                    self.pg_conn.rollback()
                    retry_count = self._get_retry_count(cur, event_id)
                    next_retry = datetime.now() + timedelta(minutes=2 ** retry_count)  # exponential backoff

                    cur.execute("""
                        UPDATE sync_outbox
                        SET status = 'failed',
                            retry_count = retry_count + 1,
                            last_error = %s,
                            next_retry_at = %s
                        WHERE id = %s
                    """, (str(e), next_retry, event_id))
                    self.pg_conn.commit()

                    logger.error(f"Sync failed: {entity_type}/{entity_id} - {e}")

    def _sync_event(self, entity_type: str, operation: str, target_db: str, payload: dict):
        """실제 동기화 수행"""
        if target_db in ('neo4j', 'all'):
            self._sync_to_neo4j(entity_type, operation, payload)

        if target_db in ('pinecone', 'all'):
            self._sync_to_pinecone(entity_type, operation, payload)

    def _sync_to_neo4j(self, entity_type: str, operation: str, payload: dict):
        """Neo4j 동기화"""
        with self.neo4j_driver.session() as session:
            if entity_type == 'product':
                if operation == 'INSERT':
                    session.run("""
                        CREATE (p:Product {id: $id, name: $name, language: $language})
                    """, id=str(payload['id']), name=payload['name'],
                         language=payload.get('primary_language'))
                elif operation == 'UPDATE':
                    session.run("""
                        MATCH (p:Product {id: $id})
                        SET p.name = $name, p.language = $language
                    """, id=str(payload['id']), name=payload['name'],
                         language=payload.get('primary_language'))
                elif operation == 'DELETE':
                    session.run("""
                        MATCH (p:Product {id: $id}) DETACH DELETE p
                    """, id=str(payload['id']))

    def _sync_to_pinecone(self, entity_type: str, operation: str, payload: dict):
        """Pinecone 동기화"""
        if entity_type == 'product':
            vector_id = f"product-{payload['id']}"

            if operation in ('INSERT', 'UPDATE'):
                desc = payload.get('description_en', payload.get('name', ''))
                embedding = self.openai_client.embeddings.create(
                    model="text-embedding-ada-002",
                    input=desc
                ).data[0].embedding

                self.pinecone_index.upsert(vectors=[{
                    "id": vector_id,
                    "values": embedding,
                    "metadata": {
                        "product_id": str(payload['id']),
                        "name": payload['name'],
                        "type": "product"
                    }
                }])

            elif operation == 'DELETE':
                self.pinecone_index.delete(ids=[vector_id])

    def _get_retry_count(self, cur, event_id) -> int:
        cur.execute("SELECT retry_count FROM sync_outbox WHERE id = %s", (event_id,))
        return cur.fetchone()[0]

    def cleanup_old_events(self, days: int = 30):
        """오래된 완료 이벤트 정리"""
        with self.pg_conn.cursor() as cur:
            cur.execute("""
                DELETE FROM sync_outbox
                WHERE status = 'completed'
                  AND processed_at < NOW() - INTERVAL '%s days'
            """, (days,))
            deleted = cur.rowcount
            self.pg_conn.commit()
            logger.info(f"Cleaned up {deleted} old events")

    def close(self):
        self.pg_conn.close()
        self.neo4j_driver.close()


# 사용 예시 (5분 주기 cron job)
if __name__ == "__main__":
    processor = OutboxProcessor()
    try:
        processor.process_pending_events(batch_size=100)
        processor.cleanup_old_events(days=30)
    finally:
        processor.close()
```

---

### CDC 아키텍처 (v1 성숙기 이후)

> 💡 **전환 시점**: Outbox Pattern의 5분 지연이 비즈니스 요구사항을 충족하지 못할 때 CDC로 전환합니다.

```
PostgreSQL (Source of Truth)
         │
         ├─ INSERT/UPDATE/DELETE
         │
         ▼
┌────────────────────────┐
│  CDC Listener          │
│  (Debezium / pg_notify)│
└────────┬───────────────┘
         │
         ├──────────────┬──────────────┐
         ▼              ▼              ▼
    ┌─────────┐   ┌─────────┐   ┌─────────┐
    │  Sync   │   │  Sync   │   │  Sync   │
    │  Worker │   │  Worker │   │  Worker │
    │  (Neo4j)│   │(Pinecone│   │  (Cache)│
    └─────────┘   └─────────┘   └─────────┘
```

### 동기화 규칙

| PostgreSQL 이벤트 | Neo4j 동작 | Pinecone 동작 |
|-------------------|------------|---------------|
| **products INSERT** | Product 노드 생성 | 설명 임베딩 후 벡터 업서트 |
| **products UPDATE** | 속성 업데이트 | 벡터 재생성 및 업데이트 |
| **products DELETE** | Product 노드 삭제 (CASCADE) | 벡터 삭제 |
| **archetype 추가** | Archetype 노드 + 관계 생성 | Archetype 벡터 업서트 |

### Python 동기화 코드 예시

```python
import psycopg2
from neo4j import GraphDatabase
import pinecone
from openai import OpenAI

class GRDataSync:
    def __init__(self):
        self.pg_conn = psycopg2.connect("postgresql://...")
        self.neo4j_driver = GraphDatabase.driver("bolt://...", auth=("user", "pass"))
        pinecone.init(api_key="...", environment="...")
        self.pinecone_index = pinecone.Index("gr-products")
        self.openai_client = OpenAI(api_key="...")

    def sync_product_insert(self, product_id):
        # 1. PostgreSQL에서 데이터 읽기
        with self.pg_conn.cursor() as cur:
            cur.execute("""
                SELECT id, name, vendor_id, description_en, primary_language
                FROM products WHERE id = %s
            """, (product_id,))
            row = cur.fetchone()

        if not row:
            return

        pid, name, vendor_id, desc, lang = row

        # 2. Neo4j에 Product 노드 생성
        with self.neo4j_driver.session() as session:
            session.run("""
                CREATE (p:Product {id: $id, name: $name, language: $lang})
            """, id=str(pid), name=name, lang=lang)

        # 3. Pinecone에 벡터 업서트
        embedding = self.openai_client.embeddings.create(
            model="text-embedding-ada-002",
            input=desc
        ).data[0].embedding

        self.pinecone_index.upsert(vectors=[{
            "id": f"product-{pid}",
            "values": embedding,
            "metadata": {"product_id": str(pid), "name": name, "type": "product"}
        }])

    def close(self):
        self.pg_conn.close()
        self.neo4j_driver.close()
```

---

## 🚀 6. API 설계 (FastAPI)

### API 엔드포인트 구조

```
/api/v1/
├── /products
│   ├── GET    /                    # 제품 목록
│   ├── GET    /{product_id}         # 제품 상세
│   ├── POST   /                     # 제품 생성 (관리자)
│   └── GET    /{product_id}/archetypes  # 제품의 모든 Archetype
│
├── /archetypes
│   ├── GET    /                     # Archetype 목록
│   └── GET    /{archetype_id}       # Archetype 상세
│
├── /search
│   ├── POST   /similarity           # 벡터 유사도 검색
│   ├── POST   /graph-path           # 그래프 경로 탐색
│   └── POST   /combined             # 통합 검색 (PostgreSQL + Neo4j + Pinecone)
│
├── /cves
│   ├── GET    /                     # CVE 목록
│   ├── GET    /{cve_id}             # CVE 상세
│   └── GET    /product/{product_id} # 특정 제품의 CVE
│
└── /analytics
    ├── GET    /zone-distribution    # Zone별 제품 분포
    └── GET    /attack-surface       # 공격 표면 분석
```

### 주요 엔드포인트 구현 예시

#### 6.1 통합 검색 API

```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional

app = FastAPI(title="GR DB API", version="2.0")

class CombinedSearchRequest(BaseModel):
    query: str
    filters: Optional[dict] = {}
    top_k: int = 10

@app.post("/api/v1/search/combined")
async def combined_search(request: CombinedSearchRequest):
    """
    PostgreSQL + Neo4j + Pinecone을 통합한 검색
    """
    # 1. Pinecone: 유사도 검색으로 후보군 추출
    query_embedding = openai_client.embeddings.create(
        model="text-embedding-ada-002",
        input=request.query
    ).data[0].embedding

    vector_results = pinecone_index.query(
        vector=query_embedding,
        top_k=request.top_k * 2,  # 넉넉하게
        filter=request.filters,
        include_metadata=True
    )

    product_ids = [m.metadata['product_id'] for m in vector_results.matches]

    # 2. Neo4j: Archetype 관계 조회
    with neo4j_driver.session() as session:
        result = session.run("""
            MATCH (p:Product)-[:HAS_ARCHETYPE]->(a:Archetype)
            WHERE p.id IN $ids
            MATCH (a)-[:LOCATED_IN]->(l:Layer)
            MATCH (a)-[:BELONGS_TO]->(z:Zone)
            RETURN p.id, p.name, a.role, l.code, z.code
        """, ids=product_ids)

        graph_data = [record.data() for record in result]

    # 3. PostgreSQL: 상세 정보 보강
    with pg_conn.cursor() as cur:
        cur.execute("""
            SELECT id, name, vendor_id, description, eol_date
            FROM products WHERE id = ANY(%s)
        """, (product_ids,))

        product_details = cur.fetchall()

    # 4. 결과 통합 및 반환
    combined_results = []
    for detail in product_details:
        pid, name, vendor, desc, eol = detail

        # 해당 제품의 Archetype 정보 찾기
        archetypes = [g for g in graph_data if g['p.id'] == pid]

        # 벡터 검색 점수 찾기
        score = next((m.score for m in vector_results.matches
                     if m.metadata['product_id'] == pid), 0.0)

        combined_results.append({
            "product_id": pid,
            "name": name,
            "description": desc,
            "similarity_score": score,
            "archetypes": archetypes,
            "eol_date": eol
        })

    return {
        "query": request.query,
        "results": sorted(combined_results,
                         key=lambda x: x['similarity_score'],
                         reverse=True)[:request.top_k]
    }
```

---

#### 6.2 Web Search Data Collection Pipeline 🆕

**Purpose**: DB 기반 추론과 Web 기반 추론의 교차 검증

```python
from fastapi import FastAPI, BackgroundTasks
from pydantic import BaseModel
from typing import List, Optional
import asyncio
import httpx
from bs4 import BeautifulSoup

app = FastAPI()

class WebSearchRequest(BaseModel):
    product_name: str
    vendor_name: Optional[str] = None
    search_depth: str = "basic"  # basic, detailed, comprehensive

class InferenceResult(BaseModel):
    source: str  # "db" or "web"
    confidence: float
    layer: str
    zone: str
    tags: List[str]
    evidence: List[str]

@app.post("/api/v1/inference/cross-validate")
async def cross_validate_inference(request: WebSearchRequest):
    """
    DB 기반 추론과 Web 기반 추론을 교차 검증
    """
    # Path 1: DB 기반 추론 (PostgreSQL + Neo4j + Pinecone)
    db_inference = await infer_from_database(request.product_name)

    # Path 2: Web 기반 추론 (병렬 실행)
    web_inference = await infer_from_web(request.product_name, request.vendor_name)

    # Cross-Validation
    agreement_score = calculate_agreement(db_inference, web_inference)

    if agreement_score > 0.85:
        # 높은 일치도 → 자동 승인
        result = merge_results(db_inference, web_inference)
        return {
            "status": "auto_approved",
            "agreement_score": agreement_score,
            "result": result
        }
    elif agreement_score > 0.70:
        # 중간 일치도 → LLM으로 충돌 해소
        resolved = await resolve_conflicts_with_llm(db_inference, web_inference)
        return {
            "status": "llm_resolved",
            "agreement_score": agreement_score,
            "result": resolved
        }
    else:
        # 낮은 일치도 → 전문가 검증 필요
        return {
            "status": "expert_validation_required",
            "agreement_score": agreement_score,
            "db_inference": db_inference,
            "web_inference": web_inference
        }

async def infer_from_database(product_name: str) -> InferenceResult:
    """
    Pinecone → Neo4j → PostgreSQL 3-Stage 추론
    """
    # Stage 1: Pinecone 벡터 검색
    query_embedding = openai_client.embeddings.create(
        model="text-embedding-ada-002",
        input=product_name
    ).data[0].embedding

    similar_products = pinecone_index.query(
        vector=query_embedding,
        top_k=5,
        include_metadata=True
    )

    # Stage 2: Neo4j 그래프 패턴 매칭
    with neo4j_driver.session() as session:
        result = session.run("""
            MATCH (p:Product {name: $name})-[:HAS_ARCHETYPE]->(a:Archetype)
            MATCH (a)-[:LOCATED_IN]->(l:Layer)
            MATCH (a)-[:BELONGS_TO]->(z:Zone)
            MATCH (a)-[:TAGGED_WITH]->(t:Tag)
            RETURN l.code, z.code, collect(t.code) AS tags
        """, name=product_name)

        graph_data = result.single()

    # Stage 3: PostgreSQL 메타데이터 조회
    with pg_conn.cursor() as cur:
        cur.execute("""
            SELECT a.layer, a.zone, a.primary_tag, a.secondary_tags
            FROM archetypes a
            JOIN products p ON a.product_id = p.id
            WHERE p.name = %s
        """, (product_name,))
        db_data = cur.fetchone()

    return InferenceResult(
        source="db",
        confidence=0.90,
        layer=graph_data['l.code'] if graph_data else db_data[0],
        zone=graph_data['z.code'] if graph_data else db_data[1],
        tags=graph_data['tags'] if graph_data else [db_data[2]] + db_data[3],
        evidence=["Pinecone similarity", "Neo4j pattern match", "PostgreSQL metadata"]
    )

async def infer_from_web(product_name: str, vendor_name: Optional[str]) -> InferenceResult:
    """
    Web 소스에서 제품 정보 수집 및 추론
    """
    async with httpx.AsyncClient(timeout=30.0) as client:
        # 병렬로 여러 소스 검색
        tasks = [
            fetch_official_docs(client, product_name, vendor_name),
            fetch_github_readme(client, product_name),
            fetch_stackoverflow(client, product_name),
            fetch_reddit_discussions(client, product_name)
        ]

        results = await asyncio.gather(*tasks, return_exceptions=True)

    # LLM으로 웹 데이터 분석 및 추론
    combined_text = "\n\n".join([r for r in results if isinstance(r, str)])

    llm_analysis = openai_client.chat.completions.create(
        model="gpt-4",
        messages=[
            {"role": "system", "content": "You are a GR Framework expert. Analyze product information and infer Layer, Zone, and Tags."},
            {"role": "user", "content": f"Product: {product_name}\n\nWeb sources:\n{combined_text}\n\nInfer: Layer, Zone, Tags"}
        ]
    )

    # LLM 응답 파싱
    llm_result = parse_llm_response(llm_analysis.choices[0].message.content)

    return InferenceResult(
        source="web",
        confidence=0.75,
        layer=llm_result['layer'],
        zone=llm_result['zone'],
        tags=llm_result['tags'],
        evidence=["Official docs", "GitHub README", "Stack Overflow", "Reddit"]
    )

async def fetch_official_docs(client: httpx.AsyncClient, product: str, vendor: Optional[str]) -> str:
    """공식 문서 크롤링"""
    if vendor:
        search_url = f"https://www.google.com/search?q={vendor}+{product}+official+documentation"
    else:
        search_url = f"https://www.google.com/search?q={product}+official+documentation"

    response = await client.get(search_url)
    soup = BeautifulSoup(response.text, 'html.parser')

    # 첫 번째 검색 결과에서 텍스트 추출
    first_result = soup.find('div', class_='g')
    if first_result:
        return first_result.get_text()[:1000]  # 처음 1000자만
    return ""

async def fetch_github_readme(client: httpx.AsyncClient, product: str) -> str:
    """GitHub README 검색"""
    github_api_url = f"https://api.github.com/search/repositories?q={product}"
    response = await client.get(github_api_url)

    if response.status_code == 200:
        repos = response.json().get('items', [])
        if repos:
            # 가장 스타가 많은 레포지토리의 README 가져오기
            top_repo = max(repos, key=lambda r: r['stargazers_count'])
            readme_url = f"https://api.github.com/repos/{top_repo['full_name']}/readme"
            readme_response = await client.get(readme_url, headers={"Accept": "application/vnd.github.v3.raw"})
            return readme_response.text[:1000]
    return ""

async def fetch_stackoverflow(client: httpx.AsyncClient, product: str) -> str:
    """Stack Overflow 검색"""
    so_api_url = f"https://api.stackexchange.com/2.3/search?order=desc&sort=relevance&intitle={product}&site=stackoverflow"
    response = await client.get(so_api_url)

    if response.status_code == 200:
        questions = response.json().get('items', [])
        if questions:
            top_question = questions[0]
            return top_question.get('title', '') + " " + top_question.get('body', '')[:500]
    return ""

async def fetch_reddit_discussions(client: httpx.AsyncClient, product: str) -> str:
    """Reddit 토론 검색"""
    reddit_search_url = f"https://www.reddit.com/search.json?q={product}"
    response = await client.get(reddit_search_url, headers={"User-Agent": "GR-Framework/2.1"})

    if response.status_code == 200:
        posts = response.json().get('data', {}).get('children', [])
        if posts:
            top_post = posts[0]['data']
            return top_post.get('title', '') + " " + top_post.get('selftext', '')[:500]
    return ""

def calculate_agreement(db: InferenceResult, web: InferenceResult) -> float:
    """
    DB 추론과 Web 추론의 일치도 계산
    """
    layer_match = 1.0 if db.layer == web.layer else 0.0
    zone_match = 1.0 if db.zone == web.zone else 0.0

    # Tag 일치도 (Jaccard similarity)
    db_tags_set = set(db.tags)
    web_tags_set = set(web.tags)
    tag_match = len(db_tags_set & web_tags_set) / len(db_tags_set | web_tags_set) if (db_tags_set | web_tags_set) else 0.0

    # 가중 평균 (Layer 40%, Zone 40%, Tags 20%)
    agreement = (layer_match * 0.4) + (zone_match * 0.4) + (tag_match * 0.2)
    return agreement

def merge_results(db: InferenceResult, web: InferenceResult) -> dict:
    """높은 일치도 시 결과 병합"""
    return {
        "layer": db.layer,  # DB 우선
        "zone": db.zone,
        "tags": list(set(db.tags + web.tags)),  # 합집합
        "confidence": (db.confidence + web.confidence) / 2,
        "evidence": db.evidence + web.evidence
    }

async def resolve_conflicts_with_llm(db: InferenceResult, web: InferenceResult) -> dict:
    """중간 일치도 시 LLM으로 충돌 해소"""
    llm_response = openai_client.chat.completions.create(
        model="gpt-4",
        messages=[
            {"role": "system", "content": "You are a GR Framework expert. Resolve conflicts between DB and Web inference."},
            {"role": "user", "content": f"DB inference: {db.dict()}\n\nWeb inference: {web.dict()}\n\nResolve conflicts and provide final answer."}
        ]
    )

    return parse_llm_response(llm_response.choices[0].message.content)

def parse_llm_response(response: str) -> dict:
    """LLM 응답 파싱"""
    # 간단한 파싱 로직 (실제로는 더 정교하게)
    return {
        "layer": "L7",
        "zone": "Zone2",
        "tags": ["A1.5", "N2.1"]
    }
```

---

#### 6.3 Direct Query vs AI-Assisted API 🆕

**Purpose**: 80% Direct Query (AI 불필요) + 20% AI-Assisted (복잡한 추론)

```python
from fastapi import FastAPI, Depends
from enum import Enum

app = FastAPI()

class QueryMode(str, Enum):
    DIRECT = "direct"           # PostgreSQL/Neo4j 직접 쿼리 (80%)
    AI_ASSISTED = "ai_assisted" # LLM 추론 필요 (20%)

# ========================================
# 80% Direct Query APIs (AI 불필요)
# ========================================

@app.get("/api/v1/products/{product_name}/tags")
async def get_product_tags_direct(product_name: str):
    """
    Direct Query: PostgreSQL + Neo4j 직접 쿼리
    - 응답 시간: 50ms
    - 정확도: 100%
    - 비용: $0
    - 기밀 안전: ✅
    """
    with pg_conn.cursor() as cur:
        cur.execute("""
            SELECT p.name, a.role, a.layer, a.zone,
                   array_agg(DISTINCT t.code) AS tags
            FROM products p
            JOIN archetypes a ON p.id = a.product_id
            LEFT JOIN archetype_tags at ON a.id = at.archetype_id
            LEFT JOIN tags t ON at.tag_id = t.id
            WHERE p.name = %s
            GROUP BY p.id, a.id
        """, (product_name,))

        result = cur.fetchall()

    return {
        "query_mode": "direct",
        "response_time_ms": 50,
        "cost": 0.0,
        "data": result
    }

@app.get("/api/v1/zones/{zone_code}/products")
async def get_zone_products_direct(zone_code: str):
    """
    Direct Query: 특정 Zone에 배치된 모든 제품 조회
    - 응답 시간: 80ms
    - AI 불필요
    """
    with neo4j_driver.session() as session:
        result = session.run("""
            MATCH (z:Zone {code: $zone_code})<-[:BELONGS_TO]-(a:Archetype)
            MATCH (a)<-[:HAS_ARCHETYPE]-(p:Product)
            RETURN p.name, a.role, a.layer, a.primary_tag
            ORDER BY p.name
        """, zone_code=zone_code)

        products = [record.data() for record in result]

    return {
        "query_mode": "direct",
        "zone": zone_code,
        "count": len(products),
        "products": products
    }

@app.get("/api/v1/cves/{cve_id}/affected-products")
async def get_cve_affected_products_direct(cve_id: str):
    """
    Direct Query: CVE로 영향 받는 제품 및 GR Framework 컨텍스트 조회
    - 응답 시간: 100ms
    - AI 불필요
    """
    with pg_conn.cursor() as cur:
        cur.execute("""
            SELECT
                c.cve_id,
                c.cvss_score,
                c.vulnerable_layers,
                c.vulnerable_zones,
                c.vulnerable_tags,
                array_agg(DISTINCT p.name) AS affected_products,
                array_agg(DISTINCT m.technique_id) AS mitre_techniques
            FROM cves c
            LEFT JOIN cve_product_mapping cpm ON c.id = cpm.cve_id
            LEFT JOIN products p ON cpm.product_id = p.id
            LEFT JOIN cve_mitre_mapping cmm ON c.id = cmm.cve_id
            LEFT JOIN mitre_techniques m ON cmm.technique_id = m.id
            WHERE c.cve_id = %s
            GROUP BY c.id
        """, (cve_id,))

        result = cur.fetchone()

    return {
        "query_mode": "direct",
        "cve_id": result[0],
        "cvss_score": result[1],
        "vulnerable_layers": result[2],
        "vulnerable_zones": result[3],
        "vulnerable_tags": result[4],
        "affected_products": result[5],
        "mitre_techniques": result[6]
    }

# ========================================
# 20% AI-Assisted APIs (복잡한 추론 필요)
# ========================================

@app.post("/api/v1/analyze/attack-path")
async def analyze_attack_path_ai(infrastructure_data: dict):
    """
    AI-Assisted: 공격 경로 분석 및 추론
    - 옵션 1: On-premise LLM (기밀 유지)
    - 옵션 2: 익명화 후 외부 LLM API
    - 응답 시간: 2-5초
    - 비용: $0.01 per request
    """
    # Neo4j에서 공격 경로 그래프 추출
    with neo4j_driver.session() as session:
        result = session.run("""
            MATCH path = (z1:Zone {code: $start_zone})
                         -[:ATTACK_PATH*1..5]->
                         (z2:Zone {code: $end_zone})
            RETURN path, LENGTH(path) AS hop_count
            ORDER BY hop_count
            LIMIT 5
        """, start_zone=infrastructure_data['start_zone'],
             end_zone=infrastructure_data['end_zone'])

        attack_paths = [record.data() for record in result]

    # LLM 추론 (On-premise or External)
    if USE_ONPREMISE_LLM:
        # 옵션 1: On-premise LLM (Llama 3.1, Mistral)
        analysis = llm_client.generate(
            prompt=f"Analyze attack paths: {attack_paths}\n\nProvide risk assessment and mitigation strategies.",
            model="llama-3.1-8b-instruct",
            max_tokens=1000
        )
    else:
        # 옵션 2: 외부 LLM API (익명화 후 사용)
        anonymized_data = anonymize_infrastructure_data(infrastructure_data)
        analysis = openai_client.chat.completions.create(
            model="gpt-4",
            messages=[
                {"role": "system", "content": "You are a cybersecurity expert analyzing attack paths."},
                {"role": "user", "content": f"Attack paths: {anonymized_data}\n\nProvide analysis."}
            ]
        )
        analysis = analysis.choices[0].message.content

    return {
        "query_mode": "ai_assisted",
        "llm_type": "on_premise" if USE_ONPREMISE_LLM else "external_api",
        "attack_paths": attack_paths,
        "ai_analysis": analysis,
        "cost_usd": 0.01
    }

@app.post("/api/v1/infer/new-product")
async def infer_new_product_archetype(product_description: str):
    """
    AI-Assisted: 신규 제품의 Archetype 추론
    - Pinecone 벡터 유사도 + LLM 추론
    - 응답 시간: 1-3초
    - 비용: $0.005 per request
    """
    # Pinecone 벡터 검색
    query_embedding = openai_client.embeddings.create(
        model="text-embedding-ada-002",
        input=product_description
    ).data[0].embedding

    similar_products = pinecone_index.query(
        vector=query_embedding,
        top_k=5,
        include_metadata=True
    )

    # LLM으로 Archetype 추론
    llm_response = openai_client.chat.completions.create(
        model="gpt-4",
        messages=[
            {"role": "system", "content": "You are a GR Framework expert. Infer Archetype based on similar products."},
            {"role": "user", "content": f"New product: {product_description}\n\nSimilar products: {similar_products}\n\nInfer: Layer, Zone, Tags"}
        ]
    )

    inference = parse_llm_response(llm_response.choices[0].message.content)

    return {
        "query_mode": "ai_assisted",
        "similar_products": [m.metadata for m in similar_products.matches],
        "inference": inference,
        "confidence": 0.80,
        "cost_usd": 0.005
    }

def anonymize_infrastructure_data(data: dict) -> dict:
    """기밀 데이터 익명화"""
    return {
        "start_zone": data['start_zone'],  # Zone 정보는 유지
        "end_zone": data['end_zone'],
        "products": ["Product_A", "Product_B"],  # 실제 제품명 익명화
        "ips": ["10.x.x.x", "172.x.x.x"]  # IP 주소 마스킹
    }

# Configuration
USE_ONPREMISE_LLM = False  # True: On-premise, False: External API
```

**API 사용 가이드**

| 사용 사례 | API 엔드포인트 | Query Mode | 비용 | 응답 시간 |
|----------|---------------|-----------|------|----------|
| 제품 태그 조회 | `/products/{name}/tags` | Direct | $0 | 50ms |
| Zone별 제품 목록 | `/zones/{code}/products` | Direct | $0 | 80ms |
| CVE 영향 분석 | `/cves/{id}/affected-products` | Direct | $0 | 100ms |
| 공격 경로 분석 | `/analyze/attack-path` | AI-Assisted | $0.01 | 2-5s |
| 신규 제품 추론 | `/infer/new-product` | AI-Assisted | $0.005 | 1-3s |

**비용 최적화 전략**:
- **Phase 0-2 (GR DB 구축)**: 외부 LLM API 자유 사용 (~$1K/year)
- **고객 배포**: 80% Direct Query (무료), 20% AI-Assisted (on-premise or 익명화)

---

## 📊 7. 성능 최적화

### 7.1 PostgreSQL 최적화

```sql
-- 파티셔닝 (제품 수가 10만 개 이상일 때)
CREATE TABLE products (
    ...
) PARTITION BY HASH (id);

CREATE TABLE products_p0 PARTITION OF products FOR VALUES WITH (MODULUS 4, REMAINDER 0);
CREATE TABLE products_p1 PARTITION OF products FOR VALUES WITH (MODULUS 4, REMAINDER 1);
CREATE TABLE products_p2 PARTITION OF products FOR VALUES WITH (MODULUS 4, REMAINDER 2);
CREATE TABLE products_p3 PARTITION OF products FOR VALUES WITH (MODULUS 4, REMAINDER 3);

-- Materialized View (자주 조회되는 통계)
CREATE MATERIALIZED VIEW product_stats AS
SELECT
    v.name AS vendor,
    COUNT(*) AS product_count,
    COUNT(CASE WHEN c.severity = 'Critical' THEN 1 END) AS critical_cve_count
FROM products p
JOIN vendors v ON p.vendor_id = v.id
LEFT JOIN cves c ON p.id = c.product_id
GROUP BY v.name;

CREATE INDEX idx_product_stats_vendor ON product_stats(vendor);

-- 1시간마다 갱신
CREATE EXTENSION pg_cron;
SELECT cron.schedule('refresh-product-stats', '0 * * * *',
    'REFRESH MATERIALIZED VIEW CONCURRENTLY product_stats');
```

### 7.2 Neo4j 최적화

```cypher
-- 인덱스 생성
CREATE INDEX product_name IF NOT EXISTS FOR (p:Product) ON (p.name);
CREATE INDEX archetype_layer IF NOT EXISTS FOR (a:Archetype) ON (a.layer);
CREATE INDEX zone_code IF NOT EXISTS FOR (z:Zone) ON (z.code);

-- 자주 사용되는 쿼리를 위한 복합 인덱스
CREATE INDEX archetype_layer_zone IF NOT EXISTS
FOR (a:Archetype) ON (a.layer, a.zone);
```

### 7.3 Pinecone 최적화

```python
# Batch Upsert (한 번에 여러 벡터 업서트)
vectors_to_upsert = []
for product in products:
    embedding = get_embedding(product.description)
    vectors_to_upsert.append({
        "id": f"product-{product.id}",
        "values": embedding,
        "metadata": {...}
    })

# 최대 100개씩 배치 처리
index.upsert(vectors=vectors_to_upsert, batch_size=100)
```

---

## 🔐 8. 보안 및 백업 전략

### 8.1 접근 제어

```yaml
PostgreSQL:
  - 읽기 전용 계정 (API 서버용)
  - 쓰기 가능 계정 (관리자용)
  - SSL/TLS 암호화 필수

Neo4j:
  - RBAC 활성화
  - 읽기 전용 계정 (API 서버용)
  - Bolt 프로토콜 암호화

Pinecone:
  - API Key 로테이션 (30일마다)
  - IP Whitelist 설정
```

### 8.2 백업 전략

| Database | 백업 주기 | 보관 기간 | 방법 |
|----------|----------|----------|------|
| **PostgreSQL** | 매일 (01:00 AM) | 30일 | AWS RDS 자동 백업 + S3 스냅샷 |
| **Neo4j** | 매일 (02:00 AM) | 14일 | `neo4j-admin backup` → S3 |
| **Pinecone** | 매주 (일요일) | 4주 | 메타데이터 export → S3 |

---

## 📈 9. 모니터링 지표

### 9.1 핵심 KPI

| 지표 | 목표치 | 측정 도구 |
|------|--------|----------|
| **API 응답 시간 (P95)** | < 500ms | Prometheus + Grafana |
| **벡터 검색 시간** | < 100ms | Pinecone Metrics |
| **그래프 쿼리 시간** | < 200ms | Neo4j Metrics |
| **DB 동기화 지연** | < 5초 | Custom Metrics |
| **데이터 정확도** | > 95% | 수동 샘플링 검증 |

---

## 🎯 최종 체크리스트

**Phase 0 구현 전 확인 사항**:
- [ ] PostgreSQL RDS 인스턴스 생성 (db.t3.medium)
- [ ] Neo4j AuraDB 프로페셔널 계정 생성
- [ ] Pinecone Serverless 인덱스 생성 (dimension=1536)
- [ ] OpenAI API Key 발급 (임베딩용)
- [ ] FastAPI 프로젝트 초기화
- [ ] 100개 제품 리스트 확정
- [ ] 데이터 동기화 워커 개발

---

## 🛤️ 10. 구현 로드맵 (Implementation Roadmap)

### 설계 vs 구현의 분리

**중요**: 본 문서는 **논리적 아키텍처 설계(Logical Architecture)**를 정의합니다.
실제 물리적 구현(Physical Implementation)은 프로젝트 단계에 따라 점진적으로 진행됩니다.

```
┌────────────────────────────────────────────────────────────┐
│  Level 1: Concept Model (개념 모델)                        │
│  - GR Framework (Layer × Zone × Tag)                      │
│  - DB 독립적, 영속적                                        │
└────────────────────────────────────────────────────────────┘
                         ▼
┌────────────────────────────────────────────────────────────┐
│  Level 2: Logical Schema (논리적 스키마) ← 본 문서           │
│  - Entity 정의, Relationship 정의                          │
│  - DB 유형 결정 (RDBMS, Graph, Vector)                    │
│  - DB 제품 독립적 (PostgreSQL vs MySQL 선택 이전)          │
└────────────────────────────────────────────────────────────┘
                         ▼
┌────────────────────────────────────────────────────────────┐
│  Level 3: Physical Implementation (물리적 구현)            │
│  - 실제 DB 설치 및 설정                                     │
│  - v0, v1, v2 단계별 롤아웃 ← 이 섹션이 다룸                │
└────────────────────────────────────────────────────────────┘
```

---

### 단계별 구현 전략

#### v0: PostgreSQL Only (Phase 1-2 초반)

**목표**: 핵심 기능 검증 및 빠른 초기 구축

**구현 범위**:
```yaml
Database:
  - PostgreSQL only
  - pgvector extension (벡터 검색 기본 지원)

Tables:
  - products, vendors, licenses
  - product_versions
  - archetypes (PostgreSQL 내에서 관계 관리)
  - cves, cve_product_versions
  - mitre_techniques, cve_mitre_mapping
  - function_tags, layer_zone_mapping

Vector Search:
  - pgvector 확장 사용
  - PostgreSQL 내에서 기본 벡터 검색 제공
  - Dimension: 1536 (OpenAI ada-002 embedding)

Features:
  - ✅ 제품 기본 정보 관리
  - ✅ 버전 관리
  - ✅ CVE 매핑
  - ✅ 기본 Archetype 관리 (Foreign Key로 관계 표현)
  - ✅ 기본 벡터 검색 (pgvector)
  - ❌ 복잡한 그래프 쿼리
  - ❌ 고속 벡터 검색
```

**장점**:
- ✅ **단순성**: 하나의 DB만 관리
- ✅ **빠른 구축**: 초기 설정 및 학습 비용 최소화
- ✅ **비용 효율**: PostgreSQL RDS만 운영
- ✅ **트랜잭션**: ACID 보장
- ✅ **백업/복구**: RDS 자동 백업 활용

**한계**:
- ⚠️ 그래프 쿼리 성능: 복잡한 관계 탐색 시 JOIN 다발성
- ⚠️ 벡터 검색 성능: pgvector는 Pinecone 대비 속도 제한적

**적용 단계**:
- Phase 1 (분류 체계 구축)
- Phase 2-1 (100-300개 핵심 제품)

**인프라 비용** (월간):
```yaml
PostgreSQL RDS:
  instance: db.t3.medium
  storage: 100GB SSD
  cost: ~$50/month
```

---

#### v1: PostgreSQL + Neo4j (필요시 추가)

**추가 시점**: 그래프 쿼리 성능이 병목이 되는 경우

**트리거 조건**:
- Attack Path 쿼리가 5초 이상 소요
- Archetype 관계 탐색이 빈번하게 발생
- Zone-to-Zone 통신 경로 분석이 핵심 기능으로 부상

**추가 구현**:
```yaml
New Database:
  - Neo4j AuraDB Professional
  - Graph DB for relationship navigation

Data Migration:
  - PostgreSQL → Neo4j 동기화
  - products → :Product 노드
  - archetypes → :Archetype 노드
  - relationships → [:HAS_ARCHETYPE], [:LOCATED_IN], [:TAGGED_WITH]

Performance Improvement:
  - Attack Path 쿼리: 5초 → 200ms (25배 향상)
  - Archetype 탐색: 1초 → 50ms (20배 향상)

Features Added:
  - ✅ 고속 그래프 쿼리
  - ✅ Attack Path 시뮬레이션
  - ✅ Zone-to-Zone 통신 경로 분석
  - ✅ MITRE ATT&CK 체인 분석
```

**장점**:
- ✅ **그래프 쿼리 최적화**: Neo4j의 네이티브 그래프 엔진
- ✅ **관계 탐색**: 복잡한 관계도 직관적 쿼리 (Cypher)
- ✅ **공격 경로**: MITRE 기법 체인 분석 최적화

**추가 비용** (월간):
```yaml
Neo4j AuraDB:
  instance: Professional (1 instance)
  cost: ~$200/month

Total: $250/month (PostgreSQL $50 + Neo4j $200)
```

**Migration 전략**:
```python
# PostgreSQL에서 Neo4j로 데이터 동기화
def sync_postgresql_to_neo4j():
    # 1. PostgreSQL에서 읽기
    products = pg.execute("SELECT * FROM products")
    archetypes = pg.execute("SELECT * FROM archetypes")

    # 2. Neo4j에 쓰기
    for product in products:
        neo4j.run("CREATE (p:Product {id: $id, name: $name})",
                  id=product.id, name=product.name)

    for archetype in archetypes:
        neo4j.run("""
            MATCH (p:Product {id: $product_id})
            CREATE (a:Archetype {id: $id, role: $role})
            CREATE (p)-[:HAS_ARCHETYPE]->(a)
        """, product_id=archetype.product_id,
             id=archetype.id, role=archetype.role)
```

**Framework 영향**:
- ✅ GR Framework는 변경 없음 (DB 독립적 설계)
- ✅ API 계층에서 쿼리 라우팅만 추가
- ✅ 기존 PostgreSQL 데이터는 Source of Truth로 유지

---

#### v2: PostgreSQL + Neo4j + Pinecone (필요시 추가)

**추가 시점**: 대규모 유사도 검색 및 AI 추론이 핵심 요구사항인 경우

**트리거 조건**:
- 제품 수가 10,000개 이상
- 벡터 검색이 초당 100회 이상 요청
- pgvector 성능이 병목 (검색 시간 >1초)
- AI 추론 기능이 서비스 핵심으로 자리잡음

**추가 구현**:
```yaml
New Database:
  - Pinecone Serverless
  - Vector DB for high-performance similarity search

Data Migration:
  - PostgreSQL → Pinecone 벡터 업서트
  - products.description → OpenAI embedding → Pinecone
  - archetypes → Archetype 벡터 업서트

Performance Improvement:
  - 벡터 검색: 1초 (pgvector) → 50ms (Pinecone) (20배 향상)
  - 동시 처리: 10 qps → 1000 qps (100배 향상)
  - 정확도: ANN(Approximate Nearest Neighbor) 최적화

Features Added:
  - ✅ 고속 대규모 벡터 검색
  - ✅ AI 기반 제품 추천
  - ✅ 신규 제품 Archetype 자동 추론
  - ✅ 유사 제품 탐색 (semantic search)
```

**장점**:
- ✅ **속도**: Pinecone 전용 하드웨어 최적화
- ✅ **확장성**: 수백만 벡터 지원
- ✅ **정확도**: ANN 알고리즘 최적화
- ✅ **관리 편의**: Serverless 아키텍처

**추가 비용** (월간):
```yaml
Pinecone Serverless:
  vectors: 100K vectors (10,000 products × 10 archetypes)
  cost: ~$70/month

Total: $320/month (PostgreSQL $50 + Neo4j $200 + Pinecone $70)
```

**Framework 영향**:
- ✅ GR Framework는 변경 없음
- ✅ API에서 벡터 검색 라우팅 추가
- ✅ PostgreSQL은 여전히 Master DB

---

### 구현 로드맵 요약

| 버전 | DB 구성 | 적용 단계 | 월 비용 | 핵심 기능 | 추가 시점 |
|------|---------|----------|---------|----------|----------|
| **v0** | PostgreSQL + pgvector | Phase 1-2 초반 | $50 | 제품 관리, 기본 검색 | 초기 구축 |
| **v1** | + Neo4j | Phase 2-2 중반 | $250 | 그래프 쿼리, Attack Path | 그래프 성능 필요시 |
| **v2** | + Pinecone | Phase 2-3 후반 | $320 | AI 추론, 대규모 벡터 검색 | 대규모 데이터 + AI 필요시 |

---

### Migration 시나리오

#### v0 → v1 Migration

```yaml
Phase 1: Neo4j 준비
  - AuraDB 인스턴스 생성
  - 스키마 설계 검증

Phase 2: 초기 데이터 로드
  - PostgreSQL snapshot 시점 기준
  - products, archetypes 일괄 마이그레이션

Phase 3: CDC 설정
  - PostgreSQL → Neo4j 실시간 동기화
  - Change Data Capture 워커 실행

Phase 4: API 업데이트
  - 그래프 쿼리 → Neo4j 라우팅
  - 기존 PostgreSQL 쿼리 유지

Phase 5: 검증 및 모니터링
  - 쿼리 성능 비교
  - 동기화 지연 모니터링
```

#### v1 → v2 Migration

```yaml
Phase 1: Pinecone 준비
  - Serverless Index 생성
  - Dimension 1536 설정

Phase 2: 벡터 생성
  - OpenAI Embedding API 호출
  - products.description → 1536차원 벡터

Phase 3: 일괄 업서트
  - Batch upsert (100개씩)
  - 메타데이터 포함

Phase 4: API 업데이트
  - 벡터 검색 → Pinecone 라우팅
  - pgvector는 fallback으로 유지

Phase 5: 성능 검증
  - 검색 속도 측정
  - 정확도 비교 (Precision@K)
```

---

### Framework 독립성 보장

**핵심 원칙**: GR Framework는 DB 구현에 독립적

```
GR Framework (Concept)
    ↓ (defines)
Logical Schema (Entity/Relationship)
    ↓ (implements using)
Physical DB (v0 → v1 → v2)
```

**변경되지 않는 것**:
- ✅ Layer × Zone × Tag 정의
- ✅ Archetype 개념
- ✅ Entity 및 Relationship 정의
- ✅ API Contract (엔드포인트, 응답 형식)

**변경되는 것**:
- ✅ 쿼리 라우팅 (PostgreSQL vs Neo4j vs Pinecone)
- ✅ 성능 최적화 전략
- ✅ 인프라 비용

---

### 권장 사항

**Phase 1-2 초반**: v0 (PostgreSQL only)로 시작
- 복잡도 최소화
- 빠른 검증
- 비용 최적화

**Phase 2-2 중반**: 그래프 쿼리 필요시 v1 추가
- Attack Path 분석이 핵심 기능인 경우
- 복잡한 관계 탐색 빈도 증가

**Phase 2-3 후반**: 대규모 AI 추론 필요시 v2 추가
- 제품 수 10,000개 이상
- 벡터 검색 성능 병목
- AI 기반 추천 서비스 런칭

**결론**:
논리적 설계는 v2를 목표로 완성하되, 물리적 구현은 v0 → v1 → v2로 점진적 확장.

---

## ⚠️ 11. 실무 리스크 및 보완 전략 (Practical Pitfalls)

> 완벽해 보이는 설계에도 실무적인 함정(Pitfalls)은 존재합니다. 이 섹션은 실제 구현 시 마주칠 수 있는 3가지 핵심 리스크와 그 보완 전략을 정리합니다.

### 11.1 Risk 1: CPE(Common Platform Enumeration)의 지옥

**문제점**:
- NVD(National Vulnerability Database)의 CPE 데이터는 신뢰도가 낮습니다
- 벤더명 변경: Sun Microsystems → Oracle, Red Hat → IBM
- 표기 불일치: httpd vs Apache Web Server vs Apache HTTP Server
- 제품명 오타 및 변형: Ngingx, nginx, NGINX

**발생 시나리오**:
```
사용자: "우리 서버에 httpd 2.4.51이 설치되어 있는데 취약점 있어?"
시스템: "Apache HTTP Server가 DB에 없습니다" ← CPE 불일치로 검색 실패
```

**보완 전략**:
- ✅ `product_aliases` 테이블 추가 (Section 2.2)
- ✅ 다양한 별칭 유형 지원: canonical, common_name, legacy_name, cpe, legacy_cpe, typo
- ✅ `find_product_by_alias()` 함수로 유연한 검색 제공

**구현 우선순위**: 🔴 높음 (v0 구축 시 즉시)

---

### 11.2 Risk 2: 데이터 동기화(CDC)의 복잡성

**문제점**:
- "PostgreSQL에 넣으면 Neo4j와 Pinecone에 자동 동기화된다"는 말은 쉽지만 구현은 어렵습니다
- 트랜잭션 불일치: PG에는 들어갔는데 Neo4j에는 안 들어가는 경우
- Debezium 같은 CDC 툴은 초기 학습 곡선이 높음
- 네트워크 장애, DB 다운타임 시 데이터 정합성 문제

**발생 시나리오**:
```
1. products INSERT 성공 (PostgreSQL)
2. Neo4j 동기화 중 네트워크 오류 발생
3. 결과: PostgreSQL에만 데이터 존재, 그래프 쿼리 불가
4. 사용자는 "제품이 있는데 왜 그래프에서 안 보여요?" 문의
```

**보완 전략**:
- ✅ Outbox Pattern 도입 (Section 5)
- ✅ `sync_outbox` 테이블로 트랜잭션 보장
- ✅ 자동 재시도 (exponential backoff)
- ✅ v0 → v1 단계별 전환 전략

**구현 우선순위**: 🟡 중간 (v1 전환 시)

**핵심 원칙**:
> "실시간성이 1~2초 늦는 것은 이 서비스에서 치명적이지 않지만, 데이터가 틀리는 것은 치명적입니다."

---

### 11.3 Risk 3: 버전 비교(Version Comparison) 로직

**문제점**:
- `affected_version_start: "2.0-beta9"`를 문자열(VARCHAR)로 저장하면 SQL 비교가 어렵습니다
- 문자열 정렬 문제: "10.0" < "2.0" (ASCII 순서)
- Semantic versioning 외에도 다양한 버전 형식 존재: "2.0-beta9", "7.0.15-rc1", "2021.01"

**발생 시나리오**:
```sql
-- 의도: Redis 6.2.7이 CVE 영향 범위(2.0 ~ 7.0)에 포함되는지 확인
SELECT * FROM cve_product_versions
WHERE '6.2.7' BETWEEN affected_version_start AND affected_version_end;

-- 결과: 문자열 비교로 인해 정확하지 않은 결과 반환
-- "6.2.7" > "2.0-beta9" ← TRUE (우연히 맞음)
-- "10.0.0" < "2.0.0" ← TRUE (잘못된 결과!)
```

**보완 전략**:
- ✅ 정수형 컬럼 분리: `affected_start_major`, `affected_start_minor`, `affected_start_patch` (Section 2.8)
- ✅ `version_in_range()` 함수로 정확한 범위 비교
- ✅ `parse_version()` 함수로 문자열 → 정수 변환
- ✅ `is_version_affected()` 함수로 CVE 영향 여부 확인

**구현 우선순위**: 🔴 높음 (v0 구축 시 즉시)

---

### 11.4 리스크 대응 체크리스트

| 리스크 | 문제 | 보완 테이블/함수 | 우선순위 | 구현 시점 |
|--------|------|-----------------|----------|----------|
| **CPE 지옥** | 벤더 변경, 표기 불일치 | `product_aliases` + `find_product_by_alias()` | 🔴 높음 | v0 |
| **동기화 복잡성** | 트랜잭션 불일치, CDC 어려움 | `sync_outbox` + Outbox Pattern | 🟡 중간 | v1 |
| **버전 비교** | 문자열 비교 오류 | 정수형 컬럼 + `version_in_range()` | 🔴 높음 | v0 |

### 11.5 추가 고려 사항

**v0 구축 전 반드시 확인**:
- [ ] `product_aliases` 테이블 생성
- [ ] `cve_product_versions` 테이블에 정수형 버전 컬럼 추가
- [ ] `version_in_range()`, `parse_version()`, `is_version_affected()` 함수 생성
- [ ] 100개 핵심 제품의 별칭 데이터 수집 (최소 5개 별칭/제품)

**v1 전환 전 반드시 확인**:
- [ ] `sync_outbox` 테이블 생성
- [ ] Outbox 트리거 함수 생성 (`fn_products_outbox_trigger`, `fn_archetypes_outbox_trigger`)
- [ ] Outbox Processor 배치 작업 설정 (5분 주기)
- [ ] 동기화 실패 시 알림 설정

---

## 📝 변경 이력

### v2.4 (2025-01-26)
**주요 변경 사항**: 실무 리스크 대응 전략 추가

1. **Risk 1 - CPE 정규화 (Section 2.2)**:
   - `product_aliases` 테이블 추가
   - alias_type: canonical, common_name, legacy_name, cpe, legacy_cpe, typo
   - `find_product_by_alias()` 함수로 유연한 검색 제공
   - Apache HTTP Server, Oracle Java 샘플 데이터

2. **Risk 2 - 데이터 동기화 전략 개선 (Section 5)**:
   - Outbox Pattern 도입 (CDC 대신 초기 단계에서 사용)
   - `sync_outbox` 테이블 추가
   - Outbox 트리거 함수 (`fn_products_outbox_trigger`, `fn_archetypes_outbox_trigger`)
   - `OutboxProcessor` Python 클래스 (자동 재시도, exponential backoff)
   - 동기화 전략 단계별 적용: v0(PG Only) → v1 초기(Outbox) → v1 성숙(CDC)

3. **Risk 3 - 버전 비교 로직 개선 (Section 2.8)**:
   - `cve_product_versions` 테이블에 정수형 버전 컬럼 추가
     - `affected_start_major`, `affected_start_minor`, `affected_start_patch`
     - `affected_end_major`, `affected_end_minor`, `affected_end_patch`
   - `version_in_range()` 함수: 정수 기반 범위 비교
   - `parse_version()` 함수: 문자열 → 정수 변환
   - `is_version_affected()` 함수: CVE 영향 여부 확인

4. **Section 11 추가 - 실무 리스크 및 보완 전략**:
   - 3가지 핵심 리스크 문서화 (CPE, 동기화, 버전 비교)
   - 발생 시나리오 및 보완 전략 상세 설명
   - 리스크 대응 체크리스트 제공
   - v0/v1 구축 전 확인 사항 정리

5. **섹션 번호 재정렬**:
   - 2.2 product_aliases 🆕
   - 2.3 product_versions
   - 2.4 vendors
   - 2.5 licenses
   - 2.6 archetypes
   - 2.7 cves
   - 2.8 cve_product_versions (버전 비교 컬럼 추가)
   - 2.9 MITRE ATT&CK Integration Tables

**이전 버전**: v2.3 (DB_아키텍처_설계서_v2.3.md)

---

### v2.3 (2025-01-20)
**주요 변경 사항**: 구현 로드맵 추가 (Section 10)

1. **설계 vs 구현 분리 명확화**:
   - Level 1: Concept Model (GR Framework) - DB 독립적
   - Level 2: Logical Schema (본 문서) - DB 제품 독립적
   - Level 3: Physical Implementation - 단계별 구현

2. **v0: PostgreSQL Only (Phase 1-2 초반)**:
   - pgvector 확장 사용 (기본 벡터 검색)
   - 핵심 테이블: products, versions, archetypes, cves
   - 월 비용: $50 (PostgreSQL RDS만)
   - 장점: 단순성, 빠른 구축, 비용 효율, ACID 보장

3. **v1: PostgreSQL + Neo4j (그래프 성능 필요시)**:
   - 추가 조건: Attack Path 쿼리 5초 이상, 관계 탐색 빈번
   - 성능 향상: Attack Path 5초 → 200ms (25배)
   - 월 비용: $250 (PostgreSQL $50 + Neo4j $200)
   - Migration 전략 제공

4. **v2: PostgreSQL + Neo4j + Pinecone (대규모 AI 필요시)**:
   - 추가 조건: 제품 10K+ 개, 벡터 검색 >100 qps
   - 성능 향상: 벡터 검색 1초 → 50ms (20배)
   - 월 비용: $320 (PostgreSQL $50 + Neo4j $200 + Pinecone $70)
   - Migration 시나리오 제공

5. **Framework 독립성 보장**:
   - GR Framework는 DB 구현과 독립적
   - v0 → v1 → v2 마이그레이션 시 Framework 변경 없음
   - API Contract 유지 (쿼리 라우팅만 변경)

6. **권장 사항**:
   - 논리적 설계는 v2를 목표로 완성
   - 물리적 구현은 v0 → v1 → v2로 점진적 확장
   - 필요시에만 추가 (필요시점 명확히 정의)

**이전 버전**: v2.2 (DB_아키텍처_설계서_v2.2.md)

---

### v2.2 (2025-01-20)
**주요 변경 사항**: 제품 버전 관리 시스템 추가

1. **product_versions 테이블 추가** (Section 2.2):
   - 같은 제품의 다른 버전들을 개별적으로 관리
   - 버전별 메타데이터: release_date, eol_date, support_status, is_lts
   - 버전별 기능 변경: major_features, breaking_changes, security_improvements
   - Semantic versioning 지원: version_major, version_minor, version_patch
   - Redis 5.0.14, 6.2.14 (LTS), 7.0.15, 7.2.4 예시 데이터

2. **products 테이블 리팩토링** (Section 2.1):
   - 버전 독립적 제품 메타데이터만 유지
   - release_date, eol_date, current_version 필드 제거 → product_versions로 이동
   - cpe → cpe_product로 이름 변경 (제품 레벨 CPE, 버전 와일드카드)

3. **archetypes 테이블 개선** (Section 2.5):
   - version_id 컬럼 추가: 특정 버전과 연결 가능
   - min_version, max_version 컬럼 추가: 버전 범위 지정 가능
   - Redis 5.x, 6.x, 7.x 버전별 Archetype 예시 (기능 차이 반영)

4. **CVE 테이블 분리 및 개선**:
   - cves 테이블 (Section 2.6): CVE 정보만 (제품 연결 제거)
   - cve_product_versions 테이블 (Section 2.7): CVE-제품 버전 범위 매핑
   - affected_version_start, affected_version_end: 버전 범위 지원
   - fixed_version, fixed_version_id: 수정 버전 추적
   - Log4Shell (CVE-2021-44228) 예시 데이터 with 버전 범위

5. **쿼리 예시 추가** (Section 2 끝):
   - 예시 1: 제품의 모든 버전과 지원 상태 조회
   - 예시 2: 특정 버전이 영향받는 CVE 조회
   - 예시 3: 제품별 Critical CVE 개수 및 최고 CVSS 점수
   - 예시 4: 버전별 Archetype 및 CVE 조회
   - 예시 5: EOL 임박 버전 (6개월 이내)

6. **섹션 번호 재정렬**:
   - 2.1 products → 변경 없음
   - 2.2 product_versions → 🆕 신규 추가
   - 2.3 vendors → 변경 없음
   - 2.4 licenses → 이전 2.3에서 변경
   - 2.5 archetypes → 이전 2.4 versions 삭제 후 재구성
   - 2.6 cves → 개선
   - 2.7 cve_product_versions → 🆕 신규 추가
   - 2.8 MITRE ATT&CK Integration Tables → 이전 2.6에서 변경

**이전 버전**: v2.1 → 같은 문서의 이전 상태

---

### v2.1 (2025-01-20)
**주요 변경 사항**:
1. **MITRE ATT&CK 통합**:
   - PostgreSQL: `mitre_techniques`, `cve_mitre_mapping` 테이블 추가
   - `cves` 테이블에 GR Framework 컨텍스트 컬럼 추가 (vulnerable_layers, vulnerable_zones, vulnerable_tags)
   - Neo4j: `AttackPath`, `MITRETechnique` 노드 및 관계 추가
   - CVE → MITRE → GR Framework 3-Way 매핑 지원

2. **Web Search 파이프라인 추가** (Section 6.2):
   - DB 기반 추론과 Web 기반 추론의 교차 검증 API
   - `/api/v1/inference/cross-validate` 엔드포인트
   - 공식 문서, GitHub, Stack Overflow, Reddit 크롤링
   - 0.85 임계값 기반 자동 승인/LLM 해소/전문가 검증 로직

3. **Direct Query vs AI-Assisted API 분리** (Section 6.3):
   - 80% Direct Query API (AI 불필요, 무료, 50-100ms)
   - 20% AI-Assisted API (복잡한 추론, $0.005-$0.01, 1-5초)
   - On-premise LLM vs 외부 API 선택 옵션
   - 기밀 데이터 익명화 함수

4. **Attack Path 시뮬레이션** (Section 3.5):
   - Zone-to-Zone 공격 경로 그래프 모델링
   - Log4Shell 예시 데이터 추가
   - 5가지 Attack Path 쿼리 패턴 제공

**이전 버전**: v2.0 → DB_아키텍처_설계서_v2.0.md

### v2.0 (2025-01-19)
**주요 변경 사항**:
- PostgreSQL + Neo4j + Pinecone 하이브리드 아키텍처 확정
- 100,000+ 제품 데이터 지원을 위한 스키마 설계
- CVE 데이터베이스 통합
- FastAPI 기반 통합 검색 API 설계
- 성능 최적화 및 백업 전략 수립

**이전 버전**: v1.x (기존 설계 문서)

---

**문서 끝**
