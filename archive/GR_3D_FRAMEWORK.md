# GR 3D Classification Framework v5.0

> Every infrastructure component occupies a unique position in three-dimensional space: **Layer (vertical stack) × Zone (horizontal trust) × Function (capability role)**.

---

## 1. Overview

The GR 3D Framework assigns coordinates to every IT infrastructure component across three dimensions:

| Dimension | Axis | Question Answered | Values |
|-----------|------|-------------------|--------|
| **Layer** | Vertical | Where in the technology stack? | L0–L7 + Cross-Layer |
| **Zone** | Horizontal | What trust boundary? | Z0A, Z0B, Z1–Z5 |
| **Function** | Functional | What capability does it provide? | 10 domains, 280+ codes |

**Core Invariant**: Same coordinates → same security policies, regardless of deployment environment (AWS, Azure, on-premise, hybrid).

---

## 2. Dimension 1: Deployment Layer (배치 계층)

Layers represent the **vertical technology stack**, from physical infrastructure at the bottom to business applications at the top. This is NOT the OSI network model — it is an **infrastructure deployment stack**.

### Layer Definitions

#### L0: External Services (외부 서비스)
- **Definition**: External SaaS and API services NOT managed by our organization
- **Key Characteristic**: We have no control over their infrastructure; trust is contract-based
- **Examples**: OpenAI API, GitHub, Slack, Salesforce, Auth0 (SaaS), Cloudflare (SaaS), PagerDuty, Datadog (SaaS)
- **Security Implication**: Cannot enforce internal policies; must rely on API security, contract SLAs, and outbound controls
- **Default Zone**: Z0B (Trusted Partner)

#### L1: Physical Infrastructure (물리적 인프라)
- **Definition**: Physical hardware, cabling, power, and data center facilities
- **Key Characteristic**: Tangible, physical assets that form the foundation of all computing
- **Examples**: Server hardware, SAN/NAS (NetApp, EMC, Pure Storage), fiber cabling, power systems (UPS, PDU), cooling (HVAC), racks/cabinets, data center facilities (Equinix, colocation)
- **Security Implication**: Physical access control, environmental monitoring, hardware integrity
- **Typical Zone**: Z4 (Management) or Z3 (Restricted)

#### L2: Network Infrastructure (네트워크 인프라)
- **Definition**: Network connectivity, routing, switching, and network-level security
- **Key Characteristic**: Provides communication paths between all other layers
- **Examples**: Router, Switch, Firewall (NGFW), Load Balancer (F5, ALB, NLB), API Gateway (Kong, AWS API GW), Reverse Proxy (Nginx, Envoy), WAF, VPN Gateway, DNS Server, CDN, IDS/IPS
- **Security Implication**: Network segmentation, traffic filtering, DDoS protection, encryption in transit
- **Typical Zone**: Z1 (Perimeter) or Z2 (Service), depending on role

#### L3: Computing Infrastructure (컴퓨팅 인프라)
- **Definition**: Computing resource provisioning — virtualization, cloud platforms, compute instances
- **Key Characteristic**: Abstraction layer that provides compute resources to higher layers
- **Examples**: Cloud platforms (AWS, Azure, GCP), EC2/VM instances, VMware ESXi (Hypervisor), bare metal servers, auto scaling groups, GPU instances (NVIDIA A100)
- **Security Implication**: Hypervisor security, instance isolation, resource quotas, image integrity
- **Typical Zone**: Z2–Z4, depending on workload sensitivity

#### L4: Platform Services (플랫폼 서비스)
- **Definition**: Development platforms, CI/CD pipelines, automation, and orchestration services
- **Key Characteristic**: Enables deployment and lifecycle management of applications
- **Examples**: CI/CD (Jenkins, GitLab CI, GitHub Actions), IaC (Terraform, Ansible), GitOps (ArgoCD), Container Registry (Harbor, ECR), ML Platform (SageMaker, Kubeflow, MLflow), Version Control
- **Security Implication**: Pipeline security, secrets management, supply chain integrity, access control
- **Typical Zone**: Z4 (Management)

