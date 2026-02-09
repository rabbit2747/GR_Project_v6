# Hypervisor (하이퍼바이저)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Hypervisor |
| **한글명** | 하이퍼바이저 |
| **Layer** | Layer 3 (Computing Infrastructure) |
| **분류** | Virtualization Platform |
| **Function Tag (Primary)** | C3.1 (Type 1 Hypervisor) |
| **Function Tag (Secondary)** | C3.2 (Type 2 Hypervisor) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

하이퍼바이저는 **물리 서버에서 여러 개의 가상 머신을 생성하고 관리하는 가상화 소프트웨어**입니다.

### 핵심 기능

1. **하드웨어 추상화**
   - CPU, Memory, Storage, Network 가상화
   - 리소스 할당 및 격리
   - 하드웨어 독립성 제공

2. **VM 관리**
   - VM 생성, 삭제, 복제
   - 리소스 동적 할당
   - 스냅샷 및 백업

3. **고급 기능**
   - Live Migration (vMotion)
   - High Availability (HA)
   - Resource Pooling

---

## 🏗️ Hypervisor 유형

### Type 1 (Bare-Metal Hypervisor)

```
직접 하드웨어 위에서 실행

[VM 1] [VM 2] [VM 3]
    ↓      ↓      ↓
[Hypervisor (Type 1)]
    ↓
[Physical Hardware]

특징:
- 높은 성능
- 낮은 오버헤드
- 프로덕션 환경
```

**주요 제품**:

| 제품 | 제공사 | 시장 점유율 | 용도 |
|------|--------|------------|------|
| **VMware ESXi** | VMware | 80% | 엔터프라이즈 |
| **KVM** | Red Hat | 15% | 오픈소스, 클라우드 |
| **Hyper-V** | Microsoft | 3% | Windows 환경 |
| **Xen** | Citrix | 2% | 클라우드 (AWS) |

---

### Type 2 (Hosted Hypervisor)

```
OS 위에서 애플리케이션으로 실행

[VM 1] [VM 2]
    ↓      ↓
[Hypervisor (Type 2)]
    ↓
[Host OS (Windows/macOS/Linux)]
    ↓
[Physical Hardware]

특징:
- 설치 간편
- 성능 오버헤드
- 개발/테스트 환경
```

**주요 제품**:

| 제품 | 제공사 | 가격 | 용도 |
|------|--------|------|------|
| **VMware Workstation** | VMware | $199 | 개발/테스트 |
| **VirtualBox** | Oracle | 무료 | 개인용 |
| **Parallels Desktop** | Parallels | $99/year | macOS 가상화 |
| **QEMU** | 오픈소스 | 무료 | 개발 |

---

## 🚀 주요 Hypervisor 상세

### 1. VMware ESXi

**특징**:
- 업계 표준 Type 1 하이퍼바이저
- vSphere 관리 플랫폼 통합
- 최고 수준의 안정성

**라이선스**:
```yaml
ESXi Free:
  - 무료
  - 제한: vMotion 없음, API 제한

vSphere Essentials:
  - $560 per CPU
  - 3 hosts까지
  - vMotion, HA 지원

vSphere Standard:
  - $995 per CPU
  - vCenter 포함
  - 전체 기능
```

**고급 기능**:

**vMotion** (Live Migration):
```
VM을 중단 없이 다른 호스트로 이동

Before:
[VM-A] [VM-B]    [VM-C]
   ↓       ↓        ↓
[Host 1]        [Host 2]

After (vMotion):
[VM-B]    [VM-A] [VM-C]
   ↓        ↓       ↓
[Host 1]        [Host 2]

다운타임: 0초
네트워크: 10Gbps 권장
```

**DRS** (Distributed Resource Scheduler):
```yaml
자동 부하 분산:
  - CPU/메모리 사용률 모니터링
  - 불균형 감지 시 자동 vMotion
  - 부하 균등화
```

