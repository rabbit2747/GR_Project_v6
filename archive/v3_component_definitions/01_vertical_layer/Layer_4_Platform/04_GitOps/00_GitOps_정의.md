# GitOps

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | GitOps |
| **한글명** | Git 기반 운영 자동화 |
| **Layer** | Layer 4 (Platform Services) |
| **분류** | Deployment Automation |
| **Function Tag (Primary)** | P4.1 (GitOps Controller) |
| **Function Tag (Secondary)** | P4.2 (Continuous Deployment) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

GitOps는 **Git을 단일 진실 공급원(Single Source of Truth)으로 사용하여 인프라와 애플리케이션을 선언적으로 관리하는 운영 방법론**입니다.

### 핵심 원칙

1. **선언적 구성 (Declarative)**
   - 원하는 시스템 상태를 선언
   - Git 저장소에 YAML/JSON 정의

2. **Git 중심 (Git as Source of Truth)**
   - 모든 변경사항은 Git을 통해
   - Git 커밋 = 배포 이력
   - 롤백 = Git revert

3. **자동 동기화**
   - Git 변경 감지 → 자동 배포
   - 실제 상태 ≠ 원하는 상태 → 자동 수정

4. **지속적 조정 (Continuous Reconciliation)**
   - Pull 모델 (클러스터가 Git에서 가져옴)
   - 주기적 상태 비교
   - Drift Detection

---

## 🏗️ GitOps 아키텍처

### 전통적 CI/CD vs GitOps

```
전통적 CI/CD (Push 모델):
[Git] → [CI] → [Build] → [Test] → [Deploy Script] ──Push──→ [Cluster]

GitOps (Pull 모델):
[Git (Desired State)] ←──Pull── [GitOps Operator] ─→ [Cluster (Actual State)]
                                      ↓
                                  [Reconcile]
```

### GitOps 워크플로우

```
1. 개발자 변경
   └─→ Git Commit (manifest.yaml)
        └─→ Pull Request
             └─→ 리뷰 & 승인
                  └─→ Merge to main

2. GitOps Operator
   └─→ Git 변경 감지 (Polling or Webhook)
        └─→ Desired State 가져오기
             └─→ Actual State와 비교
                  └─→ Diff 발견 시 Apply
                       └─→ Cluster 업데이트
```

---

## 🛠️ 주요 GitOps 도구

### 1. Argo CD

**특징**:
- Kubernetes 네이티브
- 강력한 UI
- 다중 클러스터 지원

**설치**:
```bash
# Argo CD 설치
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# CLI 설치
brew install argocd

# 포트 포워딩
kubectl port-forward svc/argocd-server -n argocd 8080:443

# 초기 비밀번호 확인
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# 로그인
argocd login localhost:8080
argocd account update-password
```

**Application 정의** (`application.yaml`):
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
spec:
  project: default

  source:
    repoURL: https://github.com/myorg/myapp-config
    targetRevision: HEAD
    path: k8s/overlays/production

  destination:
    server: https://kubernetes.default.svc
    namespace: production

  syncPolicy:
    automated:
      prune: true
      selfHeal: true
      allowEmpty: false
    syncOptions:
      - CreateNamespace=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m

  revisionHistoryLimit: 10
```

**CLI로 Application 생성**:
```bash
argocd app create myapp \
  --repo https://github.com/myorg/myapp-config \
  --path k8s/overlays/production \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace production \
  --sync-policy automated \
  --auto-prune \
  --self-heal

# Application 동기화
argocd app sync myapp

# Application 상태 확인
argocd app get myapp

# Application 목록
argocd app list
```

**프로젝트 정의** (`project.yaml`):
```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: production
  namespace: argocd