#### L5: Data Services (데이터 서비스)
- **Definition**: Data storage, processing, and analytics systems
- **Key Characteristic**: Manages persistent data — the most valuable and sensitive assets
- **Examples**: RDBMS (PostgreSQL, MySQL), NoSQL (MongoDB), Graph DB (Neo4j), Redis (as data store), Pinecone, Elasticsearch, Object Storage (S3), Data Warehouse (Redshift, BigQuery), Vector DB, Backup Systems
- **Security Implication**: Encryption at rest, access control, audit logging, backup integrity, data classification
- **Typical Zone**: Z3 (Data) — highest data sensitivity

#### L6: Application Runtime (애플리케이션 런타임)
- **Definition**: Application execution environments, containers, orchestration, and middleware
- **Key Characteristic**: Provides the runtime environment where applications execute
- **Examples**: Docker containers, Kubernetes, Message Queue (Kafka, RabbitMQ), In-Memory Cache (Redis as cache, Memcached), Application Server (Tomcat, JBoss), Service Mesh (Istio, Linkerd)
- **Security Implication**: Container security, orchestration policies, runtime protection, service-to-service auth
- **Typical Zone**: Z2 (Service) or Z3 (Data), depending on data access

#### L7: Business Logic & Application (비즈니스 로직 & 애플리케이션)
- **Definition**: User-facing applications, business logic, APIs, and AI workloads
- **Key Characteristic**: Implements business value — the reason all other layers exist
- **Examples**: Frontend Web App (React, Vue, Angular), Mobile App, Admin Dashboard, Backend API (REST, GraphQL), Serverless Functions (Lambda), LLM Inference API (vLLM, TGI), RAG Pipeline (LangChain), AI Agent Workflows
- **Security Implication**: Application-level security, input validation, authentication/authorization, business logic protection
- **Typical Zone**: Z2 (Service) for most; Z1 (Perimeter) for public-facing

#### Cross-Layer: Management & Security (관리 & 보안)
- **Definition**: Systems that span ALL layers — monitoring, security, and management infrastructure
- **Key Characteristic**: Operates across the entire stack; has visibility into multiple layers
- **Examples**: Monitoring (Prometheus, Grafana, ELK, Datadog agent), Security & IAM (Okta, Azure AD, Vault, CyberArk), SIEM (Splunk), ITSM (ServiceNow, CMDB), EDR agents
- **Security Implication**: Highest privilege requirement; compromise affects entire stack
- **Default Zone**: Z4 (Management)

### Layer Assignment Rules

1. **Primary function determines Layer**: Identify the component's core purpose in the technology stack
2. **"Where does it sit in the deployment stack?"**: Physical → Network → Compute → Platform → Data → Runtime → Application
3. **Same product, different role = different Layer**: Redis as cache (L6) vs Redis as persistent store (L5)
4. **External services always L0**: Any service we don't control goes to L0
5. **Management/monitoring tools → Cross-Layer**: If it spans multiple layers, use Cross-Layer
6. **When ambiguous**: Choose the Layer where the component provides its PRIMARY value

### Layer Summary Table

| Layer | Name | Core Question | Trust Direction |
|-------|------|---------------|-----------------|
| L0 | External Services | Is it outside our control? | Outbound trust |
| L1 | Physical | Can you physically touch it? | Foundation |
| L2 | Network | Does it route/filter traffic? | Perimeter |
| L3 | Computing | Does it provide compute resources? | Resource |
| L4 | Platform | Does it manage deployment/lifecycle? | Operations |
| L5 | Data | Does it store/process persistent data? | Data gravity |
| L6 | Runtime | Does it host running applications? | Execution |
| L7 | Application | Does it implement business logic? | User-facing |
| Cross | Management & Security | Does it span multiple layers? | Oversight |

---

## 3. Dimension 2: Security Zone (보안 구역)

Zones represent **logical trust boundaries**, NOT physical network segments. The same zone architecture applies regardless of whether implementation uses VLANs, VPC subnets, security groups, or firewall policies.

**Critical Rule**: Zone numbers are **labels**, not sequential order. Z5 (Endpoint) has LOWER trust than Z4 (Management).

### Zone Definitions

#### Z0A: Untrusted External — Trust: 0%
- **Definition**: Completely untrusted external zone; origin of attacks
- **Components**: General internet users, attacker infrastructure, anonymous access (Tor, VPN, proxies), bots/crawlers/scanners
- **Characteristics**:
  - Zero trust — no authentication possible
  - We cannot apply our security policies
  - Primary threat source
