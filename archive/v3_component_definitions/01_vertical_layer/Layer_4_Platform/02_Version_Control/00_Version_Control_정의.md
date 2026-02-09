# Version Control (버전 관리 시스템)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Version Control |
| **한글명** | 버전 관리 시스템 |
| **Layer** | Layer 4 (Platform Services) |
| **분류** | Source Code Management |
| **Function Tag (Primary)** | P2.1 (Git Server) |
| **Function Tag (Secondary)** | P2.2 (Code Repository) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

Version Control은 **소스 코드의 변경사항을 추적하고 관리하는 시스템**입니다.

### 핵심 기능

1. **변경 이력 관리**
   - 모든 변경사항 추적
   - 시점별 복원
   - 변경 이유 기록

2. **협업 지원**
   - 다중 개발자 동시 작업
   - 코드 리뷰
   - 충돌 해결

3. **브랜치 관리**
   - 독립적인 작업 공간
   - 기능별 분리
   - 병합 및 통합

---

## 🏗️ Version Control 시스템 유형

### 1. 중앙집중형 (Centralized VCS)

```
모든 변경사항이 중앙 서버에 저장

[Developer 1] ─┐
[Developer 2] ─┼→ [Central Server]
[Developer 3] ─┘

특징:
- 단일 진실 공급원
- 간단한 구조
- 네트워크 필수

예시: SVN, CVS, Perforce
```

---

### 2. 분산형 (Distributed VCS)

```
각 개발자가 전체 저장소 복사본 보유

[Developer 1 (Local Repo)] ─┐
[Developer 2 (Local Repo)] ─┼→ [Remote Repo (GitHub)]
[Developer 3 (Local Repo)] ─┘

특징:
- 오프라인 작업 가능
- 빠른 속도
- 복잡한 브랜칭

예시: Git, Mercurial
```

---

## 🛠️ Git 기본 개념

### Git 워크플로우

```
Working Directory → Staging Area → Local Repository → Remote Repository
     (수정)            (git add)       (git commit)      (git push)
```

### 주요 명령어

```bash
# 저장소 초기화
git init
git clone https://github.com/user/repo.git

# 변경사항 추적
git status
git diff
git log --oneline --graph

# 스테이징 및 커밋
git add file.txt
git add .
git commit -m "Add new feature"

# 브랜치 관리
git branch feature/new-feature
git checkout feature/new-feature
git checkout -b feature/new-feature  # 생성 및 체크아웃

# 병합
git merge feature/new-feature
git rebase main

# 원격 저장소
git remote add origin https://github.com/user/repo.git
git push origin main
git pull origin main
git fetch origin

# 변경 취소
git reset HEAD file.txt  # 스테이징 취소
git checkout -- file.txt  # 변경 취소
git revert abc123  # 커밋 되돌리기

# 임시 저장
git stash
git stash pop
```

---

## 🌐 주요 Git 호스팅 서비스

### 1. GitHub

**특징**:
- 세계 최대 Git 호스팅
- 강력한 CI/CD (Actions)
- 풍부한 생태계

**가격**:
```yaml
Free:
  - 무제한 Public 저장소
  - 무제한 Private 저장소
  - 2000분/월 Actions

Team: $4/user/month
  - 3000분/월 Actions
  - 2GB Packages Storage

Enterprise: $21/user/month
  - 50,000분/월 Actions
  - 50GB Packages Storage
  - SAML SSO
```

**GitHub Flow**:
```
1. main 브랜치에서 feature 브랜치 생성
2. 커밋 추가
3. Pull Request 생성
4. 리뷰 및 토론
5. 테스트 통과 확인
6. main에 병합
7. 배포
```

---

### 2. GitLab

**특징**:
- 완전한 DevOps 플랫폼
- 자체 호스팅 가능
- 통합 CI/CD

**가격**:
```yaml
Free:
  - 무제한 Private 저장소
  - 400 CI/CD 분/월
  - 5GB Storage

Premium: $29/user/month
  - 10,000 CI/CD 분/월
  - 50GB Storage
  - Code Owners
  - Multiple Approvers

Ultimate: $99/user/month
  - 50,000 CI/CD 분/월
  - 250GB Storage
  - Security Dashboard
  - Compliance Management
```

