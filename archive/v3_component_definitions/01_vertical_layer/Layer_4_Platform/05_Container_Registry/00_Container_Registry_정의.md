# Container Registry (컨테이너 레지스트리)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Container Registry |
| **한글명** | 컨테이너 레지스트리 |
| **Layer** | Layer 4 (Platform Services) |
| **분류** | Artifact Repository |
| **Function Tag (Primary)** | P5.1 (Image Registry) |
| **Function Tag (Secondary)** | P5.2 (Artifact Storage) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

Container Registry는 **Docker 이미지를 저장, 관리, 배포하는 중앙 저장소**입니다.

### 핵심 기능

1. **이미지 저장**
   - 컨테이너 이미지 푸시/풀
   - 버전 관리 (태그)
   - Layer 캐싱

2. **보안**
   - 이미지 스캔 (취약점 검사)
   - 서명 및 검증
   - 접근 제어 (RBAC)

3. **배포 지원**
   - CI/CD 통합
   - Webhook
   - 복제 및 동기화

---

## 🏗️ Registry 아키텍처

### OCI (Open Container Initiative) 표준

```
OCI Distribution Spec:
- 표준화된 API
- 모든 OCI 호환 레지스트리에서 작동

이미지 구조:
[Image]
  ↓
[Manifest] (메타데이터)
  ↓
[Layers] (파일시스템 변경사항)
  - Layer 1: base OS
  - Layer 2: dependencies
  - Layer 3: application
```

---

## 🛠️ 주요 Container Registry

### 1. Docker Hub

**특징**:
- 가장 큰 Public Registry
- 공식 이미지 제공
- 무료 티어

**가격**:
```yaml
Free:
  - 무제한 Public 저장소
  - 1개 Private 저장소
  - 100 pulls/6시간

Pro: $5/month
  - 무제한 Private 저장소
  - 5000 pulls/day

Team: $7/user/month
  - 팀 협업
  - 무제한 pulls
```

**사용 예시**:
```bash
# 로그인
docker login

# 이미지 빌드 및 태그
docker build -t myusername/myapp:v1.0.0 .

# 이미지 푸시
docker push myusername/myapp:v1.0.0

# 이미지 풀
docker pull myusername/myapp:v1.0.0

# 태그 추가
docker tag myusername/myapp:v1.0.0 myusername/myapp:latest
docker push myusername/myapp:latest
```

---

### 2. Amazon ECR (Elastic Container Registry)

**특징**:
- AWS 네이티브
- IAM 통합
- 이미지 스캔 내장

**가격**:
```yaml
Storage: $0.10/GB/month
Data Transfer:
  - IN: 무료
  - OUT to Internet: $0.09/GB
  - OUT to AWS: 무료 (동일 리전)
```

**ECR 생성 및 사용**:
```bash
# ECR 저장소 생성
aws ecr create-repository \
  --repository-name myapp \
  --image-scanning-configuration scanOnPush=true \
  --region ap-northeast-2

# 로그인
aws ecr get-login-password --region ap-northeast-2 | \
  docker login --username AWS --password-stdin \
  123456789012.dkr.ecr.ap-northeast-2.amazonaws.com

# 이미지 빌드 및 태그
docker build -t myapp .
docker tag myapp:latest \
  123456789012.dkr.ecr.ap-northeast-2.amazonaws.com/myapp:latest

# 이미지 푸시
docker push 123456789012.dkr.ecr.ap-northeast-2.amazonaws.com/myapp:latest

# 이미지 풀
docker pull 123456789012.dkr.ecr.ap-northeast-2.amazonaws.com/myapp:latest

# 이미지 스캔
aws ecr start-image-scan \
  --repository-name myapp \
  --image-id imageTag=latest

# 스캔 결과 확인
aws ecr describe-image-scan-findings \
  --repository-name myapp \
  --image-id imageTag=latest
```

**Lifecycle Policy** (자동 정리):
```json
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 10 images",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["v"],
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 2,
      "description": "Delete untagged images older than 7 days",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 7
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
```

---

