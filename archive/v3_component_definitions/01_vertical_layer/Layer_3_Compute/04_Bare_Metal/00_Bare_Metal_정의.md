# Bare Metal (베어메탈 서버)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Bare Metal |
| **한글명** | 베어메탈 서버 |
| **Layer** | Layer 3 (Computing Infrastructure) |
| **분류** | Physical Compute |
| **Function Tag (Primary)** | C4.1 (Dedicated Server) |
| **Function Tag (Secondary)** | C4.2 (Bare Metal Cloud) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

Bare Metal 서버는 **가상화 레이어 없이 물리 하드웨어에서 직접 실행되는 전용 서버**입니다.

### 핵심 특징

1. **최고 성능**
   - 하이퍼바이저 오버헤드 없음
   - 100% 리소스 활용
   - 예측 가능한 성능

2. **완전한 통제**
   - 커널 레벨 접근
   - 하드웨어 직접 제어
   - 커스텀 구성 가능

3. **격리 및 보안**
   - 물리적 격리
   - Noisy Neighbor 문제 없음
   - 규정 준수 용이

---

## 🏗️ Bare Metal 유형

### 1. Traditional Dedicated Server (전통적 전용 서버)

```
특징:
- 데이터센터 코로케이션
- 장기 계약 (1-3년)
- 프로비저닝: 수일~수주

용도:
- 엔터프라이즈 워크로드
- 데이터베이스 서버
- HPC (고성능 컴퓨팅)
```

**주요 제공업체**:

| 제공업체 | 위치 | 가격 (월) | 프로비저닝 |
|---------|------|----------|-----------|
| **코로케이션** | 자체 장비 | ~$100 (전력+공간) | 즉시 (장비 준비 시) |
| **OVH** | 글로벌 | $50~$500 | 2-4일 |
| **Hetzner** | 독일/핀란드 | €30~€300 | 24시간 |

---

### 2. Bare Metal Cloud (클라우드 베어메탈)

```
특징:
- 온디맨드 프로비저닝
- 시간/월 단위 과금
- 프로비저닝: 10분~1시간

용도:
- 고성능 워크로드
- 빅데이터 처리
- 단기 프로젝트
```

**주요 제공업체**:

| 제공업체 | 인스턴스 예시 | 가격 | 프로비저닝 |
|---------|-------------|------|-----------|
| **AWS EC2 Bare Metal** | c5.metal (96 vCPU) | $4.08/hour | 10분 |
| **IBM Cloud Bare Metal** | 다양한 구성 | $0.50~$5/hour | 4-6시간 |
| **Packet (Equinix Metal)** | c3.small.x86 | $0.50/hour | 10분 |
| **Oracle Cloud** | BM.Standard2.52 | $3.40/hour | 15분 |

---

## 📊 Bare Metal vs Virtual Machine

### 성능 비교

| 항목 | Bare Metal | Virtual Machine |
|------|-----------|----------------|
| **CPU 성능** | 100% | 95-98% |
| **메모리 성능** | 100% | 95-97% |
| **I/O 성능** | 100% | 85-95% |
| **네트워크** | 100% | 90-95% |
| **지연시간** | 최소 | 약간 높음 |
| **일관성** | 매우 높음 | 보통 (Noisy Neighbor) |

---

### 특성 비교

| 특성 | Bare Metal | VM |
|------|-----------|-----|
| **프로비저닝** | 10분~수일 | 초~분 |
| **비용** | 높음 (고정) | 낮음 (유연) |
| **확장성** | 제한적 | 높음 |
| **유연성** | 낮음 | 높음 |
| **성능** | 최고 | 우수 |
| **격리** | 완전 | 논리적 |
| **관리** | 복잡 | 간편 |

---

## 💻 Bare Metal 구성 예시

### AWS EC2 Bare Metal

**c5.metal** (컴퓨팅 최적화):
```yaml
CPU:
  - Intel Xeon Platinum 8275CL
  - 96 vCPUs (48 physical cores)
  - 3.6 GHz (Turbo)

Memory:
  - 192 GB

Storage:
  - EBS 전용 (25 Gbps)

Network:
  - 25 Gbps

가격:
  - $4.08/hour ($3,000/month)

용도:
  - HPC, 빅데이터, 머신러닝
```

**i3.metal** (스토리지 최적화):
```yaml
CPU:
  - Intel Xeon E5-2686 v4
  - 72 vCPUs (36 cores)

Memory:
  - 512 GB

Storage:
  - 8x 1.9TB NVMe SSD (15.2TB)
  - 높은 I/O 성능

Network:
  - 25 Gbps

가격:
  - $4.992/hour ($3,650/month)

용도:
  - NoSQL, 데이터베이스, 빅데이터
```

---

### IBM Cloud Bare Metal

**일반 구성**:
```yaml
CPU 옵션:
  - Intel Xeon 4210 (10 cores)
  - Intel Xeon 6248 (20 cores)
  - AMD EPYC 7542 (32 cores)

Memory 옵션:
  - 64GB ~ 1.5TB

Storage 옵션:
  - SATA SSD (960GB ~ 7.68TB)
  - NVMe SSD (960GB ~ 15.36TB)
  - RAID 구성

Network:
  - 1Gbps ~ 10Gbps

OS:
  - CentOS, Ubuntu, Red Hat, Windows

가격:
  - $150~$2,000/month (구성에 따라)
```

---

## 🚀 Use Case (사용 사례)

### 1. 데이터베이스 서버

