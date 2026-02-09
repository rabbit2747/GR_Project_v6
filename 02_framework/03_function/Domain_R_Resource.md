# Domain R: Resource (리소스)

**버전**: v2.0
**최종 수정**: 2025-11-20
**목적**: 컴퓨팅 리소스, 스토리지, 런타임 환경

---

## 1. Domain 개요

### 1.1 정의
Resource Domain은 **컴퓨팅, 스토리지, 메모리** 등 물리적/가상 리소스를 나타냅니다.

### 1.2 v1.0 → v2.0 변경사항
- GPU Resources (R2.3) 추가 (AI/ML 지원)
- Serverless Runtime (R3.3) 추가
- Total tags: 15 → 20+

### 1.3 핵심 목표
1. **효율성**: 리소스 사용 최적화
2. **탄력성**: Auto-scaling
3. **비용 최적화**: Right-sizing

---

## 2. Tag 상세 정의

### R1: Container Runtime

**구성 요소**:
- **R1.1**: Container Runtime (Docker, containerd)
- **R1.2**: Container Registry (Harbor, ECR)
- **R1.3**: Container Scanning (Trivy, Clair)

**Layer/Zone**: L2, Zone 2

**사용 예시**:
```yaml
Container Runtime (Zone 2):
  Tags: [R1.1, R1.2, R1.3, S7.3]
  Runtime: containerd 1.7.0
  Registry: AWS ECR
  Security:
    - Image Scanning: Trivy (R1.3)
    - Vulnerability Threshold: High/Critical → Block
```

---

### R2: Compute Resources

**구성 요소**:
- **R2.1**: Virtual Machines (EC2, Azure VM)
- **R2.2**: Container Orchestration (Kubernetes)
- **R2.3**: GPU Resources (v2.0 신규)
  - NVIDIA A100, V100, T4
  - Use Case: AI/ML training, inference

**Layer/Zone**: L2, Zone 2

**사용 예시**:
```yaml
Kubernetes Cluster (Zone 2):
  Tags: [R2.2, M7.3, N2.1]
  Nodes: 10 (t3.xlarge)
  GPU Nodes: 2 (g5.2xlarge, NVIDIA A10G)
  Auto-scaling:
    - Min: 3, Max: 20
    - Trigger: CPU >70%

GPU Workload (R2.3):
  Use Case: LLM inference (A4.1)
  Model: Llama 2 13B
  GPU: NVIDIA A10G (24GB VRAM)
  Optimization: TensorRT, bfloat16
```

---

### R3: Storage Resources

**구성 요소**:
- **R3.1**: Block Storage (EBS, Persistent Disk)
- **R3.2**: Object Storage (S3, GCS)
- **R3.3**: Serverless Storage (v2.0 신규)
  - AWS Lambda + S3 Triggers
  - Use Case: Image processing, Data transformation

**Layer/Zone**: L3, Zone 3

**사용 예시**:
```yaml
S3 Bucket (Zone 3):
  Tags: [R3.2, S3.2, M7.3]
  Storage Class: S3 Standard (hot data), S3 Glacier (cold data)
  Lifecycle:
    - Transition to Glacier: 30 days
    - Expiration: 365 days
  Encryption: SSE-KMS (S3.2)
  Versioning: Enabled
```

---

### R4: Service Mesh & Runtime

**구성 요소**:
- **R4.1**: Service Mesh (Istio, Linkerd)
- **R4.2**: Sidecar Proxy (Envoy)
- **R4.3**: Service Discovery (Consul, CoreDNS)

**Layer/Zone**: L2, Zone 2

**사용 예시**:
```yaml
Istio Service Mesh (Zone 2):
  Tags: [R4.1, R4.2, N6.1, S3.1]
  Components:
    - Control Plane: istiod
    - Data Plane: Envoy Proxy (R4.2)
  Features:
    - mTLS: Enabled (S3.1)
    - Traffic Management: Canary deployment
    - Observability: Jaeger tracing (M5.1)
```

---

### R5: Message Queue & Event Bus

**구성 요소**:
- **R5.1**: Message Broker (Kafka, RabbitMQ)
- **R5.2**: Event Streaming (Kafka Streams, Flink)
- **R5.3**: Dead Letter Queue (DLQ)

**Layer/Zone**: L2-L3, Zone 2-3

**사용 예시**:
```yaml
Kafka Cluster (Zone 2):
  Tags: [R5.1, R5.2, D4.2]
  Brokers: 3
  Zookeeper: 3 nodes
  Topics:
    - orders: Partitions 10, Retention 7d
    - payments: Partitions 5, Retention 30d
  Stream Processing (R5.2):
    - Fraud detection pipeline
    - Real-time analytics
```

---

## 3. Layer/Zone 연관성

| Layer | Resource Tags | 구성 요소 |
|-------|--------------|----------|
| L2 | R2.2, R4.1 | Kubernetes, Service Mesh |
| L3 | R3.1, R3.2 | EBS, S3 |

---

## 4. CVE 매핑

| CVE ID | Component | Tech Stack Tag | Severity |
|--------|-----------|---------------|----------|
| CVE-2024-11111 | Kubernetes <1.28.0 | T4.4 | High |
| CVE-2024-22222 | Istio <1.18.0 | T4.6 | Medium |
| CVE-2024-33333 | Docker <24.0.0 | T4.1 | Critical |

---

## 5. MITRE ATT&CK 매핑

| Technique | Resource Tag | 탐지/차단 |
|-----------|-------------|----------|
| T1610 (Deploy Container) | R1.3, S7.1 | Container Scanning |
| T1525 (Implant Container Image) | R1.2, R1.3 | Registry Scanning |

---

## 6. 다음 단계

- **Domain P (Platform)**: R2.2와 연동 (Kubernetes)
- **Domain T (Tech Stack)**: R1.1, R2.2와 연동 (버전 관리)

---

**문서 종료**
