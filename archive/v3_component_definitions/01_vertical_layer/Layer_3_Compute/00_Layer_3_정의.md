# Layer 3: Computing Infrastructure (컴퓨팅 인프라)

## 📋 Layer 정보

| 속성 | 값 |
|------|-----|
| **Layer 번호** | 3 |
| **한글명** | 컴퓨팅 인프라 |
| **영문명** | Computing Infrastructure |
| **변경 빈도** | Medium (월 단위) |
| **복잡도** | Medium |
| **다이어그램 위치** | 중하단 (Layer 2 위) |

---

## 🎯 정의

Layer 3은 **애플리케이션 실행을 위한 컴퓨팅 리소스를 제공하는 계층**입니다.

### 핵심 역할

1. **컴퓨팅 리소스 제공**
   - CPU, Memory, Storage
   - 가상화 또는 물리 서버
   - 클라우드 또는 온프레미스

2. **리소스 관리**
   - 자동 확장 (Auto Scaling)
   - 리소스 할당 및 격리
   - 성능 최적화

3. **인프라 추상화**
   - IaaS (Infrastructure as a Service)
   - 가상 머신 관리
   - 컨테이너 호스트

---

## 🏗️ 주요 구성요소

Layer 3은 다음 5개 주요 구성요소로 분류됩니다:

| 번호 | 구성요소 | 설명 | 문서 링크 |
|------|---------|------|-----------|
| 1 | **Cloud Platform** | 클라우드 인프라 (AWS, Azure, GCP) | [상세 문서](01_Cloud_Platform/00_Cloud_Platform_정의.md) |
| 2 | **Virtual Machine** | 가상 머신 | [상세 문서](02_Virtual_Machine/00_Virtual_Machine_정의.md) |
| 3 | **Hypervisor** | 하이퍼바이저 (가상화 레이어) | [상세 문서](03_Hypervisor/00_Hypervisor_정의.md) |
| 4 | **Bare Metal** | 물리 서버 (가상화 없음) | [상세 문서](04_Bare_Metal/00_Bare_Metal_정의.md) |
| 5 | **Auto Scaling** | 자동 확장 | [상세 문서](05_Auto_Scaling/00_Auto_Scaling_정의.md) |

---

## 🔒 Zone별 배치 개요

| Zone | 배치 빈도 | 주요 구성요소 |
|------|----------|---------------|
| **Zone 2** | Very Common | Application VM, Container Host |
| **Zone 3** | Very Common | Database VM, Storage VM |
| **Zone 4** | Common | Management VM, Bastion Host |

---

## 📊 Layer 특성

### 변경 관리

- **변경 빈도**: 월 단위
- **변경 유형**: 스케일링, VM 추가/삭제, 인스턴스 타입 변경
- **영향도**: 중간 (계획된 유지보수)

### 의존성

**하위 Layer 의존**:
- Layer 1 (Physical Infrastructure)
- Layer 2 (Network Infrastructure)

**상위 Layer 의존**:
- Layer 4 (Platform)
- Layer 5 (Data)
- Layer 6 (Runtime)
- Layer 7 (Application)

---

## ⚡ 실무 고려사항

### 1. 클라우드 vs 온프레미스

```yaml
클라우드:
  장점: 빠른 프로비저닝, 확장성, 운영 부담 감소
  단점: 장기 비용, 벤더 종속성

온프레미스:
  장점: 완전한 통제, 예측 가능한 비용
  단점: 초기 투자, 운영 인력 필요
```

### 2. VM vs Bare Metal

```yaml
Virtual Machine:
  장점: 유연성, 격리, 효율적 리소스 활용
  단점: 약간의 성능 오버헤드

Bare Metal:
  장점: 최고 성능, 하드웨어 직접 제어
  단점: 프로비저닝 느림, 유연성 낮음
```

---

## 🔗 관련 문서

- [차원 1 개요](../00_차원1_개요.md)
- [Layer 2: Network Infrastructure](../Layer_2_Network/00_Layer_2_정의.md)
- [Layer 4: Platform Services](../Layer_4_Platform/00_Layer_4_정의.md)

---

**문서 끝**
