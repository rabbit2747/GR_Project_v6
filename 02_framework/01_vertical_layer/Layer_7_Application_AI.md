# Layer 7: Application & AI (애플리케이션 & AI)

## 📋 문서 정보

**Layer**: 7 - Application & AI
**영문명**: Application & AI
**한글명**: 애플리케이션 & AI
**위치**: 최상단 계층
**목적**: 비즈니스 로직 구현 + AI/ML 워크로드 실행
**작성일**: 2025-01-20
**v2.0 확장**: ✅ AI/ML 워크로드 추가

---

## 🎯 Layer 정의

### 개요

**Layer 7 (Application & AI)**는 **사용자와 직접 상호작용**하거나 **AI/ML 추론**을 수행하는 최상위 계층입니다.

### v2.0 주요 변경

```yaml
기존 (v1.0):
  - 전통적 애플리케이션만 포함
  - Frontend, Backend API, Mobile

v2.0 확장:
  - AI/ML 워크로드 통합
  - LLM 추론 엔진
  - Vector Search (RAG)
  - AI Agent
  - Fine-tuning Pipeline
```

---

## 📦 Application & AI 구성요소

### 1. 전통적 애플리케이션

#### Frontend (프론트엔드)

**대표 프레임워크**:
```yaml
React Ecosystem:
  - React (라이브러리)
  - Next.js (SSR Framework)
  - Create React App

Vue Ecosystem:
  - Vue.js 3 (Composition API)
  - Nuxt.js (SSR Framework)

Angular:
  - Angular 17+ (Google)
  - TypeScript 기반

기타:
  - Svelte, SvelteKit
  - Solid.js
```

**Function Tags**:
- Primary: `A1.6` (Frontend Application)
- Tech Stack: `T1.1` (JavaScript), `T1.2` (TypeScript)

---

#### Backend API

**대표 프레임워크**:
```yaml
Node.js:
  - Express.js
  - Fastify
  - NestJS (TypeScript)

Python:
  - FastAPI (추천)
  - Django, Django REST Framework
  - Flask

Java:
  - Spring Boot
  - Quarkus, Micronaut

Go:
  - Gin, Echo
  - Fiber

.NET:
  - ASP.NET Core
```

**Function Tags**:
- Primary: `A1.5` (Backend API Server)
- Interface: `I1.1` (HTTP/REST), `I1.2` (GraphQL), `I1.3` (gRPC)

---

#### Mobile App

**대표 프레임워크**:
```yaml
Cross-Platform:
  - Flutter (Dart)
  - React Native
  - Ionic, Capacitor

Native:
  - iOS: Swift, SwiftUI
  - Android: Kotlin, Jetpack Compose
```

**Function Tags**:
- Primary: `A1.7` (Mobile Application)

---

### 2. AI/ML 워크로드 (v2.0 신규)

#### LLM 추론 엔진

**Self-hosted LLM**:
```yaml
Inference Server:
  - vLLM (고성능 LLM 서빙)
  - Text Generation Inference (Hugging Face)
  - LM Studio (로컬 개발)
  - Ollama (로컬 LLM)

Model:
  - Llama 3.1 (Meta)
  - Mistral 7B
  - Gemma 2 (Google)
  - Qwen 2 (Alibaba)

GPU 요구사항:
  - 7B Model: RTX 3090 (24GB) 이상
  - 70B Model: A100 (80GB) × 2 이상
```

**Function Tags**:
- Primary: `A7.1` (LLM Inference)
- Tech Stack: `T1.3` (Python), `T5.1` (PyTorch), `T5.2` (CUDA)

**Zone 배치**: Zone 2 (Application)

---

#### Vector Search & RAG

**RAG 시스템 구성**:
```yaml
Retrieval:
  - Vector DB (Pinecone, Weaviate, pgvector)
  - Embedding Model (OpenAI ada-002, Cohere)

Augmentation:
  - Prompt Template 구성
  - Context Injection

Generation:
  - LLM (GPT-4, Claude, Self-hosted)
```

**Function Tags**:
- Primary: `A7.2` (RAG System)
- Secondary: `D5.2` (Vector Search), `A7.1` (LLM Inference)

---

#### AI Agent

**대표 프레임워크**:
```yaml
LangChain:
  - Agent Framework
  - Tool Integration
  - Memory Management

AutoGPT, BabyAGI:
  - Autonomous Agent
  - Goal-driven

CrewAI:
  - Multi-Agent Collaboration
  - Role-based Agent
```

**Function Tags**:
- Primary: `A7.3` (AI Agent)

---

#### Model Serving & Fine-tuning

**Model Serving**:
```yaml
TensorFlow Serving:
  - TensorFlow 모델 서빙

TorchServe:
  - PyTorch 모델 서빙

MLflow:
  - 모델 레지스트리
  - 실험 추적
```

**Fine-tuning Pipeline**:
```yaml
Hugging Face Transformers:
  - Trainer API
  - PEFT (Parameter-Efficient Fine-Tuning)

LoRA (Low-Rank Adaptation):
  - 효율적 Fine-tuning
  - 적은 GPU 메모리

QLoRA:
  - Quantized LoRA
  - 4-bit Quantization
```

