# CI/CD (지속적 통합/배포)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | CI/CD |
| **한글명** | 지속적 통합/배포 |
| **Layer** | Layer 4 (Platform Services) |
| **분류** | Automation Platform |
| **Function Tag (Primary)** | P1.1 (Continuous Integration) |
| **Function Tag (Secondary)** | P1.2 (Continuous Deployment) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

CI/CD는 **소프트웨어 개발부터 배포까지 전 과정을 자동화하는 프랙티스 및 도구**입니다.

### 핵심 개념

1. **CI (Continuous Integration)**
   - 코드 변경사항을 자주 통합
   - 자동 빌드 및 테스트
   - 빠른 피드백

2. **CD (Continuous Delivery)**
   - 프로덕션 배포 준비 상태 유지
   - 수동 승인 후 배포
   - 배포 자동화

3. **CD (Continuous Deployment)**
   - 완전 자동 배포
   - 프로덕션까지 자동화
   - 지속적 릴리스

---

## 🏗️ CI/CD 파이프라인 단계

### 표준 파이프라인

```
[1. 소스 코드] → [2. 빌드] → [3. 테스트] → [4. 배포]
     ↓              ↓           ↓            ↓
   Git Push      Compile     Unit Test   Dev/Staging/Prod
                 Package   Integration     Auto/Manual
                           E2E Test
```

---

### 상세 단계

```yaml
1. Source Stage:
   - Git Clone
   - 의존성 체크아웃
   - 환경 변수 설정

2. Build Stage:
   - 코드 컴파일
   - 의존성 설치
   - 아티팩트 생성

3. Test Stage:
   - Unit Test
   - Integration Test
   - Code Coverage
   - Static Analysis

4. Security Stage:
   - 취약점 스캔
   - SAST (Static Application Security Testing)
   - Dependency Check

5. Package Stage:
   - Docker 이미지 빌드
   - 버전 태깅
   - Registry 푸시

6. Deploy Stage:
   - Development
   - Staging
   - Production (승인 필요)
```

---

## 🛠️ 주요 CI/CD 도구

### 1. Jenkins

**특징**:
- 오픈소스 CI/CD 도구
- 플러그인 생태계 (1800+)
- 자체 호스팅

**설치** (Docker):
```bash
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts
```

**Jenkinsfile 예시**:
```groovy
pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'docker.io'
        IMAGE_NAME = 'myapp'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/myorg/myapp.git'
            }
        }

        stage('Build') {
            steps {
                sh 'npm install'
                sh 'npm run build'
            }
        }

        stage('Test') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh 'npm test'
                    }
                }
                stage('Lint') {
                    steps {
                        sh 'npm run lint'
                    }
                }
            }
        }

        stage('Security Scan') {
            steps {
                sh 'npm audit'
                sh 'trivy fs .'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", 'docker-creds') {
                        docker.image("${IMAGE_NAME}:${IMAGE_TAG}").push()
                        docker.image("${IMAGE_NAME}:${IMAGE_TAG}").push('latest')
                    }
                }
            }
        }

        stage('Deploy to Dev') {
            steps {
                sh '''
                    kubectl set image deployment/myapp \
                      myapp=${IMAGE_NAME}:${IMAGE_TAG} \
                      -n development
                '''
            }
        }

        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to Production?', ok: 'Deploy'
                sh '''
                    kubectl set image deployment/myapp \
                      myapp=${IMAGE_NAME}:${IMAGE_TAG} \
                      -n production
                '''
            }
        }
    }

    post {
        success {
            slackSend color: 'good', message: "Build ${env.BUILD_NUMBER} succeeded"
        }
        failure {
            slackSend color: 'danger', message: "Build ${env.BUILD_NUMBER} failed"
        }
    }
}
```

---

### 2. GitHub Actions

**특징**:
- GitHub 통합
- YAML 기반 워크플로우
- 무료 티어 (2000분/월)