### 3. Google Container Registry (GCR) / Artifact Registry

**특징**:
- GCP 네이티브
- 다중 리전 복제
- Vulnerability Scanning

**가격**:
```yaml
Storage: $0.026/GB/month
Network:
  - Egress within GCP: 무료
  - Egress to Internet: $0.12/GB
```

**사용 예시**:
```bash
# GCR 로그인
gcloud auth configure-docker

# 이미지 빌드 및 태그
docker build -t myapp .
docker tag myapp gcr.io/my-project/myapp:v1.0.0

# 이미지 푸시
docker push gcr.io/my-project/myapp:v1.0.0

# 이미지 풀
docker pull gcr.io/my-project/myapp:v1.0.0

# 이미지 목록
gcloud container images list --repository=gcr.io/my-project

# 취약점 스캔
gcloud container images scan gcr.io/my-project/myapp:v1.0.0
gcloud container images describe gcr.io/my-project/myapp:v1.0.0 \
  --show-package-vulnerability
```

---

### 4. GitHub Container Registry (GHCR)

**특징**:
- GitHub 통합
- GitHub Actions 연동
- Public/Private 지원

**가격**:
```yaml
Storage:
  - Public: 무료
  - Private: GitHub 플랜에 포함

Data Transfer: 무료 (대부분)
```

**사용 예시**:
```bash
# GHCR 로그인
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# 이미지 빌드 및 태그
docker build -t myapp .
docker tag myapp ghcr.io/myorg/myapp:v1.0.0

# 이미지 푸시
docker push ghcr.io/myorg/myapp:v1.0.0

# 이미지 풀
docker pull ghcr.io/myorg/myapp:v1.0.0
```

**GitHub Actions 통합**:
```yaml
name: Build and Push

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - uses: actions/checkout@v3

      - name: Login to GHCR
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: |
            ghcr.io/${{ github.repository }}:latest
            ghcr.io/${{ github.repository }}:${{ github.sha }}
```

---

### 5. Harbor (자체 호스팅)

**특징**:
- 오픈소스
- 엔터프라이즈급 기능
- Helm Chart 지원

**설치** (Docker Compose):
```bash
# Harbor 다운로드
wget https://github.com/goharbor/harbor/releases/download/v2.8.0/harbor-offline-installer-v2.8.0.tgz
tar xzvf harbor-offline-installer-v2.8.0.tgz
cd harbor

# 설정
cp harbor.yml.tmpl harbor.yml

# harbor.yml 편집
# hostname: harbor.example.com
# harbor_admin_password: Harbor12345

# 설치
sudo ./install.sh

# 접속
# https://harbor.example.com
# admin / Harbor12345
```

**Harbor 기능**:
```yaml
프로젝트 관리:
  - Public/Private 프로젝트
  - 멤버 관리
  - RBAC

복제 (Replication):
  - 다중 레지스트리 간 동기화
  - Docker Hub, ECR, GCR 지원
  - 양방향 복제

취약점 스캔:
  - Trivy 통합
  - Clair 지원
  - 자동 스캔 정책

컨텐츠 신뢰:
  - Image 서명 (Notary)
  - Cosign 지원
```

---

## 🔐 보안

### 1. 이미지 스캔

**Trivy 사용**:
```bash
# 로컬 이미지 스캔
trivy image myapp:latest

# 원격 이미지 스캔
trivy image 123456789012.dkr.ecr.ap-northeast-2.amazonaws.com/myapp:latest

# CI/CD 통합
trivy image --exit-code 1 --severity HIGH,CRITICAL myapp:latest
```

**GitHub Actions 통합**:
```yaml
- name: Run Trivy vulnerability scanner
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: 'myapp:latest'
    format: 'sarif'
    output: 'trivy-results.sarif'
    severity: 'CRITICAL,HIGH'

- name: Upload Trivy results
  uses: github/codeql-action/upload-sarif@v2
  with:
    sarif_file: 'trivy-results.sarif'
```

---

### 2. 이미지 서명

