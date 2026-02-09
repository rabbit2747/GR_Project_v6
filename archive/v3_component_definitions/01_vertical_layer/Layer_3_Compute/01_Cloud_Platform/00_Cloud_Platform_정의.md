# Cloud Platform (클라우드 플랫폼)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Cloud Platform |
| **한글명** | 클라우드 플랫폼 |
| **Layer** | Layer 3 (Computing Infrastructure) |
| **분류** | IaaS Provider |
| **Function Tag (Primary)** | C1.1 (Public Cloud) |
| **Function Tag (Secondary)** | C1.2 (Private Cloud), C1.3 (Hybrid Cloud) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

클라우드 플랫폼은 **인터넷을 통해 컴퓨팅 리소스를 온디맨드로 제공하는 서비스**입니다.

---

## 🏗️ 주요 클라우드 제공업체

### 1. AWS (Amazon Web Services)

**시장 점유율**: 32% (2024)

**주요 서비스**:
- **EC2**: 가상 서버
- **S3**: 객체 스토리지
- **RDS**: 관리형 데이터베이스
- **Lambda**: 서버리스 함수
- **VPC**: 가상 네트워크

**가격 예시** (us-east-1):
```yaml
EC2 t3.medium:
  - vCPU: 2
  - Memory: 4GB
  - 가격: $0.0416/hour ($30/month)

EC2 m5.large:
  - vCPU: 2
  - Memory: 8GB
  - 가격: $0.096/hour ($70/month)

RDS PostgreSQL db.t3.medium:
  - $0.068/hour ($50/month)
```

---

### 2. Microsoft Azure

**시장 점유율**: 23%

**주요 서비스**:
- **Virtual Machines**: 가상 서버
- **Blob Storage**: 객체 스토리지
- **SQL Database**: 관리형 DB
- **Functions**: 서버리스
- **VNet**: 가상 네트워크

**차별점**:
- Active Directory 통합
- Office 365 연동
- Windows Server 최적화

---

### 3. Google Cloud Platform (GCP)

**시장 점유율**: 11%

**주요 서비스**:
- **Compute Engine**: VM
- **Cloud Storage**: 객체 스토리지
- **Cloud SQL**: 관리형 DB
- **BigQuery**: 데이터 웨어하우스
- **VPC**: 가상 네트워크

**차별점**:
- 빅데이터/ML 강점
- Kubernetes (GKE) 우수
- 글로벌 네트워크

---

## ☁️ 클라우드 모델

### Public Cloud (퍼블릭 클라우드)
```
특징:
- 다중 테넌트 (Multi-tenant)
- 인터넷 접근
- 종량제 과금

장점:
- 초기 비용 없음
- 무한 확장성
- 빠른 프로비저닝

단점:
- 보안/규정 준수 우려
- 데이터 주권 이슈
```

### Private Cloud (프라이빗 클라우드)
```
특징:
- 단일 조직 전용
- 온프레미스 또는 전용 호스팅
- VMware, OpenStack

장점:
- 완전한 통제
- 규정 준수 쉬움
- 데이터 보안

단점:
- 높은 초기/운영 비용
- 확장 제한
```

### Hybrid Cloud (하이브리드 클라우드)
```
구성: Public + Private

Use Case:
- 민감 데이터 → Private
- 웹 서버 → Public
- 버스트 워크로드 → Public (Cloud Bursting)

솔루션:
- AWS Outposts
- Azure Stack
- Google Anthos
```

---

## 💰 비용 모델

### 온디맨드 (On-Demand)
```
특징: 사용한 만큼 과금
가격: 정가
용도: 테스트, 가변 워크로드
```

### 예약 인스턴스 (Reserved Instance)
```
특징: 1년 또는 3년 약정
할인율: 30-70%
용도: 안정적 워크로드
```

### 스팟 인스턴스 (Spot Instance)
```
특징: 유휴 용량 경매
할인율: 최대 90%
단점: 언제든 회수 가능
용도: Batch 작업, 비중요 워크로드
```

---

## 🔒 Zone별 배치

| Zone | 배치 | 서비스 예시 |
|------|------|-------------|
| **Zone 1** | Common | EC2 (Public Subnet) |
| **Zone 2** | Very Common | EC2 (Private Subnet, App) |
| **Zone 3** | Very Common | RDS (Private Subnet, DB) |
| **Zone 4** | Common | Bastion Host, VPN Gateway |

---

## ⚡ 실무 고려사항

### 1. 멀티 클라우드 전략
```yaml
이유:
- 벤더 종속성 회피
- 최적 서비스 선택
- 재해 복구

과제:
- 복잡한 관리
- 네트워크 비용
- 기술 스택 통일
```

### 2. 비용 최적화
```yaml
방법:
- 우선 예약 인스턴스 활용
- 미사용 리소스 정리
- Auto Scaling
- Spot Instance 활용
- Savings Plans
```

---

## 🔗 관련 문서

- [Layer 3 정의](../00_Layer_3_정의.md)
- [Virtual Machine](../02_Virtual_Machine/00_Virtual_Machine_정의.md)
- [Auto Scaling](../05_Auto_Scaling/00_Auto_Scaling_정의.md)

---

**문서 끝**
