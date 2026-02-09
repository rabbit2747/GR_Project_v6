# GR Classification Rules v5.1

> **권한**: 이 문서는 GR Ontology의 결정론적 분류 규칙을 정의한다. 동일한 입력은 반드시 동일한 분류 결과를 생성해야 한다. 규칙이 모호할 경우 해당 규칙은 결함이 있으며 수정되어야 한다.

---

## 1. 기본 원칙

1. **결정론적**: 주관적 판단 불허. 모든 결정에는 명확한 이진 규칙이 존재한다.
2. **Prefix는 절대적**: ID prefix가 `is_infrastructure`, 디렉토리, 기본 type을 결정한다. 예외 없음.
3. **모호성 제로**: 분류가 불명확할 경우 사람에게 에스컬레이션한다 — 절대 추측하지 않는다.
4. **원자성**: 하나의 atom = 하나의 독립적 개념. 혼합된 개념은 별도의 atom으로 분리해야 한다.

---

## 2. 12단계 분류 프로세스

### 1단계: 본질적 성격 파악

질문: **"이것은 근본적으로 무엇인가?"**

| 만약... | Prefix | 다음 단계 |
|---------|--------|-----------|
| 배포 가능한 인프라 구성 요소 (서버, 장치, 소프트웨어 인스턴스) | `INFRA-` | 2A단계 |
| 공격 기법 또는 공세적 기술 | `ATK-` | 2B단계 |
| 방어 기법, 대응 수단, 또는 보안 통제 (지식으로서) | `DEF-` | 2B단계 |
| 약점, 결함, 또는 취약점 | `VUL-` | 2B단계 |
| 보안 도구 또는 도구의 사용법에 관한 지식 | `TOOL-` | 2B단계 |
| 규정, 컴플라이언스 프레임워크, 또는 공식 표준 | `COMP-` | 2B단계 |
| 일반적인 기술 개념 또는 범주 | `TECH-` | 2B단계 |
| 위협 행위자, 보안 조직, 벤더, 또는 연구기관 | `ACTOR-` | 2B단계 |
| 악성 소프트웨어 (malware, ransomware, trojan) | `MALWARE-` | 2B단계 |
| 탐지 시그니처, 규칙, 또는 지표 | `DETECT-` | 2B단계 |
| 통신 프로토콜 또는 표준 | `PROTO-` | 2B단계 |
| 보안 원칙, 철학, 또는 공리 | `PRI-` | 2B단계 |

**구분 규칙**:
- WAF가 배포된 어플라이언스인 경우 → `INFRA-`. WAF 설정 규칙 (지식) → `DEF-`
- Nmap이 설치된 소프트웨어인 경우 → `INFRA-`. Nmap 사용법/도구 지식 → `TOOL-`
- SQL Injection 기법 → `ATK-`. CWE-89 약점 → `VUL-`. SQLi 탐지 규칙 → `DETECT-`
- TLS가 프로토콜 사양인 경우 → `PROTO-`. TLS 종단 장치 → `INFRA-`
- Zero Trust가 철학인 경우 → `PRI-`. Zero Trust 구현 가이드 → `TECH-`
- CrowdStrike, Mandiant 같은 보안 기업 → `ACTOR-`. 해당 기업의 도구 → `TOOL-`
- 도구 이름(Nmap, Burp Suite, Metasploit)은 기본적으로 `TOOL-`. 인프라로 배포된 인스턴스만 `INFRA-`

### 2A단계: 인프라 분류 (INFRA- 전용)

**설정**: `is_infrastructure: true`

인프라 하위 유형 결정:

| 질문 | '예'인 경우 → Type |
|------|-------------------|
| 핵심 인프라 구성 요소인가 (서버, DB, 네트워크 장치)? | `component` |
| 인프라로 배포된 운영/보안 도구인가 (SIEM 인스턴스, 스캐너 에이전트)? | `component_tool` |
| 인프라로 배포된 보안 통제 장치인가 (WAF 어플라이언스, IDS 센서, 방화벽)? | `component_control` |

**의사 결정 트리**:
```
Is it primarily a SECURITY device?
  ├── YES: Is it for detection/prevention?
  │     ├── YES → component_control (WAF, IDS/IPS, firewall)
  │     └── NO → component_tool (SIEM, vulnerability scanner, EDR)
  └── NO → component (server, DB, router, switch, container)
```

