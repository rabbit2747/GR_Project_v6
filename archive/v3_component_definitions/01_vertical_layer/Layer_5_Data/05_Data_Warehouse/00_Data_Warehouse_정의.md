# Data Warehouse (데이터 웨어하우스)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Data Warehouse |
| **한글명** | 데이터 웨어하우스 |
| **Layer** | Layer 5 (Data Services) |
| **분류** | Analytics Database |
| **Function Tag (Primary)** | D5.1 (Cloud DW) |
| **Function Tag (Secondary)** | D5.2 (On-Premise DW) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

데이터 웨어하우스는 **대규모 분석 쿼리에 최적화된 컬럼형 저장소**입니다.

---

## 🏗️ 주요 데이터 웨어하우스

### 1. AWS Redshift

**특징**: 컬럼형 스토리지, MPP(Massively Parallel Processing)

**쿼리 예시**:
```sql
-- 컬럼형 압축
CREATE TABLE sales (
  date DATE,
  product_id INT,
  amount DECIMAL(10,2)
) DISTKEY(product_id) SORTKEY(date);

-- 대규모 집계
SELECT DATE_TRUNC('month', date) as month,
       SUM(amount) as total_sales
FROM sales
WHERE date >= '2024-01-01'
GROUP BY month
ORDER BY month;
```

**가격**:
```yaml
dc2.large (2 vCPU, 15GB):
  - $0.25/시간 ($180/월)

dc2.8xlarge (32 vCPU, 244GB):
  - $4.80/시간 ($3,500/월)
```

---

### 2. Google BigQuery

**특징**: 서버리스, 페타바이트 규모, SQL 표준

**쿼리 예시**:
```sql
-- 공개 데이터셋 조회
SELECT country, SUM(confirmed) as total
FROM `bigquery-public-data.covid19_jhu_csse.summary`
WHERE date = '2024-01-01'
GROUP BY country
ORDER BY total DESC
LIMIT 10;
```

**가격**:
```yaml
스토리지:
  - Active: $0.020/GB/월
  - Long-term: $0.010/GB/월

쿼리:
  - $5 per TB processed
```

---

### 3. Snowflake

**특징**: 자동 확장, 타임 트래블, Zero-copy 클론

---

## 📊 OLTP vs OLAP

| 항목 | OLTP (운영 DB) | OLAP (분석 DW) |
|------|---------------|---------------|
| **목적** | 트랜잭션 처리 | 분석, 리포팅 |
| **쿼리** | 간단, 빠름 | 복잡, 느림 |
| **데이터** | 현재 데이터 | 이력 데이터 |
| **정규화** | 3NF | 비정규화 (Star Schema) |
| **예시** | PostgreSQL, MySQL | Redshift, BigQuery |

---

## 📁 데이터 모델링

### Star Schema

```sql
-- Fact Table (사실 테이블)
CREATE TABLE fact_sales (
  sale_id BIGINT,
  date_key INT,
  product_key INT,
  customer_key INT,
  amount DECIMAL(10,2),
  quantity INT
);

-- Dimension Tables (차원 테이블)
CREATE TABLE dim_date (
  date_key INT PRIMARY KEY,
  date DATE,
  year INT,
  month INT,
  day INT,
  quarter INT
);

CREATE TABLE dim_product (
  product_key INT PRIMARY KEY,
  product_name VARCHAR(100),
  category VARCHAR(50),
  price DECIMAL(10,2)
);
```

---

## ⚡ ETL 프로세스

```yaml
Extract:
  - 소스 DB에서 데이터 추출
  - 증분 로드 (Delta)

Transform:
  - 데이터 정제
  - 형식 변환
  - 집계

Load:
  - DW로 로드
  - Batch 또는 Streaming
```

---

## 🔒 Zone별 배치

| Zone | 배치 | 용도 |
|------|------|------|
| **Zone 3** | Common | Data Warehouse |
| **Zone 4** | Common | ETL Tools |

---

## 🔗 관련 문서

- [Layer 5 정의](../00_Layer_5_정의.md)
- [Relational Database](../01_Relational_Database/00_Relational_Database_정의.md)

---

**문서 끝**
