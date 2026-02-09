# Domain A: Application (애플리케이션)

**버전**: v2.0
**최종 수정**: 2025-11-20
**목적**: 프론트엔드, 백엔드, API, 마이크로서비스, AI/ML 애플리케이션

---

## 1. Domain 개요

### 1.1 정의
Application Domain은 **비즈니스 로직, 사용자 인터페이스, API**를 구현하는 소프트웨어 계층입니다.

### 1.2 v1.0 → v2.0 변경사항
- AI/ML 워크로드 (A4) 추가
- Serverless (A3.3) 추가
- Total tags: 20 → 30+

### 1.3 핵심 목표
1. **사용자 경험**: 직관적이고 빠른 인터페이스
2. **확장성**: 트래픽 증가 대응
3. **유지보수성**: 모듈화, 테스트 가능
4. **보안성**: 입력 검증, 인증/인가

---

## 2. Tag 상세 정의

### A1: Frontend Applications

**구성 요소**:
- **A1.1**: Web Frontend (SPA)
  - Framework: React, Vue.js, Angular
  - Build: Vite, Webpack

- **A1.2**: Mobile Frontend
  - Native: Swift, Kotlin
  - Cross-platform: React Native, Flutter

- **A1.3**: Desktop Applications
  - Electron, Tauri, PWA

**Layer/Zone**: L5, Zone 5

**사용 예시**:
```yaml
Component: React SPA (Zone 5)
Tags: [A1.1, M8.2, I1.1]

Tech Stack:
  - React 18.2, TypeScript 5.0
  - State: Zustand
  - UI: shadcn/ui, Tailwind CSS

Performance:
  - Bundle: <500KB gzipped
  - LCP: <2.5s, FID: <100ms, CLS: <0.1

Security:
  - XSS Prevention: DOMPurify
  - CSRF Token, CSP
```

---

### A2: Backend Applications

**구성 요소**:
- **A2.1**: Monolithic Backend
  - Django, Spring Boot, Express.js
  - MVC Pattern

- **A2.2**: Microservices
  - FastAPI, NestJS, Spring Cloud
  - Communication: REST, gRPC, Message Queue

- **A2.3**: Backend for Frontend (BFF)
  - GraphQL: Apollo Server, Hasura

**Layer/Zone**: L2, Zone 2

**사용 예시**:
```python
# FastAPI Microservice (Zone 2)
# Tags: [A2.2, D2.1, S2.2, M2.1]

from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session

app = FastAPI(title="User Service")

@app.get("/api/users/{user_id}")
async def get_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    # RBAC Check (S2.2.1)
    if not current_user.has_permission("read:users"):
        raise HTTPException(403)

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(404)

    return user
```

---

### A3: API & Integration

**구성 요소**:
- **A3.1**: RESTful API
  - OpenAPI 3.0
  - Versioning: /api/v1/

- **A3.2**: GraphQL API
  - Apollo Server, Hasura
  - Real-time: Subscriptions

- **A3.3**: Serverless Functions (v2.0 신규)
  - AWS Lambda, Vercel Functions
  - Cold Start: <100ms

**Layer/Zone**: L1-L2, Zone 1-2

**사용 예시**:
```yaml
API Gateway: Kong (Zone 1)
Tags: [A3.1, N7.1, S2.2.3]

Routes:
  - /api/v1/users → User Service (Zone 2)
  - /api/v1/orders → Order Service (Zone 2)

Plugins:
  - Rate Limiting: 1000 req/min
  - JWT Authentication
  - CORS
```

---

### A4: AI/ML Applications (v2.0 신규)

**구성 요소**:
- **A4.1**: Model Serving
  - TensorFlow Serving, TorchServe
  - Optimization: ONNX, TensorRT

- **A4.2**: RAG (Retrieval-Augmented Generation)
  - Vector DB: pgvector, Weaviate
  - Embedding: OpenAI, Sentence Transformers
  - LLM: GPT-4, Claude, Llama

- **A4.3**: ML Training & Experimentation
  - Kubeflow, MLflow, W&B
  - GPU: NVIDIA A100, V100

**Layer/Zone**: L2, Zone 2 (Self-hosted), Zone 0-B (External API)

**사용 예시**:
```python
# RAG Chat API (Zone 2)
# Tags: [A4.2, D2.2, S2.2.3]

@app.post("/api/chat")
async def chat(request: ChatRequest):
    # 1. Generate embedding
    embedding = openai.Embedding.create(
        model="text-embedding-3-large",
        input=request.query
    )

    # 2. Vector search (pgvector)
    similar_docs = vector_search(embedding)

    # 3. Build RAG context
    context = "\n\n".join(similar_docs)
    prompt = f"Context:\n{context}\n\nQ: {request.query}\n\nA:"

    # 4. LLM inference
    answer = openai.ChatCompletion.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}]
    )

    return {"answer": answer}
```

---

### A5: Background Jobs & Workers

**구성 요소**:
- **A5.1**: Task Queue
  - Celery, BullMQ, RabbitMQ
  - Use Cases: Email, Report generation

- **A5.2**: Cron Jobs & Schedulers
  - Kubernetes CronJob, EventBridge
  - Use Cases: Daily backups, Aggregation

- **A5.3**: Event-Driven Workers
  - Triggers: Kafka, SQS, Database events

**Layer/Zone**: L2, Zone 2

**사용 예시**:
```python
# Celery Task (Zone 2)
# Tags: [A5.1, D4.2, I2.2]

from celery import Celery

app = Celery('tasks', broker='redis://...')

@app.task(max_retries=3)
def send_welcome_email(user_id):
    try:
        user = get_user_by_id(user_id)
        send_email(user.email, "Welcome!")
    except Exception as exc:
        raise self.retry(exc=exc, countdown=60 * (2 ** self.request.retries))
```

---

## 3. Layer/Zone 연관성

| Layer | Application Tags | 배치 |
|-------|-----------------|------|
| L0 | A4.2 (External LLM) | OpenAI, Anthropic |
| L1 | A3.1 (API Gateway) | Kong, AWS ALB |
| L2 | A2.2, A4.1 | Microservices, Model Serving |
| L3 | A5.1 | Background Workers |
| L5 | A1.1, A1.2 | Web, Mobile |

---

## 4. CVE 매핑

| CVE ID | Framework | Tech Stack Tag | Severity |
|--------|-----------|---------------|----------|
| CVE-2024-11111 | React <18.2.0 | T1.1 | Medium |
| CVE-2024-22222 | FastAPI <0.104.0 | T1.3 | High |
| CVE-2024-33333 | Spring Boot <3.1.5 | T1.2 | Critical |

---

## 5. MITRE ATT&CK 매핑

| Technique | Application Tag | 탐지/차단 |
|-----------|----------------|----------|
| T1190 | A3.1, S7.2 | WAF, Input Validation |
| T1059 | A2.1, S7.1 | Input Sanitization, SAST |
| T1505 | A2.2, S5.1 | File Integrity, SIEM |
| T1078 | A3.1, S2.1 | MFA, Anomaly Detection |

---

## 6. 다음 단계

- **Domain D (Data)**: A2.2와 연동 (DB 접근)
- **Domain T (Tech Stack)**: A1.1, A2.2와 연동 (프레임워크 버전)
- **Domain I (Interface)**: A3.1과 연동 (프로토콜)

---

**문서 종료**