**3A단계로 이동** (좌표 배정).

### 2B단계: 지식 분류 (INFRA- 이외 모든 prefix)

**설정**: `is_infrastructure: false`

**범주 vs. 구체적 항목 테스트**를 사용하여 지식 하위 유형을 결정한다:

| 질문 | 답변 |
|------|------|
| 직접 실행, 적용, 또는 구현할 수 있는가? | 구체적 → prefix 기본 type 사용 |
| 다른 atom들을 그룹화하는 상위 범주인가? | 범주 → `concept` |
| 구체적이고 한 문장으로 표현 가능한 동작으로 기술할 수 있는가? | 구체적 → prefix 기본 type 사용 |

**Prefix별 기본 Type**:

| Prefix | 기본 Type (구체적) | 범주 Type |
|--------|-------------------|-----------|
| `ATK-` | `technique` | `concept` ("Injection" 같은 범주인 경우) |
| `DEF-` | `control_policy` | `concept` ("Access Control" 같은 범주인 경우) |
| `VUL-` | `vulnerability` | `concept` ("Authentication Flaws" 같은 범주인 경우) |
| `TOOL-` | `tool_knowledge` | `concept` ("Reconnaissance Tools" 같은 범주인 경우) |
| `COMP-` | `control_policy` | `concept` ("Privacy Regulations" 같은 범주인 경우) |
| `TECH-` | `concept` | `concept` (항상) |
| `ACTOR-` | `concept` | `concept` (항상) |
| `MALWARE-` | `technique` | `concept` ("Ransomware" 같은 범주인 경우) |
| `DETECT-` | `pattern` | `concept` ("Network Detection" 같은 범주인 경우) |
| `PROTO-` | `protocol` | `concept` ("Transport Protocols" 같은 범주인 경우) |
| `PRI-` | `principle` | `concept` ("Security Principles" 같은 범주인 경우) |

**3B단계로 이동** (scope 배정).

### 3A단계: 좌표 배정 (INFRA- 전용)

3D 좌표를 배정한다:

**Layer 배정** — 질문: "이것은 배포 스택에서 어디에 위치하는가?"

| 질문 | Layer |
|------|-------|
| 우리가 통제하지 않는 외부 서비스인가? | L0 |
| 물리적 하드웨어인가? | L1 |
| 네트워크 트래픽을 라우팅/필터링하는가? | L2 |
| 컴퓨팅 리소스를 제공하는가 (VM, 클라우드)? | L3 |
| 배포/라이프사이클을 관리하는가 (CI/CD, IaC)? | L4 |
| 영구 데이터를 저장/처리하는가? | L5 |
| 실행 중인 애플리케이션을 호스팅하는가 (컨테이너, 런타임)? | L6 |
| 비즈니스 로직이나 사용자 인터페이스를 구현하는가? | L7 |
| 여러 계층에 걸쳐 있는가 (모니터링, 보안)? | Cross |

**Zone 배정** — 질문: "어떤 신뢰 경계에 있는가?"

| 질문 | Zone |
|------|------|
| 완전히 외부이며 인증되지 않은 것인가? | Z0A |
| 외부이지만 인증된 것인가 (SaaS, 파트너 API)? | Z0B |
| 외부 트래픽에 직접 노출된 우리 인프라인가? | Z1 |
| 비즈니스 로직 / 애플리케이션 서비스를 실행하는가? | Z2 |
| 영구적/민감한 데이터를 저장 또는 처리하는가? | Z3 |
| 관리/운영/모니터링 시스템인가? | Z4 |
| 사용자 단말 (노트북, 워크스테이션, 모바일)인가? | Z5 |

**Function 배정** — 질문: "주요 기능은 무엇인가?"
- `02_framework/GR_3D_FRAMEWORK.md`의 Function Code 계층 구조를 참조한다
- 하나의 주요 function 코드를 배정한다 (예: 관계형 저장소의 경우 `D1.3`)
- 계층적 형식을 사용한다: `{Domain}{Category}.{Sequence}` — 단일 문자는 금지

**4단계로 이동**.

