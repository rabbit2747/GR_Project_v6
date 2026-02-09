# Layer 3: Computing Infrastructure (컴퓨팅 인프라)

## 📋 문서 정보

**Layer**: 3 - Computing Infrastructure
**영문명**: Computing Infrastructure
**한글명**: 컴퓨팅 인프라
**위치**: 중하단 계층
**목적**: 컴퓨팅 리소스 제공 (VM, Container Node, Serverless)
**작성일**: 2025-01-20

---

## 🎯 Layer 정의

### 개요

**Layer 3 (Computing Infrastructure)**는 애플리케이션 실행을 위한 **컴퓨팅 리소스**를 제공하는 계층입니다.

### 핵심 개념

```yaml
핵심 특징:
  - 가상화된 컴퓨팅 리소스
  - Auto Scaling (자동 확장/축소)
  - 클라우드/온프레미스 모두 지원
  - 변경 빈도: Low (분기 단위)

주요 역할:
  - Virtual Machine 제공
  - Hypervisor 관리
  - Auto Scaling Group 운영
  - 리소스 최적화
```

---

## 📦 Computing Infrastructure 구성요소

### 1. Cloud Platform (클라우드 플랫폼)

**정의**: IaaS(Infrastructure as a Service) 제공 플랫폼

**대표 클라우드**:
```yaml
AWS (Amazon Web Services):
  - EC2 (Elastic Compute Cloud)
  - Auto Scaling Groups
  - ECS/EKS (Container Orchestration)
  - Lambda (Serverless)

Microsoft Azure:
  - Azure VM
  - Azure VM Scale Sets
  - Azure Kubernetes Service (AKS)
  - Azure Functions

Google Cloud Platform (GCP):
  - Compute Engine
  - Google Kubernetes Engine (GKE)
  - Cloud Functions

Oracle Cloud, IBM Cloud, Alibaba Cloud
```

**Function Tags**:
- Primary: `R4.1` (Cloud Infrastructure)
- Secondary: `R3.2` (Auto Scaling)

**Zone 배치**: Zone 2-4 (용도에 따라)

---

### 2. Virtual Machine (가상 머신)

**정의**: 물리 서버 위에서 실행되는 가상화된 서버

**유형**:
```yaml
AWS EC2 Instance Types:
  - t3 (Burstable, 일반 용도)
  - m5 (General Purpose)
  - c5 (Compute Optimized)
  - r5 (Memory Optimized)
  - i3 (Storage Optimized)

Azure VM Series:
  - B-Series (Burstable)
  - D-Series (General Purpose)
  - F-Series (Compute Optimized)

GCP Machine Types:
  - n1-standard (General Purpose)
  - c2 (Compute Optimized)
  - m2 (Memory Optimized)
```

**Function Tags**:
- Primary: `R4.2` (Virtual Machine)
- Tech Stack: `T3.1` (Linux), `T3.2` (Windows)

**Zone 배치**: Zone 2 (Application), Zone 3 (Data), Zone 4 (Management)

---

### 3. Hypervisor (하이퍼바이저)

**정의**: 물리 서버에서 VM을 실행하는 가상화 소프트웨어

**유형**:
```yaml
Type 1 (Bare-Metal):
  - VMware ESXi
  - Microsoft Hyper-V
  - KVM (Kernel-based Virtual Machine)
  - Xen

Type 2 (Hosted):
  - VMware Workstation
  - Oracle VirtualBox
  - Parallels Desktop

Container Runtime (경량 가상화):
  - Docker, containerd
  - CRI-O
```

**Function Tags**:
- Primary: `R4.3` (Hypervisor)
- Tech Stack: `T3.3` (Virtualization)

**Zone 배치**: Layer 3는 인프라 계층 (Zone 개념과 분리)

---

### 4. Bare Metal Server

**정의**: 가상화 없이 직접 운영하는 물리 서버

**사용 사례**:
```yaml
고성능 요구:
  - 데이터베이스 (Oracle RAC)
  - AI/ML Training (GPU 집약)
  - 레거시 애플리케이션 (가상화 비호환)

규제 준수:
  - 금융사 (단일 테넌트 요구)
  - 의료 (HIPAA 컴플라이언스)

클라우드 Bare Metal:
  - AWS EC2 Bare Metal (i3.metal, m5.metal)
  - Azure Dedicated Host
  - IBM Cloud Bare Metal
```

**Function Tags**:
- Primary: `R4.4` (Bare Metal)

**Zone 배치**: Zone 3 (Data), Zone 4 (Management)

---

### 5. Auto Scaling Group

**정의**: 트래픽에 따라 자동으로 인스턴스 수 조정

**대표 기술**:
```yaml
AWS Auto Scaling:
  - Target Tracking (CPU 80% → Scale Out)
  - Step Scaling (단계별 확장)
  - Scheduled Scaling (예측 가능한 트래픽)

Kubernetes HPA (Horizontal Pod Autoscaler):
  - CPU/Memory 기반 자동 확장
  - Custom Metrics (Prometheus 연동)

Azure VM Scale Sets:
  - Instance Count: 0-1000
  - Automatic OS Upgrades
```

