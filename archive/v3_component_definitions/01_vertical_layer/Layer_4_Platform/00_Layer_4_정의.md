# Layer 4: Platform Services (플랫폼 서비스)

## 📋 Layer 정보

| 속성 | 값 |
|------|-----|
| **Layer 번호** | 4 |
| **한글명** | 플랫폼 서비스 |
| **영문명** | Platform Services |
| **변경 빈도** | High (주 단위) |
| **복잡도** | Medium-High |
| **다이어그램 위치** | 중단 (Layer 3 위) |

---

## 🎯 정의

Layer 4는 **애플리케이션 개발, 배포, 관리를 지원하는 플랫폼 서비스 계층**입니다.

### 핵심 역할

1. **개발 지원**
   - 소스 코드 관리
   - 빌드 및 패키징
   - 의존성 관리

2. **배포 자동화**
   - CI/CD 파이프라인
   - 인프라 프로비저닝
   - GitOps 워크플로우

3. **아티팩트 관리**
   - 컨테이너 이미지 저장
   - 패키지 레지스트리
   - 버전 관리

---

## 🏗️ 주요 구성요소

Layer 4는 다음 6개 주요 구성요소로 분류됩니다:

| 번호 | 구성요소 | 설명 | 문서 링크 |
|------|---------|------|-----------|
| 1 | **CI/CD** | 지속적 통합/배포 파이프라인 | [상세 문서](01_CICD/00_CICD_정의.md) |
| 2 | **Version Control** | 소스 코드 버전 관리 | [상세 문서](02_Version_Control/00_Version_Control_정의.md) |
| 3 | **IaC** | 인프라스트럭처 코드화 | [상세 문서](03_IaC/00_IaC_정의.md) |
| 4 | **GitOps** | Git 기반 운영 자동화 | [상세 문서](04_GitOps/00_GitOps_정의.md) |
| 5 | **Container Registry** | 컨테이너 이미지 저장소 | [상세 문서](05_Container_Registry/00_Container_Registry_정의.md) |
| 6 | **Build System** | 빌드 및 패키징 시스템 | [상세 문서](06_Build_System/00_Build_System_정의.md) |

---

## 🔒 Zone별 배치 개요

| Zone | 배치 빈도 | 주요 구성요소 |
|------|----------|-----------------|
| **Zone 2** | Common | CI/CD Workers, Build Agents |
| **Zone 4** | Very Common | Git Server, Registry, Management Tools |

---

## 📊 Layer 특성

### 변경 관리

- **변경 빈도**: 주 단위
- **변경 유형**: 파이프라인 업데이트, 도구 버전 업그레이드, 정책 변경
- **영향도**: 중-높음 (개발/배포 프로세스 영향)

### 의존성

**하위 Layer 의존**:
- Layer 1 (Physical Infrastructure)
- Layer 2 (Network Infrastructure)
- Layer 3 (Computing Infrastructure)

**상위 Layer 지원**:
- Layer 5 (Data)
- Layer 6 (Runtime)
- Layer 7 (Application)

---

## ⚡ 실무 고려사항

### 1. DevOps 성숙도

```yaml
Level 1 (수동):
  - 수동 빌드 및 배포
  - 로컬 개발 환경
  - 도구: 없음

Level 2 (기본 자동화):
  - 기본 CI/CD 파이프라인
  - Git 기반 협업
  - 도구: Jenkins, GitLab, Docker

Level 3 (통합 자동화):
  - 완전 자동화 파이프라인
  - IaC 도입
  - 도구: GitHub Actions, Terraform, ArgoCD

Level 4 (고급):
  - GitOps 워크플로우
  - 정책 자동화 (Policy as Code)
  - 도구: Flux, Crossplane, OPA
```

---

### 2. 보안 및 규정 준수

```yaml
필수 요구사항:
  - 시크릿 관리 (Vault, AWS Secrets Manager)
  - 접근 제어 (RBAC, SSO)
  - 감사 로그 (Audit Trails)
  - 취약점 스캔 (Trivy, Snyk)

모범 사례:
  - 최소 권한 원칙
  - 시크릿 암호화
  - 코드 서명
  - SBOM (Software Bill of Materials)
```

---

### 3. 통합 및 확장

```yaml
통합 포인트:
  - 소스 코드 → Version Control
  - 빌드 → Build System
  - 테스트 → CI/CD
  - 배포 → GitOps
  - 이미지 → Container Registry

확장 전략:
  - 플러그인 시스템
  - API 통합
  - Webhook
  - 이벤트 기반 아키텍처
```

---

## 🔗 관련 문서

- [차원 1 개요](../00_차원1_개요.md)
- [Layer 3: Computing Infrastructure](../Layer_3_Compute/00_Layer_3_정의.md)
- [Layer 5: Data Services](../Layer_5_Data/00_Layer_5_정의.md)

---

**문서 끝**