### 3B단계: Scope 배정 (INFRA- 이외 전용)

지식 atom에는 3D 좌표가 부여되지 않는다. 대신, 이 지식이 적용되는 인프라 맥락인 **scope**가 부여된다:

```yaml
scope:
  target_layers: [L2, L7]      # Which layers does this apply to?
  target_zones: [Z1, Z2]       # Which zones does this apply to?
  target_components: [INFRA-SEC-WAF-001, INFRA-APP-API-001]  # Specific components (optional)
```

**Scope 배정 규칙**:
1. `target_layers`: 이 지식이 관련되는 배포 계층은?
2. `target_zones`: 이 지식이 관련되는 보안 영역은?
3. `target_components`: 이것이 적용되는 특정 인프라 atom (선택 사항, 정밀한 연결을 위해)
4. target_layers 또는 target_zones 중 최소 하나는 반드시 채워져야 한다

**4단계로 이동**.

### 4단계: 추상화 수준

| 수준 | 명칭 | 기준 | 예시 |
|------|------|------|------|
| 4 | Principle | 보편적 진리, 철학 | Least Privilege, Defense in Depth |
| 3 | Concept | 범주 또는 분류 | Injection, Network Security |
| 2 | Technique | 실행 가능한 기법 또는 도구 | SQL Injection, WAF configuration |
| 1 | Instance | 특정 사례 또는 페이로드 | `' OR 1=1--`, CVE-2024-XXXX |

### 5단계: Atom Tag 배정

통제된 용어집 (`atom_tags.yaml`)에서 태그를 적용한다:

**5-질문 태그 배정**:
1. 관련된 **공격 단계**는? (RECON, INITIAL, EXEC, PERSIST, PRIV, EVADE, EXFIL, IMPACT)
2. 어떤 **기술 스택**인가? (WEB, API, CLOUD, CONTAINER, MOBILE, IOT, AI)
3. 어떤 **플랫폼**인가? (WINDOWS, LINUX, MACOS, AWS, AZURE, GCP)
4. 어떤 **취약점 유형**인가? (INJ, XSS, AUTHN, AUTHZ, CRYPTO, CONFIG, DESER)
5. 어떤 **방어/프로토콜**인가? (WAF, IDS, SIEM, EDR, HTTP, DNS, SSH, TLS)

**규칙**:
- 최소 2개, 최대 10개 태그
- `atom_tags.yaml`의 통제된 용어집에 있는 태그만 사용
- 자유 형식 태그는 금지

### 6단계: 관계 배정

기존 atom과의 관계를 식별한다:

**사용 가능한 관계 유형**:

| 범주 | 관계 | 설명 |
|------|------|------|
| 구조적 | `is_a`, `part_of`, `instance_of`, `abstracts` | 계층 구조 및 구성 |
| 인과적 | `causes`, `enables`, `prevents` | 원인과 결과 |
| 조건적 | `requires`, `conflicts_with`, `alternative_to` | 의존성 및 충돌 |
| 시간적 | `precedes`, `supersedes` | 시간 순서 |
| 적용성 | `applies_to`, `effective_against` | 적용 대상/범위 |
| 구현 | `implements` | 개념의 실현 |
| 인식론적 | `contradicts`, `disputes`, `refines` | 지식 관계 |

**관계 규칙**:
1. `related_to`는 **절대 금지** — 너무 모호하고 무한히 확장 가능
2. **정방향(canonical direction)**만 저장한다 (예: `is_a`를 저장, `has_subtype`은 저장하지 않음)
3. **대칭 관계** (`conflicts_with`, `alternative_to`, `contradicts`, `disputes`)는 한 번만 저장한다
4. `is_a`, `part_of`, `requires` 체인에서 **순환 참조 금지**
5. atom당 최소 **1개의 관계** — atom은 반드시 그래프에 연결되어야 한다
6. **역방향 관계**는 절대 저장하지 않는다 — 쿼리 시점에 계산한다

**정방향 참조표**:

| 저장 (정방향) | 계산 (역방향) |
|--------------|--------------|
| `is_a` | `has_subtype` |
| `part_of` | `has_part` |
| `instance_of` | `has_instance` |
| `causes` | `caused_by` |
| `enables` | `enabled_by` |
| `prevents` | `prevented_by` |
| `requires` | `required_by` |
| `applies_to` | `applied_by` |
| `effective_against` | `defended_by` |
| `implements` | `implemented_by` |
| `precedes` | `preceded_by` |
| `supersedes` | `superseded_by` |
| `abstracts` | `abstracted_by` |
| `refines` | `refined_by` |

### 7단계: ID 생성

**형식**: `{PREFIX}-{SUBDOMAIN}-{NAME}-{###}`

| 구성 요소 | 규칙 | 예시 |
|-----------|------|------|
| PREFIX | 12개 prefix 중 하나 | `ATK` |
| SUBDOMAIN | 도메인 범주 (대문자) | `INJECT` |
| NAME | 설명적 이름 (대문자) | `SQL` |
| ### | 3자리 순번 | `001` |

**전체 예시**: `ATK-INJECT-SQL-001`

**명명 규칙**:
- 모든 구성 요소는 대문자를 사용하고 하이픈으로 구분한다
- SUBDOMAIN은 **서브도메인 카탈로그** (Section 6)에 정의된 값만 사용한다
- NAME은 간결하고 설명적이어야 한다
- 순번은 고유한 PREFIX-SUBDOMAIN-NAME 조합마다 001부터 시작하여 증가한다

### 8단계: 정의 작성

모든 atom은 세 가지 정의 필드를 필요로 한다:

| 필드 | 내용 | 길이 |
|------|------|------|
| `what` | 이 atom이 무엇인지 — 사실적이고 객관적인 설명 | 500-800자 |
| `why` | 보안 맥락에서 왜 중요한지 | 200-500자 |
| `how` | 어떻게 작동하는지, 구현되는지, 사용되는지 | 300-600자 |

**규칙**:
- `what`은 필수 — 이것 없이는 atom이 존재할 수 없다
- `why`와 `how`는 강력히 권장되지만 차단 요건은 아니다
- AI 소비를 위해 작성한다: 정확하고, 구조적이며, 모호하지 않게
- 주관적 언어를 피한다 ("best", "should", "might")

### 9단계: 메타데이터 배정

```yaml
metadata:
  created: "YYYY-MM-DD"
  version: "1.0"
  confidence: high|medium|low
  trust_source: "primary|secondary|derived"
  sources:
    - "Source 1 reference"
    - "Source 2 reference"
  search_keywords:
    - keyword1
    - keyword2
    - keyword3
    - keyword4
    - keyword5
  embedding_text: "50-200 word summary for vector embedding"
```

**규칙**:
- 최소 1개의 출처가 필요하다
- 최소 5개의 검색 키워드
- embedding_text: 50-200 단어, 시맨틱 검색에 최적화
- confidence: `high` (검증됨, 다수의 출처), `medium` (단일 출처, 논리적), `low` (추론)

### 10단계: 최종 검증

Engine B 명세서의 18개 항목 검증 체크리스트를 실행한다. 모든 CRITICAL 항목을 반드시 통과해야 한다.

---

## 3. Prefix-디렉토리 매핑 (절대 규칙)

| Prefix | 디렉토리 | is_infrastructure | 기본 Type |
|--------|----------|-------------------|-----------|
| `INFRA-` | `atom_data/INFRA/` | `true` | component |
| `ATK-` | `atom_data/ATK/` | `false` | technique |
| `DEF-` | `atom_data/DEF/` | `false` | control_policy |
| `VUL-` | `atom_data/VUL/` | `false` | vulnerability |
| `TOOL-` | `atom_data/TOOL/` | `false` | tool_knowledge |
| `COMP-` | `atom_data/COMP/` | `false` | control_policy |
| `TECH-` | `atom_data/TECH/` | `false` | concept |
| `ACTOR-` | `atom_data/ACTOR/` | `false` | concept |
| `MALWARE-` | `atom_data/MALWARE/` | `false` | technique |
| `DETECT-` | `atom_data/DETECT/` | `false` | pattern |
| `PROTO-` | `atom_data/PROTO/` | `false` | protocol |
| `PRI-` | `atom_data/PRI/` | `false` | principle |

**이 매핑은 절대적이다. Prefix 변경은 메이저 버전 업데이트(v6.0 등)를 통해서만 가능하며, 기존 atom의 prefix는 소급 변경되지 않는다.**