- **Traffic Direction**: Primarily inbound (external → internal)
- **Required Controls**: DDoS Protection, WAF, NGFW, Rate Limiting, Bot Detection, IP Reputation

#### Z0B: Trusted Partner — Trust: 10%
- **Definition**: External SaaS/partner services authenticated via API Key, OAuth, or SAML
- **Components**: OpenAI API, GitHub, Slack, Salesforce, Auth0/Okta (external SaaS), Cloudflare, Datadog (SaaS), PagerDuty
- **Characteristics**:
  - Contract-based trust (SLA, DPA agreements)
  - API Key/OAuth/SAML authentication required
  - Usage monitoring mandatory
  - Data classification policy applies for sensitive data
- **Traffic Direction**: Primarily outbound (internal → external)
- **Required Controls**: API Key Management, Usage Monitoring, Outbound Proxy, Rate Limiting, DLP

#### Z1: Perimeter / Boundary — Trust: 20%
- **Definition**: Boundary between external (Z0) and internal zones; first line of defense
- **Components**: CDN, WAF, DDoS Protection, Public Load Balancer (ALB/NLB), NGFW, Public DNS, Internet Gateway, Bastion Host
- **Characteristics**:
  - First defense line — all external traffic MUST pass through
  - Our managed infrastructure with direct external exposure
  - High attack surface
- **Required Controls**: DPI (Deep Packet Inspection), WAF rules, IPS signatures, DDoS mitigation, Rate Limiting, Bot blocking

#### Z2: Service / Application — Trust: 40%
- **Definition**: Business logic, web/mobile/backend APIs, microservices zone
- **Components**: API Gateway, Backend API Server, Kubernetes Pods, Service Mesh, Message Queue, Redis Cache, Self-hosted LLM Inference, RAG Pipeline
- **Characteristics**:
  - Limited trust — application-level authentication required
  - Primary business logic execution zone
  - Service-to-service communication
- **Required Controls**: JWT/OAuth token validation, API Rate Limiting, Application-level firewall, Session management, Audit logging

#### Z3: Data / Storage — Trust: 60%
- **Definition**: Structured and unstructured data storage and processing core
- **Components**: RDBMS (PostgreSQL, MySQL), NoSQL (MongoDB), Graph DB (Neo4j), Vector DB (Pinecone, Qdrant), Object Storage (S3), Data Warehouse, Backup Storage, ML model checkpoint storage
- **Characteristics**:
  - Sensitive data residence — encryption mandatory
  - Fully network-isolated from external zones
  - Least privilege access enforced
- **Required Controls**: Private Subnet isolation, TDE (Transparent Data Encryption), Database Firewall, Least Privilege, Query audit logging

#### Z4: Management / Platform — Trust: 80%
- **Definition**: Infrastructure management, operations, deployment, and monitoring zone
- **Components**: CI/CD (Jenkins, GitLab), IaC (Terraform, Ansible), Monitoring (Grafana, ELK), IAM (Okta, AD), Secrets Management (Vault), PAM (CyberArk), ITSM (ServiceNow), MLOps Platform
- **Characteristics**:
  - Internal management systems — VPN required
  - Highest privilege operations
  - Organization-wide damage possible if compromised
- **Required Controls**: VPN mandatory (Zero Trust), MFA enforced, PAM (Privileged Access Management), Full access audit, Network segmentation

#### Z5: Internal Endpoints — Trust: 50%
- **Definition**: Internal user endpoints and workstations controlled by our organization
- **Components**: Employee PCs/laptops, VDI (Virtual Desktop Infrastructure), Admin workstations, MDM (Intune, Jamf), EDR (CrowdStrike, SentinelOne), VPN Client, Web Browser
- **Characteristics**:
  - Internal threat origin — phishing, malware infection starting point
  - Variable trust — managed devices vs BYOD
  - Human factor = highest unpredictability
- **Required Controls**: Zero Trust access control, Device Compliance verification, EDR, MDM, Conditional Access