**HA** (High Availability):
```yaml
장애 조치:
  - Host 장애 감지
  - VM 자동 재시작 (다른 호스트)
  - RTO: 1-5분
```

---

### 2. KVM (Kernel-based Virtual Machine)

**특징**:
- Linux 커널 내장 (커널 2.6.20+)
- 오픈소스 (무료)
- AWS, GCP 기반 기술

**설치 및 설정** (Ubuntu):
```bash
# KVM 설치
sudo apt update
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils

# 사용자 권한 추가
sudo usermod -aG libvirt $USER
sudo usermod -aG kvm $USER

# VM 생성
virt-install \
  --name vm1 \
  --ram 4096 \
  --vcpus 2 \
  --disk path=/var/lib/libvirt/images/vm1.qcow2,size=20 \
  --os-type linux \
  --os-variant ubuntu20.04 \
  --network bridge=virbr0 \
  --graphics vnc,listen=0.0.0.0 \
  --cdrom /path/to/ubuntu.iso
```

**관리 도구**:
```yaml
CLI:
  - virsh: VM 관리
  - virt-manager: GUI 관리 도구

웹 UI:
  - Proxmox VE (무료)
  - oVirt (Red Hat)

클라우드:
  - OpenStack (KVM 기반)
```

---

### 3. Microsoft Hyper-V

**특징**:
- Windows Server 내장
- Azure 기반 기술
- Windows VM 최적화

**에디션**:
```yaml
Hyper-V Server (무료):
  - Core 설치만
  - GUI 없음
  - 제한 없음

Windows Server Standard:
  - $972 (16 cores)
  - 2 VM 라이선스 포함

Windows Server Datacenter:
  - $6,155 (16 cores)
  - 무제한 VM
```

**Live Migration 설정**:
```powershell
# Live Migration 활성화
Enable-VMMigration

# 네트워크 설정
Add-VMMigrationNetwork 10.0.1.0/24

# VM 이동
Move-VM -Name "VM1" -DestinationHost "Host2" -IncludeStorage
```

---

### 4. Xen Hypervisor

**특징**:
- 오픈소스 Type 1
- AWS EC2 기반 (초기)
- Paravirtualization 지원

**아키텍처**:
```
[VM (DomU)] [VM (DomU)]
       ↓           ↓
   [Dom0 (관리 VM)]
       ↓
   [Xen Hypervisor]
       ↓
   [Hardware]

Dom0: 관리 도메인 (특권)
DomU: 게스트 VM
```

**가상화 모드**:
```yaml
Paravirtualization (PV):
  - Guest OS 수정 필요
  - 높은 성능
  - Linux 최적화

Hardware Virtual Machine (HVM):
  - 수정 불필요
  - 하드웨어 가상화 지원
  - Windows 지원
```

---

## 📊 성능 비교

### 오버헤드 비교

| 하이퍼바이저 | CPU 오버헤드 | 메모리 오버헤드 | I/O 성능 |
|-------------|-------------|---------------|---------|
| **VMware ESXi** | 2-5% | 3-6% | 95% |
| **KVM** | 2-4% | 2-5% | 93% |
| **Hyper-V** | 3-6% | 4-7% | 92% |
| **Xen (HVM)** | 3-5% | 3-6% | 93% |
| **Xen (PV)** | 1-3% | 2-4% | 96% |

---

### VM 밀도 (64GB 물리 서버 기준)

```yaml
VMware ESXi:
  - 소형 VM (2GB): 30개
  - 중형 VM (4GB): 15개
  - 대형 VM (8GB): 7개

KVM:
  - 소형 VM (2GB): 31개
  - 중형 VM (4GB): 15개
  - 대형 VM (8GB): 7개
```

---

## 🔧 고급 기능

### 1. Live Migration

**작동 원리**:
```
1. Pre-copy Phase
   - 메모리 페이지를 대상 호스트로 복사
   - VM은 계속 실행 중

2. Iterative Copy
   - 변경된 페이지만 반복 복사
   - Dirty Page Tracking

3. Stop-and-Copy
   - VM 일시 정지 (100ms)
   - 남은 메모리 복사
   - 대상 호스트에서 재개

다운타임: 50-200ms
```