---

## 4. 완전한 분류 예시

### 예시 1: WAF (Web Application Firewall)

**배포된 어플라이언스인 경우**:
```yaml
id: INFRA-SEC-WAF-001
is_infrastructure: true
type: component_control
gr_coordinates:
  layer: L2
  zone: Z1
  function: "S1.2"
atom_tags: [WEB, HTTP, WAF]
```

**방어 지식인 경우**:
```yaml
id: DEF-APPDEF-WAF-RULES-001
is_infrastructure: false
type: control_policy
scope:
  target_layers: [L2]
  target_zones: [Z1]
  target_components: [INFRA-SEC-WAF-001]
atom_tags: [WEB, HTTP, WAF, INJ, XSS]
```

### 예시 2: SQL Injection

**공격 기법인 경우**:
```yaml
id: ATK-INJECT-SQL-001
is_infrastructure: false
type: technique
abstraction_level: 2
scope:
  target_layers: [L5, L7]
  target_zones: [Z2, Z3]
atom_tags: [WEB, API, INJ, EXEC]
relations:
  - type: is_a
    target: ATK-INJECT-OVERVIEW-001
  - type: applies_to
    target: INFRA-DATA-POSTGRESQL-001
  - type: requires
    target: VUL-INJECT-CWE89-001
```

### 예시 3: Zero Trust

**원칙인 경우**:
```yaml
id: PRI-ZEROTRUST-001
is_infrastructure: false
type: principle
abstraction_level: 4
scope:
  target_layers: [L0, L1, L2, L3, L4, L5, L6, L7]
  target_zones: [Z0A, Z0B, Z1, Z2, Z3, Z4, Z5]
atom_tags: [AUTHN, AUTHZ]
```

### 예시 4: Sigma Rule (탐지)

**탐지 패턴인 경우**:
```yaml
id: DETECT-SIGNATURE-PSEXEC-001
is_infrastructure: false
type: pattern
abstraction_level: 1
scope:
  target_layers: [L3, L7]
  target_zones: [Z2, Z4, Z5]
atom_tags: [WINDOWS, EXEC, PRIV, EVADE]
relations:
  - type: effective_against
    target: ATK-LATERAL-PSEXEC-001
    description: "PsExec 횡적 이동 공격을 탐지"
```

---

## 5. 금지 항목 (절대 규칙)

| 금지 항목 | 사유 | 올바른 대안 |
|-----------|------|------------|
| `related_to` 관계 | 너무 모호하고 무한 확장 가능 | 구체적인 관계 유형을 사용 |
| 단일 문자 Function 코드 (`S`, `A`) | 모호함 | 계층적 형식 `S1.2`, `A1.5`를 사용 |
| `type: control` | 더 이상 사용되지 않음 | `component_control` 또는 `control_policy`를 사용 |
| `type: tool` | 더 이상 사용되지 않음 | `component_tool` 또는 `tool_knowledge`를 사용 |
| 자유 형식 atom_tags | 일관성 없음 | 통제된 용어집만 사용 |
| INFRA- 이외 atom에 `function` 사용 | 유효하지 않음 | `scope`를 대신 사용 |
| INFRA- atom에 `scope` 사용 | 유효하지 않음 | `gr_coordinates`를 대신 사용 |
| 역방향 관계 저장 | 중복 | 쿼리 시점에 계산 |
| 순환 참조 | 논리적 오류 | 저장 전에 검증 |

---

## 6. 서브도메인 카탈로그

서브도메인은 atom ID의 두 번째 구성 요소로, 각 prefix 내에서 항목의 **본질적 성격/방법**을 기준으로 분류한다.

### ATK (공격 기법) — 19개 서브도메인