**GitLab Flow**:
```
Production Branch Strategy:

[main] ──→ [pre-production] ──→ [production]
   ↑              ↑                    ↑
[feature/X]   (검증)              (릴리스)
```

---

### 3. Bitbucket

**특징**:
- Atlassian 제품군 통합
- Jira 연동
- Pipelines (CI/CD)

**가격**:
```yaml
Free:
  - 최대 5 users
  - 50분/월 Pipelines

Standard: $3/user/month
  - 2500분/월 Pipelines
  - Branch Permissions
  - Merge Checks

Premium: $6/user/month
  - 3500분/월 Pipelines
  - IP Whitelisting
  - Deployment Permissions
```

---

### 4. 자체 호스팅 (Self-Hosted)

**GitLab CE (Community Edition)**:
```bash
# Docker로 GitLab 설치
docker run --detach \
  --hostname gitlab.example.com \
  --publish 443:443 --publish 80:80 --publish 22:22 \
  --name gitlab \
  --restart always \
  --volume $HOME/gitlab/config:/etc/gitlab \
  --volume $HOME/gitlab/logs:/var/log/gitlab \
  --volume $HOME/gitlab/data:/var/opt/gitlab \
  gitlab/gitlab-ce:latest
```

**Gitea (경량 Git 서버)**:
```bash
# Docker로 Gitea 설치
docker run -d \
  --name gitea \
  -p 3000:3000 \
  -p 222:22 \
  -v gitea-data:/data \
  gitea/gitea:latest
```

---

## 🔀 브랜치 전략

### 1. Git Flow

```
[master/main] ──────────────────────────────→
       ↑                ↑                ↑
   [release/1.0]    [release/1.1]   [release/2.0]
       ↑                ↑                ↑
    [develop] ────────────────────────────→
       ↑        ↑         ↑         ↑
   [feature/A] [feature/B] [hotfix/X]

브랜치 유형:
- main: 프로덕션 릴리스
- develop: 다음 릴리스 개발
- feature/*: 기능 개발
- release/*: 릴리스 준비
- hotfix/*: 긴급 수정

장점: 명확한 구조, 대규모 프로젝트
단점: 복잡함, 느린 릴리스
```

---

### 2. GitHub Flow

```
[main] ──────────────────────────────────→
   ↑     ↑       ↑      ↑       ↑
[feat/A] [feat/B] [fix/C] [feat/D]

규칙:
1. main은 항상 배포 가능
2. 기능 브랜치는 main에서 생성
3. Pull Request로 병합
4. 리뷰 후 병합
5. 병합 즉시 배포

장점: 간단함, 빠른 배포
단점: 여러 버전 지원 어려움
```

---

### 3. Trunk-Based Development

```
[main/trunk] ──────────────────────────────→
   ↑  ↑  ↑  ↑  ↑
   (1) (2) (3) (4) (5)  ← 짧은 수명 브랜치 또는 직접 커밋

규칙:
- main에 자주 병합 (하루 1회 이상)
- Feature Flag 사용
- 짧은 수명 브랜치 (<1일)

장점: 단순함, CI/CD 최적
단점: 높은 자동화 요구
```

---

## 🔧 Git 고급 기능

### 1. Git Hooks

**Pre-commit Hook** (`.git/hooks/pre-commit`):
```bash
#!/bin/bash

# Linting 체크
npm run lint
if [ $? -ne 0 ]; then
    echo "Lint failed. Commit aborted."
    exit 1
fi

# 테스트 실행
npm test
if [ $? -ne 0 ]; then
    echo "Tests failed. Commit aborted."
    exit 1
fi

exit 0
```

**Husky 사용** (Node.js):
```json
// package.json
{
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged",
      "pre-push": "npm test"
    }
  },
  "lint-staged": {
    "*.js": ["eslint --fix", "git add"]
  }
}
```

---

### 2. Git Submodules

```bash
# Submodule 추가
git submodule add https://github.com/user/lib.git libs/lib

# Submodule 포함하여 클론
git clone --recursive https://github.com/user/project.git

# Submodule 업데이트
git submodule update --remote
```

