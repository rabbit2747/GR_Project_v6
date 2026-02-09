# Virtual Machine (가상 머신)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Virtual Machine |
| **한글명** | 가상 머신 |
| **Layer** | Layer 3 (Computing Infrastructure) |
| **분류** | Virtualized Compute |
| **Function Tag (Primary)** | C2.1 (VM Instance) |
| **Function Tag (Secondary)** | 없음 |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

가상 머신은 **물리 서버 위에서 독립적으로 실행되는 논리적 컴퓨터**입니다.

### 핵심 특징

- 하이퍼바이저를 통한 하드웨어 추상화
- 격리된 실행 환경
- 독립적인 OS 실행
- 리소스 할당 및 제한

---

## 🏗️ VM 유형

### AWS EC2 인스턴스 패밀리

| 패밀리 | 용도 | 특징 | 예시 |
|--------|------|------|------|
| **T3** | 범용 | 버스트 가능 | 웹 서버, 개발 |
| **M5** | 범용 | 균형잡힌 성능 | 애플리케이션 서버 |
| **C5** | 컴퓨팅 최적화 | 높은 CPU | 배치 처리, HPC |
| **R5** | 메모리 최적화 | 높은 RAM | 데이터베이스, 캐시 |
| **I3** | 스토리지 최적화 | NVMe SSD | NoSQL, 빅데이터 |
| **G4** | GPU | ML/AI 추론 | 머신러닝, 렌더링 |
| **P3** | GPU | ML/AI 훈련 | 딥러닝 훈련 |

---

## 💾 VM 구성요소

### vCPU (Virtual CPU)
```
1 vCPU = 물리 CPU 코어의 1 스레드

성능 비교:
- Dedicated: 물리 코어 전용
- Shared: 다른 VM과 공유
- Burstable (T 시리즈): 크레딧 기반
```

### Memory
```
할당: 고정 크기
Hot-Add: 일부 하이퍼바이저 지원
Ballooning: 동적 메모리 조정
```

### Storage
```
Ephemeral (임시):
  - 인스턴스 종료 시 삭제
  - 빠른 I/O
  - 임시 데이터, 캐시

Persistent (영구):
  - EBS, Azure Managed Disk
  - 인스턴스 독립적
  - 데이터베이스, 애플리케이션
```

---

## 📊 VM vs Container

| 항목 | VM | Container |
|------|-----|-----------|
| **OS** | 각 VM마다 독립 OS | 호스트 OS 공유 |
| **부팅 시간** | 분 단위 | 초 단위 |
| **리소스** | GB 단위 | MB 단위 |
| **격리** | 완전 격리 | 프로세스 격리 |
| **용도** | 멀티 OS, 레거시 | 마이크로서비스, DevOps |

---

## ⚡ 실무 고려사항

### 1. 적절한 인스턴스 타입 선택
```yaml
워크로드 프로파일링:
  - CPU 사용률
  - 메모리 요구사항
  - 네트워크 대역폭
  - Storage IOPS

권장사항:
  웹 서버: t3.medium (2 vCPU, 4GB)
  앱 서버: m5.large (2 vCPU, 8GB)
  DB 서버: r5.xlarge (4 vCPU, 32GB)
```

### 2. 비용 최적화
```yaml
Right-Sizing:
  - CloudWatch 메트릭 분석
  - 과도한 리소스 축소
  - Compute Optimizer 활용

Reserved Instance:
  - 1년/3년 약정 시 최대 72% 절감
```

---

## 🔗 관련 문서

- [Layer 3 정의](../00_Layer_3_정의.md)
- [Hypervisor](../03_Hypervisor/00_Hypervisor_정의.md)
- [Cloud Platform](../01_Cloud_Platform/00_Cloud_Platform_정의.md)

---

**문서 끝**