**Function Tags**:
- Primary: `A7.4` (Model Serving), `A7.5` (Model Training)

---

#### Prompt Engineering

**대표 도구**:
```yaml
LangSmith:
  - Prompt Monitoring
  - A/B Testing

PromptLayer:
  - Prompt 버전 관리
  - 성능 추적

Weights & Biases:
  - 실험 추적
  - 프롬프트 최적화
```

**Function Tags**:
- Primary: `A7.6` (Prompt Engineering)

---

## 🔒 Security Zone 배치

### Zone 2 (Application Zone)

```yaml
구성요소:
  - Frontend (React, Vue)
  - Backend API (FastAPI, Spring Boot)
  - AI Agent (LangChain)

보안:
  - WAF 경유
  - HTTPS Only
  - API Rate Limiting
```

### Zone 3 (Data Zone) - AI 모델 저장소

```yaml
구성요소:
  - Model Registry (MLflow)
  - Fine-tuned 모델 저장

보안:
  - Zone 2에서만 접근
  - Model Encryption at Rest
```

---

## 🛡️ AI/ML 보안 고려사항

### 1. Prompt Injection 방어

```yaml
공격 유형:
  - Jailbreak (제약 우회)
  - Prompt Leaking (시스템 프롬프트 노출)
  - Data Poisoning (악의적 학습 데이터)

방어:
  - Input Validation (유해 키워드 필터링)
  - Output Filtering (민감 정보 마스킹)
  - Prompt Firewall (LLM Firewall)
```

### 2. Data Privacy

```yaml
원칙:
  - PII 데이터 LLM 전송 금지
  - 익명화 (Anonymization)
  - 차등 프라이버시 (Differential Privacy)

예시:
  ❌ "사용자 홍길동(주민번호: 123456-1234567)의 주문 분석"
  ✅ "사용자 ID U12345의 주문 패턴 분석"
```

### 3. Model Security

```yaml
모델 보호:
  - Model Encryption at Rest
  - Access Control (RBAC)
  - Audit Logging (모델 사용 기록)

공급망 보안:
  - 신뢰된 소스에서만 모델 다운로드
  - Checksum 검증
  - Hugging Face Verified Models
```

---

## 📊 실전 예시

### 예시 1: AI 기반 고객 지원 시스템

```yaml
Layer 7 (Application & AI):
  Frontend:
    - React + Tailwind CSS
    - 실시간 채팅 UI

  Backend API:
    - FastAPI (Python)
    - WebSocket 지원

  AI Agent:
    - LangChain Agent
    - Tools: RAG, Search, Database Query

  RAG System:
    - Embedding: OpenAI ada-002 (Layer 0)
    - Vector DB: pgvector (Layer 5)
    - LLM: GPT-4 (Layer 0) or Self-hosted Llama 3.1

Layer 5 (Data):
  - PostgreSQL + pgvector (고객 문의 이력)
  - Redis (세션 캐시)

Layer 0 (External):
  - OpenAI API (GPT-4, Embeddings)
```

### 예시 2: Self-hosted LLM 추론 서비스

```yaml
Layer 7 (Application & AI):
  LLM Serving:
    - vLLM (Llama 3.1 70B)
    - GPU: A100 80GB × 2
    - Quantization: 4-bit (QLoRA)

  Inference API:
    - FastAPI Wrapper
    - OpenAI-compatible Endpoint

Layer 6 (Runtime):
  - Kubernetes (GPU Node Pool)
  - NVIDIA GPU Operator

Layer 3 (Compute):
  - AWS p4d.24xlarge (A100 × 8)
  - Auto Scaling: Time-based (업무 시간)

Zone 배치: Zone 2 (Application)
```

---

## ✅ 체크리스트

### 전통적 애플리케이션

- [ ] Frontend 번들 사이즈 최적화 (<500KB)
- [ ] Backend API 응답 시간 (<200ms)
- [ ] HTTPS/TLS 1.2+ 적용
- [ ] CORS 정책 설정

### AI/ML 워크로드

- [ ] Prompt Injection 테스트
- [ ] PII 데이터 LLM 전송 검증
- [ ] LLM API 사용량 모니터링 (비용 관리)
- [ ] Model Registry 접근 제어 (RBAC)
- [ ] GPU 리소스 모니터링 (Utilization ≥70%)
- [ ] Vector DB 인덱스 최적화 (Query Latency <100ms)

---

## 🔗 관련 문서

- [차원 1: Deployment Layer 개요](00_차원1_개요.md)
- [Layer 0: External Services](Layer_0_External.md)
- [Layer 5: Data Services](Layer_5_Data.md)
- [Layer 6: Runtime](Layer_6_Runtime.md)

---

## 📞 변경 이력

**v2.0 (2025-01-20)** - AI/ML 워크로드 추가:
- ✅ LLM 추론 엔진 (Self-hosted)
- ✅ Vector Search & RAG
- ✅ AI Agent (LangChain, AutoGPT)
- ✅ Model Serving & Fine-tuning
- ✅ Prompt Engineering
- ✅ AI/ML 보안 고려사항

**v1.0** - 초기 작성:
- 전통적 애플리케이션 (Frontend, Backend, Mobile)

---

**문서 끝**