**Note on Z5 Trust**: Z5 (50%) sits BELOW Z4 (80%) and Z3 (60%) despite being "internal" because user endpoints are the most common entry point for threats (phishing, malware, social engineering). Trust is based on RISK, not proximity.

### Inter-Zone Traffic Control Matrix

| Source → Destination | Required Controls |
|----------------------|-------------------|
| Z0A → Z1 | DDoS Protection, WAF, NGFW, Rate Limiting |
| Z0B → Z1 | API Key Validation, Rate Limiting, OAuth Verification |
| Z1 → Z2 | WAF, Rate Limiting, API Gateway, IPS |
| Z2 → Z3 | Database Firewall, Query Validation, TLS + Client Cert |
| Z2 → Z4 | VPN, MFA, Audit Logging, PAM |
| Z5 → Z2 | Zero Trust, Device Compliance, Conditional Access, MFA |
| Z5 → Z4 | Zero Trust, Device Compliance, MFA, PAM, Audit |
| Z2 → Z0B (outbound) | Proxy, API Key Management, Usage Monitoring |
| Z2 → Z0A (outbound) | Proxy, DLP (Data Loss Prevention), Content Filtering |

### Zone Assignment Rules

1. **Trust boundary determines Zone**: What level of trust does this component operate within?
2. **External = Z0**: Services we don't control → Z0A (unauthenticated) or Z0B (authenticated)
3. **Perimeter = Z1**: Components directly exposed to external traffic
4. **Business logic = Z2**: Application servers, APIs, microservices
5. **Data = Z3**: Anything that stores or processes persistent data
6. **Management = Z4**: Operations, monitoring, deployment, IAM tools
7. **User devices = Z5**: Endpoints used by humans
8. **Same product, different deployment = different Zone**: Nginx as public LB → Z1; Nginx as internal proxy → Z2
9. **Cross-Layer defaults to Z4**: Management and monitoring tools typically reside in Z4

---

## 4. Dimension 3: Function Code (기능 코드)

Function codes identify the **specific capability** a component provides. The hierarchy uses the format: `{Domain}{Category}.{Sequence}`.

### 4.1 Domain Overview

| Domain | Code | Name | Description |
|--------|------|------|-------------|
| 1 | **M** | Monitoring | Observability, metrics, logging, alerting |
| 2 | **N** | Network | Connectivity, routing, proxying, DNS |
| 3 | **S** | Security | Firewalls, IAM, encryption, access control |
| 4 | **A** | Application | App serving, containers, serverless, AI |
| 5 | **D** | Data | Storage, caching, messaging, analytics |
| 6 | **R** | Resource | Compute instances, scaling, GPU |
| 7 | **C** | Compute | Hypervisors, batch/stream processing, ML |
| 8 | **P** | Platform | CI/CD, IaC, secrets, backup |
| 9 | **T** | Tech Stack | Languages, runtimes, operating systems |
| 10 | **I** | Interface | Protocols, data formats, API styles |

### 4.2 Complete Function Code Hierarchy

#### Domain M: Monitoring
| Code | Function |
|------|----------|
| M1.1 | Metrics Collection |
| M1.2 | Log Aggregation |
| M1.3 | Distributed Tracing |
| M1.4 | APM (Application Performance Monitoring) |
| M2.1 | Alerting & Notification |
| M2.2 | Dashboard & Visualization |
| M3.1 | SIEM (Security Information & Event Management) |
| M3.2 | Threat Intelligence |

#### Domain N: Network
| Code | Function |
|------|----------|
| N1.1 | L4 Load Balancing (TCP/UDP) |
| N1.2 | L7 Load Balancing (HTTP/HTTPS) |
| N2.1 | Reverse Proxy |
| N2.2 | Forward Proxy |
| N3.1 | Service Discovery |
| N3.2 | DNS Resolution |
| N4.1 | VPN Gateway (IPSec) |
| N4.2 | VPN Gateway (SSL/TLS) |

#### Domain S: Security
| Code | Function |
|------|----------|
| S1.1 | NGFW (Next-Gen Firewall) |
| S1.2 | WAF (Web Application Firewall) |
| S1.3 | IDS/IPS (Intrusion Detection/Prevention) |
| S1.4 | DDoS Protection |
| S1.5 | JWT Validation |
| S2.1 | RBAC (Role-Based Access Control) |
| S2.2 | OAuth 2.0 / OIDC |
| S2.3 | SAML 2.0 SSO |
| S3.1 | Rate Limiting (Request) |
| S3.2 | Rate Limiting (Bandwidth) |
| S4.1 | Encryption at Rest |
| S4.2 | Encryption in Transit |
| S5.1 | TLS/SSL Termination |