**워크플로우 예시** (`.github/workflows/ci.yml`):
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: '18'
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run linter
        run: npm run lint

      - name: Run tests
        run: npm test

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info

  security:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'

      - name: Upload Trivy results
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'

  build-and-push:
    needs: [test, security]
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Log in to Container registry
        uses: docker/login-action@v2
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v4
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=sha,prefix={{branch}}-

      - name: Build and push Docker image
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}

  deploy-dev:
    needs: build-and-push
    runs-on: ubuntu-latest
    environment: development

    steps:
      - name: Deploy to Kubernetes
        uses: azure/k8s-deploy@v4
        with:
          manifests: |
            k8s/deployment.yaml
            k8s/service.yaml
          images: |
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
          namespace: development

  deploy-prod:
    needs: build-and-push
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://myapp.com

    steps:
      - name: Deploy to Production
        uses: azure/k8s-deploy@v4
        with:
          manifests: |
            k8s/deployment.yaml
            k8s/service.yaml
          images: |
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
          namespace: production
```

---

### 3. GitLab CI/CD

**특징**:
- GitLab 통합
- `.gitlab-ci.yml` 기반
- Auto DevOps

**`.gitlab-ci.yml` 예시**:
```yaml
stages:
  - build
  - test
  - security
  - package
  - deploy

variables:
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: "/certs"
  IMAGE_TAG: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA

build:
  stage: build
  image: node:18
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 hour
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - node_modules/

test:unit:
  stage: test
  image: node:18
  script:
    - npm ci
    - npm test
  coverage: '/All files[^|]*\|[^|]*\s+([\d\.]+)/'
  artifacts:
    reports:
      junit: junit.xml
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml

test:lint:
  stage: test
  image: node:18
  script:
    - npm ci
    - npm run lint

security:sast:
  stage: security
  image: returntocorp/semgrep
  script:
    - semgrep --config=auto --json --output=sast-report.json .
  artifacts:
    reports:
      sast: sast-report.json

security:dependency:
  stage: security
  image: node:18
  script:
    - npm audit --json > dependency-scan.json || true
  artifacts:
    reports:
      dependency_scanning: dependency-scan.json

package:
  stage: package
  image: docker:latest
  services:
    - docker:dind
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - docker build -t $IMAGE_TAG .
    - docker push $IMAGE_TAG
    - docker tag $IMAGE_TAG $CI_REGISTRY_IMAGE:latest
    - docker push $CI_REGISTRY_IMAGE:latest
  only:
    - main
    - develop

deploy:dev:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - kubectl config use-context dev-cluster
    - kubectl set image deployment/myapp myapp=$IMAGE_TAG -n development
    - kubectl rollout status deployment/myapp -n development
  environment:
    name: development
    url: https://dev.myapp.com
  only:
    - develop

deploy:prod:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - kubectl config use-context prod-cluster
    - kubectl set image deployment/myapp myapp=$IMAGE_TAG -n production
    - kubectl rollout status deployment/myapp -n production
  environment:
    name: production
    url: https://myapp.com
  when: manual
  only:
    - main
```

---

### 4. CircleCI

**특징**:
- 클라우드 기반
- 병렬 실행
- 다양한 언어 지원

**`.circleci/config.yml` 예시**:
```yaml
version: 2.1

orbs:
  node: circleci/node@5.0
  docker: circleci/docker@2.1

executors:
  node-executor:
    docker:
      - image: cimg/node:18.0