| 서브도메인 | 설명 | 예시 |
|-----------|------|------|
| `INJECT` | 코드/명령 주입 공격 | SQL Injection, Command Injection, LDAP Injection |
| `CRED` | 인증정보 탈취/공격 | Credential Stuffing, Password Spraying, Brute Force |
| `EXEC` | 코드/명령 실행 | Remote Code Execution, Arbitrary Code Execution |
| `MEMORY` | 메모리 기반 공격 | Buffer Overflow, Heap Spray, Use-After-Free |
| `EVASION` | 탐지 회피 기법 | Obfuscation, Living-off-the-Land, Log Tampering |
| `PRIVESC` | 권한 상승 | Kernel Exploit, Token Manipulation, DLL Hijacking |
| `PERSIST` | 지속성 확보 | Registry Run Key, Scheduled Task, Implant |
| `LATERAL` | 횡적 이동 | Pass-the-Hash, PsExec, RDP Hijacking |
| `RECON` | 정찰/정보수집 | Port Scanning, OSINT, Service Enumeration |
| `PHISH` | 사회공학/피싱 | Spear Phishing, Vishing, Pretexting |
| `EXFIL` | 데이터 유출 | DNS Tunneling, Steganography, Covert Channel |
| `NETWORK` | 네트워크 기반 공격 | MITM, ARP Spoofing, DNS Poisoning |
| `WEB` | 웹 애플리케이션 공격 | XSS, CSRF, SSRF, Path Traversal |
| `CRYPTO` | 암호화 공격 | Padding Oracle, Birthday Attack, Key Recovery |
| `SUPPLY` | 공급망 공격 | Dependency Confusion, Typosquatting, Build Compromise |
| `WIRELESS` | 무선/RF 공격 | Evil Twin, Deauth, Bluetooth Exploit |
| `CLOUD` | 클라우드 특화 공격 | SSRF to Metadata, IAM Abuse, Container Escape |
| `AIML` | AI/ML 대상 공격 | Adversarial Examples, Model Poisoning, Prompt Injection |
| `MITRE` | MITRE ATT&CK 기법 | T1059, T1566, T1021 (ATT&CK Technique ID 보존) |

### MALWARE (악성 소프트웨어) — 11개 서브도메인

| 서브도메인 | 설명 | 예시 |
|-----------|------|------|
| `RAT` | 원격 접근 트로이목마 | DarkComet, Gh0st RAT, Quasar |
| `RANSOM` | 랜섬웨어 | LockBit, REvil, Conti |
| `STEALER` | 정보 탈취형 | RedLine, Raccoon, Vidar |
| `LOADER` | 로더/드롭퍼 | Emotet (loader), BazarLoader, IcedID |
| `BACKDOOR` | 백도어 | ShadowPad, SUNBURST, Cobalt Strike Beacon |
| `WIPER` | 와이퍼/파괴형 | NotPetya, WhisperGate, HermeticWiper |
| `BOTNET` | 봇넷 | Mirai, Emotet (botnet), TrickBot |
| `SPYWARE` | 스파이웨어 | Pegasus, FinFisher, Predator |
| `BANKER` | 금융 악성코드 | Zeus, Dridex, QakBot |
| `MINER` | 크립토마이너 | XMRig, Coinhive, LemonDuck |
| `EXPLOITKIT` | 익스플로잇 킷 | Angler, RIG, Magnitude |

### TOOL (보안 도구) — 11개 서브도메인

| 서브도메인 | 설명 | 예시 |
|-----------|------|------|
| `OFFENSIVE` | 공격/침투 도구 | Metasploit, Cobalt Strike, Empire |
| `SCANNER` | 취약점 스캐너 | Nessus, OpenVAS, Qualys |
| `RECON` | 정찰/OSINT 도구 | Shodan, Maltego, theHarvester |
| `PENTEST` | 침투테스트 도구 | Burp Suite, OWASP ZAP, sqlmap |
| `CRED` | 크레덴셜 도구 | Hashcat, John the Ripper, Mimikatz |
| `FORENSIC` | 포렌식/IR 도구 | Autopsy, Volatility, FTK |
| `REVERSE` | 리버스 엔지니어링 도구 | IDA Pro, Ghidra, x64dbg |
| `NETMON` | 네트워크 모니터링 도구 | Wireshark, tcpdump, Zeek |
| `DEFENSE` | 방어/보안 운영 도구 | YARA, Sigma, Snort (규칙 작성 도구) |
| `SYSUTIL` | 시스템 유틸리티 (보안 관련) | Sysinternals, PsExec, CyberChef |
| `CLOUD` | 클라우드 보안 도구 | ScoutSuite, Prowler, CloudSploit |