spec:
  description: Production applications

  sourceRepos:
    - 'https://github.com/myorg/*'

  destinations:
    - namespace: 'production'
      server: https://kubernetes.default.svc
    - namespace: 'monitoring'
      server: https://kubernetes.default.svc

  clusterResourceWhitelist:
    - group: ''
      kind: Namespace
    - group: 'rbac.authorization.k8s.io'
      kind: ClusterRole

  namespaceResourceBlacklist:
    - group: ''
      kind: ResourceQuota

  roles:
    - name: admin
      policies:
        - p, proj:production:admin, applications, *, production/*, allow
    - name: readonly
      policies:
        - p, proj:production:readonly, applications, get, production/*, allow
```

---

### 2. Flux CD

**특징**:
- CNCF 프로젝트
- GitOps Toolkit
- 멀티 테넌시 지원

**설치**:
```bash
# Flux CLI 설치
brew install fluxcd/tap/flux

# 사전 체크
flux check --pre

# Flux 부트스트랩
flux bootstrap github \
  --owner=myorg \
  --repository=fleet-infra \
  --branch=main \
  --path=./clusters/production \
  --personal
```

**GitRepository 정의**:
```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: myapp-repo
  namespace: flux-system
spec:
  interval: 1m
  url: https://github.com/myorg/myapp-config
  ref:
    branch: main
  secretRef:
    name: github-credentials
```

**Kustomization 정의**:
```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: myapp
  namespace: flux-system
spec:
  interval: 5m
  path: ./k8s/overlays/production
  prune: true
  sourceRef:
    kind: GitRepository
    name: myapp-repo
  healthChecks:
    - apiVersion: apps/v1
      kind: Deployment
      name: myapp
      namespace: production
  timeout: 2m
```

**HelmRelease 정의** (Helm 차트 배포):
```yaml
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: nginx
  namespace: default
spec:
  interval: 5m
  chart:
    spec:
      chart: nginx
      version: '9.x'
      sourceRef:
        kind: HelmRepository
        name: bitnami
        namespace: flux-system
  values:
    service:
      type: LoadBalancer
    replicaCount: 3
```

**이미지 자동 업데이트** (`ImagePolicy`):
```yaml
apiVersion: image.toolkit.fluxcd.io/v1beta1
kind: ImageRepository
metadata:
  name: myapp-image
  namespace: flux-system
spec:
  image: myregistry.io/myorg/myapp
  interval: 1m
---
apiVersion: image.toolkit.fluxcd.io/v1beta1
kind: ImagePolicy
metadata:
  name: myapp-policy
  namespace: flux-system
spec:
  imageRepositoryRef:
    name: myapp-image
  policy:
    semver:
      range: 1.x.x
---
apiVersion: image.toolkit.fluxcd.io/v1beta1
kind: ImageUpdateAutomation
metadata:
  name: myapp-auto-update
  namespace: flux-system
spec:
  interval: 1m
  sourceRef:
    kind: GitRepository
    name: myapp-repo
  git:
    checkout:
      ref:
        branch: main
    commit:
      author:
        name: fluxcdbot
        email: flux@users.noreply.github.com
      messageTemplate: 'Update image to {{range .Updated.Images}}{{println .}}{{end}}'
  update:
    path: ./k8s/overlays/production
    strategy: Setters
```

---

## 📁 Git 저장소 구조

### 1. 단일 저장소 (Monorepo)

```
myapp-gitops/
├── apps/
│   ├── app1/
│   │   ├── base/
│   │   │   ├── deployment.yaml
│   │   │   ├── service.yaml
│   │   │   └── kustomization.yaml
│   │   └── overlays/
│   │       ├── dev/
│   │       ├── staging/
│   │       └── production/
│   └── app2/
├── infrastructure/
│   ├── base/
│   │   ├── namespaces/
│   │   ├── ingress/
│   │   └── monitoring/
│   └── overlays/
│       ├── dev/
│       └── production/
└── clusters/
    ├── dev-cluster/
    └── prod-cluster/
```

---

### 2. 다중 저장소 (Polyrepo)

```
myapp-k8s-manifests/          # 애플리케이션 매니페스트
├── deployment.yaml
├── service.yaml
└── kustomization.yaml

myapp-helm-values/            # Helm Values
├── values-dev.yaml
├── values-staging.yaml
└── values-prod.yaml

infrastructure-config/        # 인프라 구성
├── namespaces/
├── network/
└── monitoring/
```

---

## 🚀 Progressive Delivery

### 1. Canary Deployment

```yaml
# Argo Rollouts를 사용한 Canary 배포
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: myapp
spec:
  replicas: 10
  strategy:
    canary:
      steps:
        - setWeight: 10
        - pause: {duration: 1m}
        - setWeight: 20
        - pause: {duration: 1m}
        - setWeight: 50
        - pause: {duration: 2m}
        - setWeight: 100

      canaryService: myapp-canary
      stableService: myapp-stable

      trafficRouting:
        nginx:
          stableIngress: myapp-ingress

      analysis:
        templates:
          - templateName: success-rate
        startingStep: 2
        args:
          - name: service-name
            value: myapp

  selector:
    matchLabels:
      app: myapp

  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - name: myapp
          image: myapp:v2.0.0
```

---

### 2. Blue/Green Deployment

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: myapp
spec:
  replicas: 3
  strategy:
    blueGreen:
      activeService: myapp-active
      previewService: myapp-preview
      autoPromotionEnabled: false
      prePromotionAnalysis:
        templates:
          - templateName: smoke-tests
      postPromotionAnalysis:
        templates:
          - templateName: performance-tests
      scaleDownDelaySeconds: 30

  selector:
    matchLabels:
      app: myapp

  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - name: myapp
          image: myapp:v2.0.0
```

---

## 🔐 보안

### 1. 시크릿 관리

```yaml
Sealed Secrets:
  # 암호화된 시크릿을 Git에 커밋

  # SealedSecret 설치
  kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.18.0/controller.yaml

  # 시크릿 암호화
  echo -n mypassword | kubectl create secret generic mysecret \
    --dry-run=client --from-file=password=/dev/stdin -o yaml | \
    kubeseal -o yaml > mysealedsecret.yaml

  # Git에 커밋
  git add mysealedsecret.yaml

SOPS (Secrets OPerationS):
  # 파일 암호화
  sops --encrypt --kms arn:aws:kms:... secret.yaml > secret.enc.yaml

  # Flux SOPS 통합
  spec:
    decryption:
      provider: sops
      secretRef:
        name: sops-keys
```

---

### 2. RBAC 및 접근 제어

```yaml
# Argo CD RBAC Policy
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: argocd
data:
  policy.default: role:readonly
  policy.csv: |
    p, role:admin, applications, *, */*, allow
    p, role:admin, clusters, *, *, allow
    p, role:admin, repositories, *, *, allow

    p, role:developer, applications, get, */*, allow
    p, role:developer, applications, sync, */*, allow
    p, role:developer, applications, override, */*, deny

    g, alice@example.com, role:admin
    g, developers, role:developer
```

---

## 📊 모니터링 및 관찰

```yaml
주요 메트릭:
  - 동기화 상태 (Synced/OutOfSync)
  - 동기화 시간
  - 실패율
  - Drift 감지 빈도

알림:
  - Slack, Email 통합
  - Sync Failed
  - Health Degraded
  - Out of Sync (5분+)

도구:
  - Prometheus Metrics
  - Grafana Dashboard
  - Argo CD Notifications
  - Flux Alerts
```

---

## 🔒 Zone별 배치

| Zone | 배치 | 구성요소 |
|------|------|----------|
| **Zone 4** | Very Common | GitOps Operator (Argo CD, Flux) |

---

## ⚡ 실무 고려사항

### 1. 환경별 구성 관리

```yaml
Kustomize:
  base/
    ├── deployment.yaml
    └── kustomization.yaml
  overlays/
    ├── dev/
    │   └── kustomization.yaml (replicas: 1)
    ├── staging/
    │   └── kustomization.yaml (replicas: 2)
    └── production/
        └── kustomization.yaml (replicas: 10)

Helm:
  values/
    ├── values.yaml (공통)
    ├── values-dev.yaml
    ├── values-staging.yaml
    └── values-prod.yaml
```

---

### 2. 재해 복구

```yaml
백업:
  - Git 저장소는 자동 백업
  - Application 정의 백업
  - Secrets 백업 (암호화)

복구:
  1. 새 클러스터 생성
  2. GitOps Operator 설치
  3. Git 저장소 연결
  4. 자동 동기화 → 전체 복구
```

---

### 3. 마이그레이션 전략

```yaml
단계:
  1. CI/CD와 병행 운영
  2. Dev/Staging 환경부터 GitOps 적용
  3. 검증 및 학습
  4. Production 마이그레이션
  5. CI/CD 파이프라인 간소화
```

---

## 🔗 관련 문서

- [Layer 4 정의](../00_Layer_4_정의.md)
- [CI/CD](../01_CICD/00_CICD_정의.md)
- [Version Control](../02_Version_Control/00_Version_Control_정의.md)
- [IaC](../03_IaC/00_IaC_정의.md)

---

**문서 끝**
