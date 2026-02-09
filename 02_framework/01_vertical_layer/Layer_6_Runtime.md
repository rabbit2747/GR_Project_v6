# Layer 6: Application Runtime (애플리케이션 런타임)

## 📋 문서 정보

**Layer**: 6 - Application Runtime
**영문명**: Application Runtime
**한글명**: 애플리케이션 런타임
**위치**: 중상단 계층
**목적**: 애플리케이션 실행 환경 제공
**작성일**: 2025-01-20

---

## 🎯 Layer 정의

### 개요

**Layer 6 (Application Runtime)**는 애플리케이션이 **실행되는 환경**을 제공하는 계층입니다.

```yaml
핵심 역할:
  - Container 실행
  - Orchestration (Kubernetes)
  - Message Queue
  - Service Mesh
```

---

## 📦 Runtime 구성요소

### 1. Container Runtime

**대표 런타임**:
```yaml
Docker:
  - 가장 인기 있는 Container Runtime
  - docker run, docker-compose

containerd:
  - CNCF 프로젝트
  - Kubernetes CRI 지원
  - Docker Desktop 내부 엔진

CRI-O:
  - Kubernetes 전용
  - Lightweight
```

**Function Tags**:
- Primary: `R5.1` (Container Runtime)

---

### 2. Container Orchestration

**대표 도구**:
```yaml
Kubernetes:
  - 사실상 표준
  - Self-hosted (kubeadm, kops)
  - Managed (EKS, AKS, GKE)

Docker Swarm:
  - Docker 내장
  - 간단한 설정

AWS ECS/ECS:
  - AWS 전용
  - Fargate (Serverless)
```

**Function Tags**:
- Primary: `R5.2` (Container Orchestration)
- Secondary: `R3.2` (Auto Scaling), `M1.1` (Self-Healing)

---

### 3. Message Queue

**대표 MQ**:
```yaml
Apache Kafka:
  - 대용량 이벤트 스트리밍
  - Pub/Sub 모델

RabbitMQ:
  - AMQP 프로토콜
  - 다양한 Exchange 패턴

AWS SQS:
  - Fully Managed
  - Standard / FIFO Queue

Redis Streams:
  - Redis 5.0+
  - 경량 메시지 큐
```

**Function Tags**:
- Primary: `D3.3` (Event Streaming), `D3.1` (Message Queue)
- Interface: `I3.1` (AMQP), `I3.2` (Kafka Protocol)

---

### 4. Service Mesh

**대표 Service Mesh**:
```yaml
Istio:
  - 가장 기능 풍부
  - Envoy Proxy 기반
  - mTLS, Traffic Management

Linkerd:
  - 경량
  - Rust 기반 Proxy
  - 간단한 설정

Consul Connect:
  - HashiCorp
  - Service Discovery + Mesh
```

**Function Tags**:
- Primary: `R5.3` (Service Mesh)
- Control: `S5.3` (mTLS), `M2.1` (Distributed Tracing)

---

## 📊 실전 예시

### 예시: Kubernetes + Kafka

```yaml
Layer 6 (Runtime):
  Kubernetes (EKS):
    - Deployment: Backend API × 10 Pods
    - Auto Scaling: HPA (CPU 70%)
    - Service Mesh: Istio (mTLS)

  Kafka:
    - 3 Brokers
    - Topic: order-events
    - Retention: 7 days

  Redis:
    - Session Store
    - Rate Limiting
```

---

## ✅ 체크리스트

- [ ] Kubernetes 클러스터 HA 구성 (Multi-AZ)
- [ ] HPA (Horizontal Pod Autoscaler) 설정
- [ ] Service Mesh mTLS 활성화
- [ ] Kafka Replication Factor ≥ 3

---

## 🔗 관련 문서

- [Layer 5: Data Services](Layer_5_Data.md)
- [Layer 7: Application & AI](Layer_7_Application_AI.md)

---

**문서 끝**