### DEF (방어 기법) — 9개 서브도메인

| 서브도메인 | 설명 | 예시 |
|-----------|------|------|
| `ACCESS` | 접근 통제 | RBAC, MAC, Zero Trust Architecture |
| `NETWORK` | 네트워크 방어 | Segmentation, Firewall Rules, IPS Policy |
| `ENDPOINT` | 엔드포인트 방어 | EDR Policy, Application Whitelisting, Host Hardening |
| `DATA` | 데이터 보호 | Encryption at Rest, DLP Policy, Backup Strategy |
| `APPDEF` | 애플리케이션 보안 | Input Validation, CSP, Secure Coding Guidelines |
| `MONITOR` | 모니터링/로깅 | SIEM Rules, Log Aggregation, Alert Tuning |
| `HARDEN` | 시스템 강화 | CIS Benchmarks, Patch Management, Configuration Baseline |
| `CLOUD` | 클라우드 보안 정책 | IAM Policy, Security Groups, Cloud Posture Management |
| `DECEPTION` | 기만 방어 | Honeypot, Honeytoken, Canary |

### VUL (취약점) — 9개 서브도메인

| 서브도메인 | 설명 | 예시 |
|-----------|------|------|
| `INJECT` | 주입 취약점 | CWE-89 (SQLi), CWE-78 (OS Command), CWE-90 (LDAP) |
| `MEMORY` | 메모리 취약점 | CWE-120 (Buffer Overflow), CWE-416 (Use-After-Free) |
| `AUTH` | 인증/인가 취약점 | CWE-287 (Improper Auth), CWE-862 (Missing Authz) |
| `CONFIG` | 설정 오류 | CWE-16 (Configuration), Misconfigured Permissions |
| `CRYPTO` | 암호화 취약점 | CWE-327 (Broken Crypto), CWE-330 (Insufficient Randomness) |
| `LOGIC` | 로직 취약점 | CWE-840 (Business Logic), Race Condition, TOCTOU |
| `DESER` | 역직렬화 취약점 | CWE-502 (Deserialization), Insecure Object Handling |
| `INFO` | 정보 노출 | CWE-200 (Information Exposure), CWE-209 (Error Message) |
| `ACCESS` | 접근 통제 취약점 | CWE-284 (Improper Access Control), IDOR, Path Traversal |

### TECH (기술 개념) — 9개 서브도메인

| 서브도메인 | 설명 | 예시 |
|-----------|------|------|
| `CRYPTO` | 암호학 개념 | AES, RSA, PKI, Hash Functions |
| `ARCH` | 아키텍처/설계 패턴 | Microservices Security, API Gateway, Service Mesh |
| `DATA` | 데이터 기술 개념 | Data Classification, Tokenization, Anonymization |
| `ML` | AI/ML 보안 개념 | Federated Learning, Differential Privacy, Model Security |
| `OS` | 운영체제 보안 개념 | Kernel Security, SELinux, Sandboxing |
| `NET` | 네트워크 기술 개념 | SDN, Network Virtualization, Traffic Analysis |
| `AUTH` | 인증/인가 기술 개념 | OAuth 2.0, SAML, FIDO2, Kerberos |
| `DEVSEC` | DevSecOps 개념 | SAST, DAST, SCA, CI/CD Security |
| `GENERAL` | 기타 일반 기술 개념 | Encoding, Serialization, Virtualization |

### INFRA (인프라) — 8개 서브도메인

| 서브도메인 | 설명 | 예시 |
|-----------|------|------|
| `NET` | 네트워크 장비 | Router, Switch, Load Balancer, VPN Gateway |
| `SEC` | 보안 장비/어플라이언스 | Firewall, WAF, IDS/IPS, HSM |
| `DATA` | 데이터 저장소 | PostgreSQL, Redis, Elasticsearch, S3 |
| `APP` | 애플리케이션 서버 | Web Server, API Gateway, Application Server |
| `COMPUTE` | 컴퓨팅 리소스 | VM, Container Host, Serverless Runtime |
| `IDENTITY` | ID/인증 인프라 | Active Directory, LDAP Server, PKI CA |
| `ENDPOINT` | 엔드포인트 장치 | Workstation, Mobile Device, IoT Device |
| `DEVOPS` | DevOps 인프라 | CI/CD Server, Registry, IaC Platform |