**Docker Content Trust (Notary)**:
```bash
# Content Trust 활성화
export DOCKER_CONTENT_TRUST=1

# 서명된 이미지 푸시
docker push myusername/myapp:v1.0.0
# 서명 키 생성 프롬프트

# 검증된 이미지만 풀
docker pull myusername/myapp:v1.0.0
# 서명 검증 자동
```

**Cosign (Sigstore)**:
```bash
# Cosign 설치
brew install cosign

# 키 생성
cosign generate-key-pair

# 이미지 서명
cosign sign --key cosign.key \
  myregistry.io/myapp:v1.0.0

# 서명 검증
cosign verify --key cosign.pub \
  myregistry.io/myapp:v1.0.0
```

---

### 3. 접근 제어

**ECR IAM Policy**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
      ],
      "Resource": "arn:aws:ecr:ap-northeast-2:123456789012:repository/myapp"
    }
  ]
}
```

**Harbor RBAC**:
```yaml
프로젝트 역할:
  Project Admin:
    - 프로젝트 관리
    - 멤버 관리
    - 이미지 삭제

  Developer:
    - 이미지 푸시/풀
    - 태그 관리

  Guest:
    - 이미지 풀만 (Public 프로젝트)
```

---

## 📦 이미지 최적화

### 1. Multi-stage Build

```dockerfile
# Stage 1: Build
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Production
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
EXPOSE 3000
CMD ["node", "dist/index.js"]

# Before: 1.2GB
# After: 150MB
```

---

### 2. Layer 캐싱

```dockerfile
# ❌ 나쁜 예 (항상 재빌드)
COPY . /app
RUN npm install

# ✅ 좋은 예 (의존성 캐싱)
COPY package*.json /app/
RUN npm install
COPY . /app
```

---

### 3. .dockerignore

```
# .dockerignore
node_modules
npm-debug.log
.git
.gitignore
README.md
.env
*.test.js
coverage/
```

---

## 📊 레지스트리 선택 기준

| 요구사항 | 추천 Registry |
|---------|--------------|
| AWS 환경 | Amazon ECR |
| GCP 환경 | Google Artifact Registry |
| Azure 환경 | Azure Container Registry |
| GitHub 중심 | GitHub Container Registry |
| 멀티 클라우드 | Docker Hub, Harbor |
| 온프레미스 | Harbor, Nexus |
| 무료 Public | Docker Hub, GHCR |

---

## 🔒 Zone별 배치

| Zone | 배치 | 구성요소 |
|------|------|----------|
| **Zone 4** | Very Common | Container Registry (Harbor, Nexus) |
| **Zone 5** | Common | Cloud Registry (ECR, GCR, GHCR) |

---

## ⚡ 실무 고려사항

### 1. 이미지 태깅 전략

```yaml
Semantic Versioning:
  - myapp:1.2.3
  - myapp:1.2
  - myapp:1
  - myapp:latest

Git SHA:
  - myapp:abc123f
  - myapp:main-abc123f

환경별:
  - myapp:dev-abc123f
  - myapp:staging-v1.2.3
  - myapp:prod-v1.2.3

날짜:
  - myapp:2024-01-15
```

---

### 2. Cleanup Policy

```yaml
자동 정리:
  - 오래된 이미지 삭제 (30일+)
  - Untagged 이미지 삭제
  - 최신 N개만 유지

ECR Lifecycle Policy:
  - countType: imageCountMoreThan
  - countNumber: 10

Harbor:
  - Tag Retention Rules
  - 최근 30일 이미지 유지
```

---

### 3. 비용 최적화

```yaml
스토리지:
  - 불필요한 이미지 정리
  - 이미지 크기 최적화
  - Multi-stage build

네트워크:
  - 동일 리전 사용
  - 캐싱 활용
  - CDN 통합 (Public 이미지)
```

---

## 🔗 관련 문서

- [Layer 4 정의](../00_Layer_4_정의.md)
- [CI/CD](../01_CICD/00_CICD_정의.md)
- [GitOps](../04_GitOps/00_GitOps_정의.md)
- [Build System](../06_Build_System/00_Build_System_정의.md)

---

**문서 끝**
