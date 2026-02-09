# 07_raw_sources — 원자화 원재료 저장소

> 수집일: 2026-02-05
> 
> 이 디렉토리는 원자화(atomization) 전 원재료(raw) 데이터를 저장합니다.
> 분류 규칙 확정 후 이 데이터를 기반으로 원자화를 수행합니다.

---

## 수집 현황

### structured/ — 구조화된 소스

| 소스 | 파일 | 크기 | 항목 수 | 라이선스 |
|------|------|------|---------|---------|
| **MITRE ATT&CK Enterprise** | enterprise-attack.json (STIX 2.1) | 44MB | 기법 835, 관계 20,048, 전체 24,771 | Apache 2.0 |
| **MITRE ATT&CK Mobile** | mobile-attack.json | 4.2MB | — | Apache 2.0 |
| **MITRE ATT&CK ICS** | ics-attack.json | 3.0MB | — | Apache 2.0 |
| **MITRE D3FEND** | d3fend.json (JSON-LD) | 4.3MB | 7,172 그래프 노드 | Apache 2.0 |
| **MITRE CWE** | cwec_v4.19.1.xml | 16MB | 969 취약점 유형 | 공개 |
| **MITRE CAPEC** | capec_latest.xml | 3.7MB | 615 공격 패턴 | 공개 |
| **NIST SP 800-53 Rev5** | nist_sp800-53_rev5.json (OSCAL) | 10MB | 20 패밀리, 1,196 통제 | 공개 |
| **OWASP Top 10 (2021)** | A01~A10 .md | ~17KB | 10 카테고리 | CC BY-SA 4.0 |
| **OWASP API Top 10 (2023)** | api_0xa1~0xa10 .md | ~57KB | 10 카테고리 | CC BY-SA 4.0 |

### unstructured/ — 비구조화 소스 (수집 예정)

| 폴더 | 용도 | 상태 |
|------|------|------|
| textbooks/ | 보안 교과서 발췌 | 대기 |
| papers/ | 학술 논문 | 대기 |
| rfc/ | RFC 프로토콜 표준 | 대기 |
| vendor/ | 벤더 기술 문서 | 대기 |

---

## 원재료 → 원자화 파이프라인

```
Raw Source → 파싱/추출 → 분류 규칙 적용 → 원자 YAML 생성 → 04_knowledge_base/
```

## 대용량 파일 (Git 미포함)

아래 파일은 용량 문제로 Git에 포함되지 않습니다.
로컬에서 아래 명령으로 다운로드하세요:

```bash
# MITRE ATT&CK (Enterprise / Mobile / ICS)
curl -sL "https://raw.githubusercontent.com/mitre/cti/master/enterprise-attack/enterprise-attack.json" -o structured/mitre_attack/enterprise-attack.json   # 44MB
curl -sL "https://raw.githubusercontent.com/mitre/cti/master/mobile-attack/mobile-attack.json" -o structured/mitre_attack/mobile-attack.json               # 4.2MB
curl -sL "https://raw.githubusercontent.com/mitre/cti/master/ics-attack/ics-attack.json" -o structured/mitre_attack/ics-attack.json                         # 3.0MB

# MITRE D3FEND
curl -sL "https://d3fend.mitre.org/ontologies/d3fend.json" -o structured/mitre_defend/d3fend.json   # 4.3MB

# MITRE CWE
curl -sL "https://cwe.mitre.org/data/xml/cwec_latest.xml.zip" -o structured/mitre_cwe/cwec_latest.xml.zip   # 1.8MB (압축 해제 시 16MB)

# MITRE CAPEC
curl -sL "https://capec.mitre.org/data/xml/capec_latest.xml" -o structured/mitre_capec/capec_latest.xml   # 3.7MB

# NIST SP 800-53 Rev5
curl -sL "https://raw.githubusercontent.com/usnistgov/oscal-content/main/nist.gov/SP800-53/rev5/json/NIST_SP-800-53_rev5_catalog.json" -o structured/nist/nist_sp800-53_rev5.json   # 10MB
```

