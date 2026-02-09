# Dimension 1: Deployment Layer (배치 계층)

> Layer는 **수직 기술 스택**을 나타내며, 하단의 물리적 인프라부터 상단의 비즈니스 애플리케이션까지 포함한다. 이것은 OSI 네트워크 모델이 아니라 **인프라 배포 스택**이다.

---

## Layer 정의

### L0: External Services (외부 서비스)
- **정의**: 우리 조직이 관리하지 않는 외부 SaaS 및 API 서비스
- **핵심 특성**: 해당 인프라에 대한 통제권이 없으며, 신뢰는 계약 기반
- **예시**: OpenAI API, GitHub, Slack, Salesforce, Auth0 (SaaS), Cloudflare (SaaS), PagerDuty, Datadog (SaaS)
- **보안 함의**: 내부 정책 적용 불가. API 보안, 계약 SLA, 아웃바운드 제어에 의존해야 함
- **기본 Zone**: Z0B (Trusted Partner)

### L1: Physical Infrastructure (물리적 인프라)
- **정의**: 물리적 하드웨어, 케이블링, 전원 및 데이터센터 시설
- **핵심 특성**: 모든 컴퓨팅의 기반이 되는 유형의 물리적 자산
- **예시**: 서버 하드웨어, SAN/NAS (NetApp, EMC, Pure Storage), 광섬유 케이블링, 전원 시스템 (UPS, PDU), 냉각 시스템 (HVAC), 랙/캐비닛, 데이터센터 시설 (Equinix, 코로케이션)
- **보안 함의**: 물리적 접근 제어, 환경 모니터링, 하드웨어 무결성
- **일반적 Zone**: Z4 (Management) 또는 Z3 (Restricted)

### L2: Network Infrastructure (네트워크 인프라)
- **정의**: 네트워크 연결, 라우팅, 스위칭 및 네트워크 수준 보안
- **핵심 특성**: 다른 모든 Layer 간의 통신 경로를 제공
- **예시**: Router, Switch, Firewall (NGFW), Load Balancer (F5, ALB, NLB), API Gateway (Kong, AWS API GW), Reverse Proxy (Nginx, Envoy), WAF, VPN Gateway, DNS Server, CDN, IDS/IPS
- **보안 함의**: 네트워크 세그멘테이션, 트래픽 필터링, DDoS 방어, 전송 중 암호화
- **일반적 Zone**: 역할에 따라 Z1 (Perimeter) 또는 Z2 (Service)

### L3: Computing Infrastructure (컴퓨팅 인프라)
- **정의**: 컴퓨팅 자원 프로비저닝 — 가상화, 클라우드 플랫폼, 컴퓨트 인스턴스
- **핵심 특성**: 상위 Layer에 컴퓨팅 자원을 제공하는 추상화 계층
- **예시**: 클라우드 플랫폼 (AWS, Azure, GCP), EC2/VM 인스턴스, VMware ESXi (Hypervisor), 베어메탈 서버, Auto Scaling 그룹, GPU 인스턴스 (NVIDIA A100)
- **보안 함의**: Hypervisor 보안, 인스턴스 격리, 자원 쿼터, 이미지 무결성
- **일반적 Zone**: 워크로드 민감도에 따라 Z2–Z4

### L4: Platform Services (플랫폼 서비스)
- **정의**: 개발 플랫폼, CI/CD 파이프라인, 자동화 및 오케스트레이션 서비스
- **핵심 특성**: 애플리케이션의 배포와 생명주기 관리를 지원
- **예시**: CI/CD (Jenkins, GitLab CI, GitHub Actions), IaC (Terraform, Ansible), GitOps (ArgoCD), Container Registry (Harbor, ECR), ML Platform (SageMaker, Kubeflow, MLflow), Version Control
- **보안 함의**: 파이프라인 보안, 시크릿 관리, 공급망 무결성, 접근 제어
- **일반적 Zone**: Z4 (Management)

### L5: Data Services (데이터 서비스)
- **정의**: 데이터 저장, 처리 및 분석 시스템
- **핵심 특성**: 영구 데이터를 관리 — 가장 가치 있고 민감한 자산
- **예시**: RDBMS (PostgreSQL, MySQL), NoSQL (MongoDB), Graph DB (Neo4j), Redis (데이터 저장소로 사용 시), Pinecone, Elasticsearch, Object Storage (S3), Data Warehouse (Redshift, BigQuery), Vector DB, 백업 시스템
- **보안 함의**: 저장 시 암호화, 접근 제어, 감사 로깅, 백업 무결성, 데이터 분류
- **일반적 Zone**: Z3 (Data) — 최고 데이터 민감도