**Function Tags**:
- Primary: `R3.2` (Auto Scaling)
- Secondary: `P1.1` (Resource Optimization)

**Zone 배치**: Zone 2 (Application)

---

## 🔒 Security Zone 배치 전략

### Zone 2 (Application Zone)

```yaml
구성요소:
  - Web Server (Frontend, Backend API)
  - Application Server (Tomcat, JBoss)
  - Worker Nodes (비동기 작업 처리)

보안:
  - WAF 경유 트래픽만 허용
  - Outbound Internet Access 제한
  - Security Group (Least Privilege)
```

### Zone 3 (Data Zone)

```yaml
구성요소:
  - Database Server (RDS가 아닌 EC2 기반 DB)
  - Cache Server (Redis, Memcached on EC2)

보안:
  - Zone 2에서만 접근 허용
  - Public IP 비할당
  - Encryption at Rest 필수
```

### Zone 4 (Management Zone)

```yaml
구성요소:
  - Bastion Host (Jump Server)
  - Monitoring Server (Prometheus, Grafana on EC2)
  - CI/CD Runner (Jenkins Agent)

보안:
  - VPN 또는 Private Link 접근만 허용
  - MFA 필수
  - 모든 접속 로그 기록
```

---

## 🛡️ 보안 고려사항

### 1. Instance Security

```yaml
Hardening:
  - OS 최소 설치 (불필요한 패키지 제거)
  - 정기 패치 (자동 업데이트 권장)
  - Host-based Firewall (iptables, firewalld)

Access Control:
  - SSH Key 기반 인증 (비밀번호 비활성화)
  - sudo 권한 최소화
  - 불필요한 포트 비활성화
```

### 2. Network Security

```yaml
Security Group (AWS):
  - Inbound: 필요한 포트만 허용
  - Outbound: Least Privilege
  - Tag 기반 관리

Network ACL:
  - Subnet 레벨 방어
  - Stateless (명시적 Allow/Deny)
```

### 3. Monitoring & Compliance

```yaml
모니터링:
  - CloudWatch, Azure Monitor (리소스 메트릭)
  - OS 레벨 모니터링 (CPU, Memory, Disk)
  - Security Scanning (Nessus, Qualys)

Compliance:
  - CIS Benchmark 준수
  - PCI-DSS 요구사항 (필요 시)
  - 정기 취약점 스캔
```

---

## 📊 실전 예시

### 예시 1: AWS 기반 Auto Scaling 웹 서비스

```yaml
Layer 3 (Computing):
  Region: ap-northeast-2 (서울)
  Availability Zones: 2a, 2c (이중화)

  Auto Scaling Group:
    - Instance Type: t3.medium
    - Min: 2, Max: 10
    - Target Tracking: CPU 70%

  Launch Template:
    - AMI: Amazon Linux 2023
    - User Data: nginx 자동 설치
    - Security Group: sg-web-tier

Zone 배치: Zone 2 (Application)
```

### 예시 2: 온프레미스 VMware 환경

```yaml
Layer 1 (Physical):
  - Dell PowerEdge R750 × 5대

Layer 3 (Computing):
  - VMware ESXi 7.0
  - vCenter Server 관리

  Virtual Machines:
    - Web Tier: 10 VMs (Ubuntu 22.04)
    - App Tier: 8 VMs (RHEL 8)
    - DB Tier: 2 VMs (Oracle Linux 8)

  High Availability:
    - vSphere HA (자동 Failover)
    - DRS (Dynamic Resource Scheduling)
```

---

## ✅ 체크리스트

### 클라우드 환경

- [ ] Region/AZ 이중화 확인
- [ ] Auto Scaling 정책 설정
- [ ] Instance Type 최적화 (Right Sizing)
- [ ] Reserved Instance 또는 Savings Plan 활용
- [ ] Security Group Least Privilege 검증

### 온프레미스 환경

- [ ] Hypervisor 라이선스 관리
- [ ] VM 리소스 할당 최적화
- [ ] HA/DRS 설정 확인
- [ ] Backup 전략 수립

---

## 🔗 관련 문서

- [차원 1: Deployment Layer 개요](00_차원1_개요.md)
- [Layer 2: Network Infrastructure](Layer_2_Network.md)
- [Layer 4: Platform Services](Layer_4_Platform.md)
- [Layer 6: Runtime](Layer_6_Runtime.md)

---

## 📞 변경 이력

**v1.0 (2025-01-20)** - 초기 작성:
- ✅ Computing Infrastructure 정의
- ✅ Cloud Platform, VM, Hypervisor, Auto Scaling 분류
- ✅ Zone별 보안 전략
- ✅ AWS/Azure/GCP 및 온프레미스 예시

---

**문서 끝**