| 파일 | 크기 | 항목 수 |
|------|------|---------|
| enterprise-attack.json | 44MB | 기법 835, 전체 24,771 객체 |
| mobile-attack.json | 4.2MB | — |
| ics-attack.json | 3.0MB | — |
| d3fend.json | 4.3MB | 7,172 그래프 노드 |
| cwec_latest.xml.zip → cwec_v4.19.1.xml | 1.8MB → 16MB | 969 취약점 유형 |
| capec_latest.xml | 3.7MB | 615 공격 패턴 |
| nist_sp800-53_rev5.json | 10MB | 20 패밀리, 1,196 통제 |

### 추가 다운로드 (2차 수집)

```bash
# OWASP Cheat Sheet Series (109개 md)
git clone --depth 1 https://github.com/OWASP/CheatSheetSeries.git /tmp/cs && cp /tmp/cs/cheatsheets/*.md structured/owasp_cheatsheet/

# OWASP WSTG (156개 md)
git clone --depth 1 https://github.com/OWASP/wstg.git /tmp/wstg && cp -r /tmp/wstg/document/* structured/owasp_wstg/

# Sigma Rules (3,104개 yml)
curl -sL "https://github.com/SigmaHQ/sigma/archive/refs/heads/master.zip" -o structured/sigma/sigma-master.zip

# Atomic Red Team (328 ATT&CK 기법, 660 파일)
curl -sL "https://github.com/redcanaryco/atomic-red-team/archive/refs/heads/master.zip" -o structured/atomic_redteam/atomic-red-team-master.zip

# LOLBAS (230 Windows 바이너리)
curl -sL "https://github.com/LOLBAS-Project/LOLBAS/archive/refs/heads/master.zip" -o structured/lolbas/lolbas-master.zip

# GTFOBins (468 Linux 바이너리)
curl -sL "https://github.com/GTFOBins/GTFOBins.github.io/archive/refs/heads/master.zip" -o structured/gtfobins/gtfobins-master.zip

# MITRE ATLAS (AI/ML 보안)
curl -sL "https://github.com/mitre-atlas/atlas-data/archive/refs/heads/main.zip" -o structured/mitre_atlas/atlas-data.zip

# RFC 핵심 프로토콜 (24개)
for rfc in 2616 7230 7231 7540 9110 8446 5246 4346 1035 8484 2821 5321 4511 4120 6749 7519 7617 793 768 791 792 826 2460 5905; do
  curl -sL "https://www.rfc-editor.org/rfc/rfc${rfc}.txt" -o structured/rfc/rfc${rfc}.txt
done
```

| 소스 | 파일 수 | 내용 |
|------|---------|------|
| OWASP Cheat Sheet Series | 109 | 방어 실무 가이드 |
| OWASP WSTG | 156 | 웹 보안 테스팅 가이드 |
| Sigma Rules | 3,104 | 탐지 시그니처 규칙 |
| Atomic Red Team | 660 | ATT&CK 기법별 테스트 (328 기법) |
| LOLBAS | 230 | Windows 합법 바이너리 악용 |
| GTFOBins | 468 | Linux 합법 바이너리 악용 |
| MITRE ATLAS | 54 | AI/ML 보안 위협 + 완화 + 케이스스터디 |
| RFC 핵심 프로토콜 | 24 | HTTP, TLS, DNS, TCP, OAuth 등 |
| SANS/CWE Top 25 | 1 | 위험한 소프트웨어 결함 |
| CSA Top Threats | 1 | 클라우드 보안 위협 |
| NVD/CVE | API | 331,213개 접근 가능 (샘플 포함) |
| OWASP Mobile Top 10 | 1 | 모바일 보안 2024 |
| OWASP ML Top 10 | 1 | ML 보안 위협 |

---

## 주의사항
- 라이선스 조건 준수 필수
- 원본 데이터 수정 금지 (읽기 전용 취급)
- 대용량 파일은 .gitignore에 의해 Git 미포함 (위 명령으로 로컬 다운로드)