### L6: Application Runtime (애플리케이션 런타임)
- **정의**: 애플리케이션 실행 환경, 컨테이너, 오케스트레이션 및 미들웨어
- **핵심 특성**: 애플리케이션이 실행되는 런타임 환경을 제공
- **예시**: Docker 컨테이너, Kubernetes, Message Queue (Kafka, RabbitMQ), In-Memory Cache (캐시로 사용되는 Redis, Memcached), Application Server (Tomcat, JBoss), Service Mesh (Istio, Linkerd)
- **보안 함의**: 컨테이너 보안, 오케스트레이션 정책, 런타임 보호, 서비스 간 인증
- **일반적 Zone**: 데이터 접근 여부에 따라 Z2 (Service) 또는 Z3 (Data)

### L7: Business Logic & Application (비즈니스 로직 & 애플리케이션)
- **정의**: 사용자 대면 애플리케이션, 비즈니스 로직, API 및 AI 워크로드
- **핵심 특성**: 비즈니스 가치를 구현 — 다른 모든 Layer가 존재하는 이유
- **예시**: Frontend Web App (React, Vue, Angular), Mobile App, Admin Dashboard, Backend API (REST, GraphQL), Serverless Functions (Lambda), LLM Inference API (vLLM, TGI), RAG Pipeline (LangChain), AI Agent Workflows
- **보안 함의**: 애플리케이션 수준 보안, 입력 검증, 인증/인가, 비즈니스 로직 보호
- **일반적 Zone**: 대부분 Z2 (Service); 공개 대면의 경우 Z1 (Perimeter)

### Cross-Layer: Management & Security (관리 & 보안)
- **정의**: 모든 Layer에 걸쳐 운영되는 시스템 — 모니터링, 보안 및 관리 인프라
- **핵심 특성**: 전체 스택에 걸쳐 운영되며, 여러 Layer에 대한 가시성 보유
- **예시**: 모니터링 (Prometheus, Grafana, ELK, Datadog agent), 보안 & IAM (Okta, Azure AD, Vault, CyberArk), SIEM (Splunk), ITSM (ServiceNow, CMDB), EDR 에이전트
- **보안 함의**: 최고 수준의 권한 필요; 침해 시 전체 스택에 영향
- **기본 Zone**: Z4 (Management)

---

## Layer 할당 규칙

1. **주요 기능이 Layer를 결정**: 기술 스택에서 구성요소의 핵심 목적을 파악
2. **"배포 스택에서 어디에 위치하는가?"**: Physical → Network → Compute → Platform → Data → Runtime → Application
3. **동일 제품, 다른 역할 = 다른 Layer**: 캐시로서의 Redis (L6) vs 영구 저장소로서의 Redis (L5)
4. **외부 서비스는 항상 L0**: 우리가 통제하지 않는 모든 서비스는 L0에 배치
5. **관리/모니터링 도구 → Cross-Layer**: 여러 Layer에 걸쳐 있으면 Cross-Layer 사용
6. **모호한 경우**: 구성요소가 주요 가치를 제공하는 Layer를 선택

---

## Layer 요약 표

| Layer | 이름 | 핵심 질문 | 신뢰 방향 |
|-------|------|----------|----------|
| L0 | External Services | 우리의 통제 밖에 있는가? | 아웃바운드 신뢰 |
| L1 | Physical | 물리적으로 접촉할 수 있는가? | 기반 |
| L2 | Network | 트래픽을 라우팅/필터링하는가? | 경계 |
| L3 | Computing | 컴퓨팅 자원을 제공하는가? | 자원 |
| L4 | Platform | 배포/생명주기를 관리하는가? | 운영 |
| L5 | Data | 영구 데이터를 저장/처리하는가? | 데이터 중력 |
| L6 | Runtime | 실행 중인 애플리케이션을 호스팅하는가? | 실행 |
| L7 | Application | 비즈니스 로직을 구현하는가? | 사용자 대면 |
| Cross | Management & Security | 여러 Layer에 걸쳐 있는가? | 감독 |

---

*Document Version: v5.0 | Last Updated: 2026-02-06*