---

### 3. Git LFS (Large File Storage)

```bash
# Git LFS 설치
git lfs install

# 대용량 파일 추적
git lfs track "*.psd"
git lfs track "*.mp4"

# .gitattributes 커밋
git add .gitattributes
git commit -m "Track large files with LFS"

# 일반적으로 사용
git add large-file.psd
git commit -m "Add design file"
git push
```

---

## 📝 커밋 메시지 컨벤션

### Conventional Commits

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
```yaml
feat: 새로운 기능
fix: 버그 수정
docs: 문서 변경
style: 코드 포맷팅 (로직 변경 없음)
refactor: 코드 리팩토링
test: 테스트 추가/수정
chore: 빌드, 설정 변경
```

**예시**:
```
feat(auth): add OAuth2 login support

- Implement Google OAuth2 provider
- Add Facebook OAuth2 provider
- Create user session management

Closes #123
```

---

## 🔒 보안

### 1. Access Control

```yaml
GitHub:
  Repository Permissions:
    - Read: 코드 조회
    - Triage: 이슈 관리
    - Write: 푸시 권한
    - Maintain: 설정 변경
    - Admin: 전체 권한

  Branch Protection:
    - Require PR reviews
    - Require status checks
    - Require signed commits
    - Restrict who can push
```

---

### 2. 시크릿 관리

```yaml
주의사항:
  ❌ API 키, 비밀번호 커밋 금지
  ❌ .env 파일 커밋 금지
  ❌ 인증서, 토큰 커밋 금지

해결책:
  ✅ .gitignore에 추가
  ✅ 환경 변수 사용
  ✅ Secrets Manager 사용
  ✅ git-secrets 도구 사용
```

**git-secrets 사용**:
```bash
# 설치
brew install git-secrets

# 설정
git secrets --install
git secrets --register-aws

# 스캔
git secrets --scan
```

---

### 3. Signed Commits (서명된 커밋)

```bash
# GPG 키 생성
gpg --gen-key

# Git 설정
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgsign true

# 서명된 커밋
git commit -S -m "Signed commit message"

# 검증
git log --show-signature
```

---

## 🔒 Zone별 배치

| Zone | 배치 | 구성요소 |
|------|------|----------|
| **Zone 4** | Very Common | Git Server (GitLab, Gitea) |
| **Zone 5** | Common | GitHub Enterprise (클라우드) |

---

## ⚡ 실무 고려사항

### 1. 저장소 크기 관리

```yaml
문제:
  - 대용량 파일 추가 시 저장소 비대화
  - 클론 시간 증가

해결책:
  - Git LFS 사용 (이미지, 동영상, 바이너리)
  - .gitignore 적극 활용
  - Shallow Clone (git clone --depth 1)
```

---

### 2. 모노레포 vs 멀티레포

```yaml
모노레포 (Monorepo):
  장점:
    - 코드 재사용 쉬움
    - 원자적 커밋
    - 일관된 버전 관리

  단점:
    - 저장소 크기
    - 빌드 시간
    - 접근 제어 복잡

  도구: Nx, Turborepo, Lerna

멀티레포 (Multirepo):
  장점:
    - 명확한 소유권
    - 독립적 배포
    - 세밀한 접근 제어

  단점:
    - 의존성 관리 복잡
    - 코드 중복
    - 버전 충돌

  전략: 명확한 API 계약, Semantic Versioning
```

---

### 3. 백업 및 재해 복구

```yaml
백업 전략:
  - 정기적인 미러링
  - 다중 지역 복제
  - 오프사이트 백업

GitHub:
  - GitHub Enterprise Backup Utilities
  - 자동 미러링 설정

GitLab:
  - gitlab-rake gitlab:backup:create
  - Cron으로 자동화
```

---

## 🔗 관련 문서

- [Layer 4 정의](../00_Layer_4_정의.md)
- [CI/CD](../01_CICD/00_CICD_정의.md)
- [GitOps](../04_GitOps/00_GitOps_정의.md)

---

**문서 끝**