### PROTO (프로토콜) — 7개 서브도메인

| 서브도메인 | 설명 | 예시 |
|-----------|------|------|
| `TRANSPORT` | 전송 프로토콜 | TCP, UDP, QUIC, SCTP |
| `SECURITY` | 보안 프로토콜 | TLS, IPSec, WireGuard, SSH |
| `AUTH` | 인증 프로토콜 | RADIUS, TACACS+, EAP, 802.1X |
| `ROUTING` | 라우팅 프로토콜 | BGP, OSPF, VXLAN |
| `MSG` | 메시징/애플리케이션 프로토콜 | HTTP, MQTT, gRPC, WebSocket |
| `NAMING` | 이름 해석 프로토콜 | DNS, mDNS, LLMNR |
| `INDUSTRIAL` | 산업 프로토콜 | Modbus, OPC UA, DNP3, BACnet |

### DETECT (탐지) — 6개 서브도메인

| 서브도메인 | 설명 | 예시 |
|-----------|------|------|
| `SIGNATURE` | 시그니처 기반 탐지 | Snort Rules, YARA Rules, Suricata Signatures |
| `BEHAVIOR` | 행위 기반 탐지 | UEBA, Anomaly Detection, Baseline Deviation |
| `NETWORK` | 네트워크 탐지 | NetFlow Analysis, DNS Monitoring, Traffic Pattern |
| `ENDPOINT` | 엔드포인트 탐지 | Sysmon Rules, EDR Detection Logic, Process Monitoring |
| `LOG` | 로그 기반 탐지 | Sigma Rules, Log Correlation, SIEM Analytics |
| `IOC` | 침해 지표 | IP/Domain/Hash IOC, Certificate Fingerprint |

### ACTOR (행위자) — 5개 서브도메인

| 서브도메인 | 설명 | 예시 |
|-----------|------|------|
| `APT` | 국가 지원 위협 그룹 | APT28, Lazarus Group, APT41 |
| `CRIME` | 사이버 범죄 그룹 | FIN7, Conti Group, REvil Operators |
| `HACKTIVIST` | 핵티비스트/독립 행위자 | Anonymous, LulzSec |
| `VENDOR` | 보안 벤더/기업 | CrowdStrike, Mandiant, Palo Alto Networks |
| `RESEARCH` | 연구기관/CERT | MITRE, NIST, KISA, FIRST |

### COMP (컴플라이언스) — 3개 서브도메인

| 서브도메인 | 설명 | 예시 |
|-----------|------|------|
| `LAW` | 법률/규정 | GDPR, HIPAA, 개인정보보호법 |
| `STANDARD` | 산업 표준 | ISO 27001, PCI DSS, SOC 2 |
| `FRAMEWORK` | 보안 프레임워크 | NIST CSF, CIS Controls, OWASP Top 10 |

### PRI (보안 원칙) — 플랫 구조

PRI prefix는 항목이 소수(~10개)이므로 서브도메인 없이 직접 명명한다.

**예시**: `PRI-LEASTPRIV-001`, `PRI-DEFINDEPTH-001`, `PRI-ZEROTRUST-001`

---

## 7. 서브도메인 확장 원칙

1. **기존 서브도메인은 유지된다**: 한번 정의된 서브도메인은 삭제하지 않는다. 기존 atom ID의 안정성을 보장한다.
2. **새 항목은 기존 서브도메인에 분류한다**: 새로운 atom은 가장 적합한 기존 서브도메인에 배정한다.
3. **신규 서브도메인 추가 조건**: 기존 서브도메인 어디에도 논리적으로 맞지 않는 본질적으로 새로운 범주가 등장할 때만 추가한다.
4. **Prefix 변경**: Prefix 체계의 변경은 메이저 버전 업데이트(v6.0 등)를 통해서만 가능하다. 기존 atom의 prefix는 소급 변경되지 않는다.
5. **데이터 주도가 아닌 본질 주도**: 서브도메인은 항목 수의 분포가 아니라, 해당 영역의 본질적 분류 기준에 의해 결정된다.

---

*문서 버전: v5.1 | 최종 업데이트: 2026-02-06*