jobs:
  build-and-test:
    executor: node-executor
    steps:
      - checkout
      - node/install-packages:
          pkg-manager: npm
      - run:
          name: Run tests
          command: npm test
      - run:
          name: Run linter
          command: npm run lint
      - store_test_results:
          path: test-results
      - store_artifacts:
          path: coverage

  build-docker:
    executor: docker/docker
    steps:
      - checkout
      - setup_remote_docker
      - docker/check
      - docker/build:
          image: myapp
          tag: ${CIRCLE_SHA1}
      - docker/push:
          image: myapp
          tag: ${CIRCLE_SHA1}

  deploy:
    docker:
      - image: cimg/base:stable
    steps:
      - checkout
      - run:
          name: Deploy to Kubernetes
          command: |
            kubectl set image deployment/myapp \
              myapp=myapp:${CIRCLE_SHA1} \
              -n production

workflows:
  version: 2
  build-test-deploy:
    jobs:
      - build-and-test
      - build-docker:
          requires:
            - build-and-test
          filters:
            branches:
              only: main
      - deploy:
          requires:
            - build-docker
          filters:
            branches:
              only: main
```

---

## 🔒 CI/CD 보안

### 1. 시크릿 관리

```yaml
권장사항:
  - 환경 변수 사용 (절대 코드에 포함 X)
  - Vault, AWS Secrets Manager 통합
  - 암호화된 시크릿
  - 최소 권한 원칙

Jenkins:
  - Credentials Plugin
  - HashiCorp Vault Plugin

GitHub Actions:
  - Repository Secrets
  - Organization Secrets
  - Environment Secrets

GitLab:
  - CI/CD Variables
  - Protected Variables
  - Masked Variables
```

---

### 2. 접근 제어

```yaml
RBAC (Role-Based Access Control):
  Developer:
    - 파이프라인 실행
    - 로그 조회

  Maintainer:
    - 파이프라인 수정
    - 시크릿 관리

  Admin:
    - 전체 권한
    - 설정 변경

브랜치 보호:
  - main/master: 직접 푸시 금지
  - PR 필수
  - 리뷰 승인 필요
  - 상태 체크 통과
```

---

## 📊 CI/CD 메트릭

### 주요 메트릭

| 메트릭 | 설명 | 목표 |
|--------|------|------|
| **Build Success Rate** | 빌드 성공률 | >95% |
| **Build Time** | 평균 빌드 시간 | <10분 |
| **Deployment Frequency** | 배포 빈도 | 일 1회+ |
| **Lead Time** | 코드 → 프로덕션 시간 | <1시간 |
| **MTTR** | 평균 복구 시간 | <1시간 |
| **Change Failure Rate** | 변경 실패율 | <5% |

---

## 🔒 Zone별 배치

| Zone | 배치 | 구성요소 |
|------|------|----------|
| **Zone 2** | Common | CI/CD Workers, Build Agents |
| **Zone 4** | Very Common | CI/CD Master, Controller |

---

## ⚡ 실무 고려사항

### 1. 파이프라인 최적화

```yaml
병렬 실행:
  - 독립적인 테스트 병렬 실행
  - 다중 환경 동시 배포

캐싱:
  - 의존성 캐싱 (node_modules, .m2)
  - Docker Layer 캐싱
  - 빌드 아티팩트 캐싱

증분 빌드:
  - 변경된 부분만 빌드
  - Monorepo 최적화
```

---

### 2. 장애 대응

```yaml
롤백 전략:
  - 자동 롤백 (Health Check 실패 시)
  - Blue/Green Deployment
  - Canary Deployment

알림:
  - Slack, Email 통합
  - 빌드 실패 즉시 알림
  - 배포 성공/실패 알림
```

---

### 3. 모니터링

```yaml
파이프라인 모니터링:
  - 실행 시간 추적
  - 실패율 분석
  - 병목 구간 식별

도구:
  - Jenkins Metrics Plugin
  - GitHub Insights
  - GitLab Analytics
  - Datadog CI Visibility
```

---

## 🔗 관련 문서

- [Layer 4 정의](../00_Layer_4_정의.md)
- [Version Control](../02_Version_Control/00_Version_Control_정의.md)
- [GitOps](../04_GitOps/00_GitOps_정의.md)

---

**문서 끝**