```yaml
요구사항:
  - 예측 가능한 고성능
  - 낮은 지연시간
  - 일관된 I/O

권장 구성:
  - CPU: 32+ cores
  - Memory: 256GB+
  - Storage: NVMe SSD (RAID 10)

예시:
  - Oracle RAC
  - MySQL (대용량)
  - PostgreSQL (분석 워크로드)
```

---

### 2. HPC (High Performance Computing)

```yaml
요구사항:
  - 최대 CPU 성능
  - 낮은 네트워크 지연시간
  - 병렬 처리

권장 구성:
  - CPU: 96+ cores (고클럭)
  - Memory: 384GB+
  - Network: 25Gbps+ (InfiniBand)

예시:
  - 과학 시뮬레이션
  - 기상 예측
  - 유전자 분석
```

---

### 3. 빅데이터 처리

```yaml
요구사항:
  - 높은 스토리지 I/O
  - 대용량 메모리
  - 빠른 네트워크

권장 구성:
  - CPU: 48+ cores
  - Memory: 512GB+
  - Storage: 다중 NVMe SSD (TB급)

예시:
  - Hadoop/Spark 클러스터
  - Elasticsearch
  - Cassandra
```

---

### 4. 규정 준수 (Compliance)

```yaml
요구사항:
  - 물리적 격리
  - 전용 하드웨어
  - 감사 추적

권장 구성:
  - Single-tenant
  - Dedicated network
  - Hardware encryption

예시:
  - 금융 시스템 (PCI-DSS)
  - 의료 시스템 (HIPAA)
  - 정부 시스템
```

---

## 🔧 Bare Metal 관리

### 프로비저닝

**전통적 방식** (수동):
```bash
1. 하드웨어 주문 → 2-4주
2. 데이터센터 설치
3. OS 설치 (PXE Boot, ISO)
4. 네트워크 설정
5. 애플리케이션 배포

총 소요 시간: 2-6주
```

**클라우드 방식** (자동화):
```bash
1. API 호출 또는 콘솔
2. 하드웨어 할당
3. OS 자동 설치
4. 네트워크 자동 설정
5. 배포 준비 완료

총 소요 시간: 10분~6시간
```

---

### Infrastructure as Code (IaC)

**Terraform 예시** (AWS):
```hcl
resource "aws_instance" "bare_metal" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "c5.metal"

  root_block_device {
    volume_size = 100
    volume_type = "gp3"
    iops        = 3000
  }

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = 500
    volume_type = "io2"
    iops        = 10000
  }

  tags = {
    Name = "Database-BareMetal"
    Type = "Production"
  }
}
```

---

### 모니터링

```yaml
하드웨어 모니터링:
  - CPU 온도
  - 메모리 오류 (ECC)
  - 디스크 SMART
  - 네트워크 오류

성능 모니터링:
  - CPU 사용률
  - 메모리 사용률
  - Disk I/O (IOPS, latency)
  - Network throughput

도구:
  - Prometheus + Node Exporter
  - Zabbix
  - Nagios
  - IPMI (하드웨어 레벨)
```

---

## 💰 비용 분석

### TCO (Total Cost of Ownership) 비교

**3년 기준** (1대 서버):

```yaml
Bare Metal (자체 구매):
  초기 비용: $10,000 (서버)
  코로케이션: $1,200/year ($3,600)
  전력: $500/year ($1,500)
  유지보수: $1,000/year ($3,000)
  총 비용: $18,100
  월 평균: $503

Bare Metal Cloud (c5.metal):
  시간당: $4.08
  월: $3,000
  3년: $108,000

VM (c5.9xlarge - 절반 성능):
  시간당: $1.53
  월: $1,120
  3년: $40,320
```

**선택 기준**:
- 안정적 워크로드 + 장기 사용 → 자체 구매
- 변동적 워크로드 → Bare Metal Cloud
- 성능 요구사항 중간 → VM

---

## 🔒 Zone별 배치

| Zone | 배치 빈도 | 용도 |
|------|----------|------|
| **Zone 2** | Uncommon | 고성능 App 서버 |
| **Zone 3** | Common | 데이터베이스 서버 |
| **Zone 4** | Rare | 관리 서버 |

---

## ⚡ 실무 고려사항

### 1. Bare Metal vs VM 선택 기준

```yaml
Bare Metal 선택:
  - 최대 성능 필요
  - 예측 가능한 성능 필요
  - 물리적 격리 필요
  - 라이선스 제약 (per-core)

VM 선택:
  - 빠른 프로비저닝 필요
  - 유연한 확장 필요
  - 비용 최적화 우선
  - 다중 워크로드
```

---

### 2. 하이브리드 접근

```yaml
전략:
  데이터베이스 (Tier 1):
    - Bare Metal
    - 최고 성능, 안정성

애플리케이션 (Tier 2):
    - VM
    - 자동 확장, 유연성

개발/테스트:
    - VM
    - 비용 효율
```

---

### 3. 마이그레이션 고려사항

```yaml
VM → Bare Metal:
  이유: 성능 문제, Noisy Neighbor
  과제: 프로비저닝 시간, 비용 증가
  솔루션: Bare Metal Cloud 활용

Bare Metal → VM:
  이유: 비용 절감, 유연성
  과제: 성능 저하 가능
  솔루션: 성능 테스트, 점진적 마이그레이션
```

---

## 🔗 관련 문서

- [Layer 3 정의](../00_Layer_3_정의.md)
- [Virtual Machine](../02_Virtual_Machine/00_Virtual_Machine_정의.md)
- [Hypervisor](../03_Hypervisor/00_Hypervisor_정의.md)

---

**문서 끝**