#### Domain A: Application
| Code | Function |
|------|----------|
| A1.1 | Static File Serving |
| A1.2 | API Gateway |
| A1.3 | GraphQL Gateway |
| A1.4 | Service Mesh Ingress |
| A1.5 | Backend API Server |
| A1.6 | Frontend Web Server |
| A1.7 | Server-Side Rendering (SSR) |
| A2.1 | Containerization |
| A2.2 | Container Orchestration |
| A2.3 | Serverless Functions |
| A3.1 | LLM Inference |
| A3.2 | Vector Search |
| A3.3 | RAG Pipeline |
| A3.4 | AI Agent Framework |

#### Domain D: Data
| Code | Function |
|------|----------|
| D1.1 | Key-Value Store |
| D1.2 | Document Store (NoSQL) |
| D1.3 | Relational Storage (SQL) |
| D1.4 | Wide-Column Store |
| D1.5 | Graph Database |
| D1.6 | Vector Database |
| D2.1 | In-Memory Caching |
| D2.2 | CDN Caching |
| D2.3 | Application Caching |
| D2.4 | Browser Caching |
| D2.5 | Static Content Caching |
| D3.1 | Message Queue (FIFO) |
| D3.2 | Pub/Sub Messaging |
| D3.3 | Event Streaming |
| D4.1 | Object Storage |
| D4.2 | Block Storage |
| D4.3 | File Storage (NFS/SMB) |
| D5.1 | Data Warehouse |
| D5.2 | Data Lake |
| D5.3 | Search & Analytics |

#### Domain R: Resource
| Code | Function |
|------|----------|
| R1.1 | Virtual Machine |
| R1.2 | Bare Metal Server |
| R2.1 | Auto Scaling |
| R2.2 | Resource Quota Management |
| R3.1 | GPU Compute |
| R3.2 | TPU/ASIC |

#### Domain C: Compute
| Code | Function |
|------|----------|
| C1.1 | Hypervisor |
| C1.2 | Container Runtime |
| C2.1 | Batch Processing |
| C2.2 | Stream Processing |
| C3.1 | ML Training |
| C3.2 | ML Inference Serving |

#### Domain P: Platform
| Code | Function |
|------|----------|
| P1.1 | CI/CD Pipeline |
| P1.2 | IaC (Infrastructure as Code) |
| P1.3 | GitOps |
| P2.1 | Backup & Recovery |
| P2.2 | Disaster Recovery |
| P3.1 | Secrets Management |
| P3.2 | Certificate Management |
| P4.1 | Feature Flag Management |
| P4.2 | A/B Testing Platform |

#### Domain T: Tech Stack
| Code | Function |
|------|----------|
| T1.1 | Java |
| T1.2 | Python |
| T1.3 | Go |
| T1.4 | Node.js |
| T1.5 | Rust |
| T1.6 | C/C++ |
| T1.7 | C# / .NET |
| T1.8 | Ruby |
| T1.9 | PHP |
| T1.10 | Kotlin |
| T2.1 | JVM |
| T2.2 | .NET CLR |
| T2.3 | Python Runtime |
| T2.4 | Node.js Runtime |
| T3.1 | Linux |
| T3.2 | Windows |
| T3.3 | macOS |
| T3.4 | Container OS |

#### Domain I: Interface
| Code | Function |
|------|----------|
| I1.1 | HTTP/1.1 |
| I1.2 | HTTP/2 |
| I1.3 | HTTP/3 (QUIC) |
| I1.4 | gRPC |
| I1.5 | WebSocket |
| I1.6 | MQTT |
| I1.7 | AMQP |
| I1.8 | GraphQL over HTTP |
| I2.1 | JSON |
| I2.2 | XML |
| I2.3 | Protobuf |
| I2.4 | Avro |
| I2.5 | MessagePack |
| I2.6 | YAML |
| I3.1 | REST API |
| I3.2 | SOAP |
| I3.3 | GraphQL |
| I3.4 | OpenAPI (Swagger) |