**요구사항**:
```yaml
네트워크:
  - 1Gbps 이상 (10Gbps 권장)
  - 낮은 지연시간 (<1ms)

스토리지:
  - 공유 스토리지 (SAN, NFS)
  - 또는 Storage vMotion

CPU:
  - 동일한 CPU 벤더 (Intel ↔ AMD 불가)
  - EVC (Enhanced vMotion Compatibility) 사용
```

---

### 2. High Availability (HA)

**VMware HA**:
```yaml
작동 방식:
  1. Host Heartbeat 모니터링 (15초 간격)
  2. 장애 감지 (네트워크, 스토리지, 하드웨어)
  3. VM 재시작 우선순위
     - High: 즉시 재시작
     - Medium: 1분 대기
     - Low: 5분 대기

RTO (Recovery Time Objective):
  - 자동 재시작: 1-5분
  - 다운타임: VM 부팅 시간
```

---

### 3. 스냅샷

```yaml
스냅샷 생성:
  - VM 상태 저장 (메모리, 디스크, 설정)
  - 변경사항은 Delta 파일에 저장
  - 롤백 가능

성능 영향:
  - 스냅샷 1개: 2-5% 느림
  - 스냅샷 3개 이상: 10-20% 느림
  - 장기 사용 권장 안 함 (백업용)

권장사항:
  - 24시간 이내 삭제
  - 프로덕션: 백업 대신 스냅샷 사용 금지
  - 테스트: 변경 전 스냅샷 생성
```

---

## 🔒 Zone별 배치

| Zone | 배치 | 하이퍼바이저 예시 |
|------|------|-------------------|
| **Zone 2** | Very Common | ESXi (App VM Host) |
| **Zone 3** | Very Common | ESXi (DB VM Host) |
| **Zone 4** | Common | ESXi (관리 VM) |

---

## ⚡ 실무 고려사항

### 1. Hypervisor 선택 기준

```yaml
VMware ESXi:
  장점: 안정성, 풍부한 기능, 엔터프라이즈 지원
  단점: 높은 라이선스 비용
  선택: 예산 충분, 안정성 최우선

KVM:
  장점: 무료, 높은 성능, 클라우드 표준
  단점: 관리 도구 부족, 기술 지원 제한
  선택: 예산 제한, 클라우드 환경

Hyper-V:
  장점: Windows 통합, 저렴한 비용
  단점: Windows 종속성, 제한적 기능
  선택: Windows 환경, Microsoft 생태계
```

---

### 2. 리소스 오버커밋

```yaml
CPU 오버커밋:
  - 권장: 1:2 ~ 1:4 (물리 1코어 당 2-4 vCPU)
  - 공격적: 1:8 (웹 서버)
  - 보수적: 1:1 (데이터베이스)

메모리 오버커밋:
  - 권장: 1.0 ~ 1.2 (20% 오버커밋)
  - Memory Ballooning 활용
  - Transparent Page Sharing (TPS)

주의사항:
  - 과도한 오버커밋은 성능 저하
  - 메모리 스왑 발생 방지
  - Reservation 설정 (중요 VM)
```

---

### 3. 모니터링

```yaml
주요 메트릭:
  - CPU Ready Time (<5%)
  - Memory Ballooning (<5%)
  - Storage Latency (<20ms)
  - Network Throughput

알림:
  - CPU Ready > 10%
  - Memory Swapping 발생
  - Host Disconnected
  - VM Migration Failed
```

---

## 🔗 관련 문서

- [Layer 3 정의](../00_Layer_3_정의.md)
- [Virtual Machine](../02_Virtual_Machine/00_Virtual_Machine_정의.md)
- [Bare Metal](../04_Bare_Metal/00_Bare_Metal_정의.md)

---

**문서 끝**