### 4.3 Function Assignment Rules

1. **Primary function = `function` field**: Each infrastructure atom gets ONE primary function code representing its main purpose
2. **Archetype model for multi-function**: If a product serves multiple roles, create separate atoms (archetypes) each with its own function code and coordinates
3. **Hierarchical format required**: Always use full format `{Domain}{Category}.{Sequence}` (e.g., `S1.2`). Single-letter codes (`S`, `A`) are forbidden
4. **Domain T and I are attributes**: Tech Stack (T) and Interface (I) codes describe characteristics rather than primary capabilities — use `atom_tags` for these unless they ARE the primary function
5. **Function determines Layer and Zone**: The function code strongly implies which Layer and Zone the component belongs to (e.g., D1.3 Relational Storage → L5 Data, Z3 Data Zone)

### 4.4 Function-to-Coordinate Mapping Guide

| Function Domain | Typical Layer | Typical Zone |
|-----------------|---------------|--------------|
| M (Monitoring) | Cross-Layer | Z4 |
| N (Network) | L2 | Z1–Z2 |
| S (Security) | L2 or Cross | Z1–Z4 |
| A (Application) | L7 | Z2 |
| D (Data) | L5 | Z3 |
| R (Resource) | L3 | Z2–Z4 |
| C (Compute) | L3 | Z2–Z4 |
| P (Platform) | L4 | Z4 |
| T (Tech Stack) | L3 or L6 | varies |
| I (Interface) | L2 or L7 | varies |

---

## 5. Coordinate-Based Inference

### 5.1 Automatic Policy Inheritance

When a new infrastructure component is assigned coordinates, it automatically inherits all security policies from existing components at the same coordinates:

```
New Component → Analyze Function → Assign (Layer, Zone, Function)
                                        ↓
                          Query existing atoms at same coordinates
                                        ↓
                          Inherit: Layer policies + Zone policies
                                 + Layer×Zone intersection policies
                                 + Function-specific policies
                                        ↓
                          Add: Product-specific exceptions only
```

**Policy Application Priority** (higher overrides lower):
1. Regulatory compliance requirements (highest)
2. Product-specific exceptions
3. Function-specific policies
4. Layer × Zone intersection policies
5. Zone common policies
6. Layer common policies (lowest)

**Override Rule**: Security-strengthening policies always override convenience policies at the same priority level.

### 5.2 Coordinate Distance and Security Relationships

The distance between two components determines the security relationship:

```
distance = |Layer₁ - Layer₂| + |Zone₁ - Zone₂|
```

| Distance | Relationship | Security Implication |
|----------|-------------|---------------------|
| 0 | Same coordinate | Identical policies |
| 1 | Adjacent | Boundary policies apply |
| 2–3 | Near | Controlled communication |
| 4–5 | Moderate | Restricted access |
| ≥6 | Remote | Strict isolation required |

**Example**:
- External API (L0, Z0A) → PostgreSQL (L5, Z3): distance = 5 + 3 = 8 → Maximum isolation
- Backend API (L7, Z2) → PostgreSQL (L5, Z3): distance = 2 + 1 = 3 → Controlled access

### 5.3 Deployment Independence

The same logical component gets the **same coordinates** regardless of deployment environment:

| Deployment | PostgreSQL Coordinates | Security Policy |
|------------|----------------------|-----------------|
| AWS RDS | L5, Z3, D1.3 | **Identical** |
| Azure Database | L5, Z3, D1.3 | **Identical** |
| On-Premise Server | L5, Z3, D1.3 | **Identical** |
| GCP Cloud SQL | L5, Z3, D1.3 | **Identical** |

The deployment platform (AWS, Azure, etc.) is captured as a `platform` attribute in `atom_tags`, NOT as part of the 3D coordinate. Platform affects operational context (cost, SLA, regulatory jurisdiction) but NOT security policy.

### 5.4 Archetype-Based Multi-Coordinate Assignment

A single product can occupy multiple positions in 3D space through the Archetype model:

**Example: Redis**
| Archetype | Layer | Zone | Function | Security Profile |
|-----------|-------|------|----------|-----------------|
| Key-Value Store | L5 | Z3 | D1.1 | Data encryption, backup, access control |
| In-Memory Cache | L6 | Z2 | D2.1 | Session timeout, cache invalidation |
| Session Store | L5 | Z3 | D1.1 | Session encryption, PII protection |
| Message Broker | L6 | Z2 | D3.1 | Message integrity, queue security |

Each archetype is a **separate atom** with its own ID, coordinates, and security policies. They are linked by `instance_of` relations to a common product atom.

---

## 6. Coordinate Examples

### 6.1 Complete Infrastructure Mapping Example

```yaml
# Nginx as Public Load Balancer
INFRA-NET-NGINX-001:
  layer: L2
  zone: Z1
  function: "N1.2"  # L7 Load Balancing

# Nginx as Internal Reverse Proxy
INFRA-NET-NGINX-002:
  layer: L2
  zone: Z2
  function: "N2.1"  # Reverse Proxy

# PostgreSQL as Primary Database
INFRA-DATA-POSTGRESQL-001:
  layer: L5
  zone: Z3
  function: "D1.3"  # Relational Storage

# Kubernetes as Container Orchestrator
INFRA-APP-KUBERNETES-001:
  layer: L6
  zone: Z2
  function: "A2.2"  # Container Orchestration

# Vault as Secrets Manager
INFRA-SEC-VAULT-001:
  layer: Cross
  zone: Z4
  function: "P3.1"  # Secrets Management

# Grafana as Dashboard
INFRA-MON-GRAFANA-001:
  layer: Cross
  zone: Z4
  function: "M2.2"  # Dashboard & Visualization

# vLLM Inference API
INFRA-APP-VLLM-001:
  layer: L7
  zone: Z2
  function: "A3.1"  # LLM Inference

# Employee Laptop
INFRA-END-LAPTOP-001:
  layer: L7
  zone: Z5
  function: "I3.1"  # REST API (client)
```

### 6.2 E-Commerce Architecture Mapping

| Component | Layer | Zone | Function | Key Policies |
|-----------|-------|------|----------|-------------|
| Cloudflare CDN | L2 | Z1 | D2.2 | DDoS, WAF, Bot Detection |
| ALB (Public) | L2 | Z1 | N1.2 | TLS Termination, Rate Limit |
| API Gateway (Kong) | L2 | Z2 | A1.2 | JWT Validation, Rate Limit |
| Backend API (Node.js) | L7 | Z2 | A1.5 | Input Validation, AuthZ |
| Redis Cache | L6 | Z2 | D2.1 | Session Timeout, No PII |
| PostgreSQL | L5 | Z3 | D1.3 | TDE, Query Audit, Backup |
| Elasticsearch | L5 | Z3 | D5.3 | Index ACL, Audit Log |
| Jenkins CI/CD | L4 | Z4 | P1.1 | Pipeline Security, MFA |
| Vault | Cross | Z4 | P3.1 | HSM Backend, Audit |
| Grafana | Cross | Z4 | M2.2 | SSO, Read-only Default |
| Employee Laptop | L7 | Z5 | — | EDR, MDM, Zero Trust |

**Auto-generated policy count**: ~156 policies
- 42 Layer common policies
- 58 Zone common policies
- 36 boundary/intersection policies
- 20 product-specific exceptions

---

## 7. Extensibility

### 7.1 Adding New Function Codes

New function codes can be added within existing domains:
1. Identify the appropriate domain (M, N, S, A, D, R, C, P, T, I)
2. Find the appropriate category number within the domain
3. Assign the next available sequence number
4. Document the new code with definition and examples

### 7.2 Adding New Domains

New domains should only be added when:
- A significant capability area is NOT covered by existing 10 domains
- Multiple function codes would belong to the new domain
- The domain is orthogonal to existing domains

### 7.3 Version Compatibility

- Layer definitions (L0–L7 + Cross) are **stable** — changes require major version bump
- Zone definitions (Z0A–Z5) are **stable** — changes require major version bump
- Function codes are **extensible** — new codes can be added in minor versions
- Existing function codes are **immutable** — once assigned, a code's meaning never changes

---

*Document Version: v5.0 | Last Updated: 2026-02-06*
