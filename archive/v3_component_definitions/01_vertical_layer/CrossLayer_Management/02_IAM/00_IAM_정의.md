# IAM (Identity and Access Management)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | IAM |
| **한글명** | 신원 및 접근 관리 |
| **Layer** | Cross-Layer (Management) |
| **분류** | Security |
| **Function Tag (Primary)** | M2.1 (Authentication) |
| **Function Tag (Secondary)** | M2.2 (Authorization), M2.3 (SSO) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

IAM은 **누가(Who) 무엇을(What) 어떻게(How) 접근할 수 있는지 관리하는 보안 시스템**입니다.

---

## 🏗️ IAM 핵심 개념

```yaml
Identity (신원):
  - User: 개별 사용자
  - Service Account: 애플리케이션/서비스
  - Role: 임시 권한 집합

Authentication (인증):
  - "당신은 누구인가?"
  - 사용자 신원 확인

Authorization (인가):
  - "무엇을 할 수 있는가?"
  - 권한 및 정책 확인

Access Control (접근 제어):
  - RBAC: Role-Based Access Control
  - ABAC: Attribute-Based Access Control
  - PBAC: Policy-Based Access Control
```

---

## 🏗️ AWS IAM

### 사용자 및 그룹

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::my-bucket/*"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:DescribeInstances",
      "Resource": "*"
    }
  ]
}
```

### IAM Role

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

---

## 🏗️ Keycloak (오픈소스 IAM)

```javascript
// Keycloak 클라이언트 설정
const Keycloak = require('keycloak-connect');

const keycloak = new Keycloak({
  realm: 'my-realm',
  'auth-server-url': 'https://keycloak.example.com/auth',
  'ssl-required': 'external',
  resource: 'my-app',
  'public-client': true
});

// Express 미들웨어
app.use(keycloak.middleware());

// 보호된 라우트
app.get('/api/admin', keycloak.protect('realm:admin'), (req, res) => {
  res.json({ message: 'Admin only' });
});

app.get('/api/users', keycloak.protect('realm:user'), (req, res) => {
  res.json({ users: [] });
});
```

---

## 🔐 RBAC (Role-Based Access Control)

```yaml
# Kubernetes RBAC
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "watch", "list"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
  - kind: User
    name: jane
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

---

## 🔑 OAuth 2.0 & OpenID Connect

```javascript
// OAuth 2.0 인증 플로우
const express = require('express');
const passport = require('passport');
const OAuth2Strategy = require('passport-oauth2');

passport.use(new OAuth2Strategy({
    authorizationURL: 'https://oauth-provider.com/oauth2/authorize',
    tokenURL: 'https://oauth-provider.com/oauth2/token',
    clientID: CLIENT_ID,
    clientSecret: CLIENT_SECRET,
    callbackURL: 'https://myapp.com/auth/callback'
  },
  function(accessToken, refreshToken, profile, cb) {
    // 사용자 정보 저장
    User.findOrCreate({ oauthId: profile.id }, function (err, user) {
      return cb(err, user);
    });
  }
));

// 인증 라우트
app.get('/auth/login', passport.authenticate('oauth2'));

app.get('/auth/callback',
  passport.authenticate('oauth2', { failureRedirect: '/login' }),
  function(req, res) {
    res.redirect('/dashboard');
  }
);
```

---

## 🌐 SSO (Single Sign-On)

```yaml
SAML 2.0:
  - Identity Provider (IdP): Okta, Azure AD
  - Service Provider (SP): 애플리케이션
  - 한 번 로그인으로 여러 앱 접근

OAuth 2.0 / OpenID Connect:
  - Authorization Server: Auth0, Keycloak
  - 토큰 기반 인증
  - 모바일/웹 앱 지원

LDAP / Active Directory:
  - 엔터프라이즈 환경
  - 중앙 집중식 사용자 관리
```

---

## 📊 IAM 모범 사례

```yaml
최소 권한 원칙:
  - 필요한 최소한의 권한만 부여
  - 정기적으로 권한 검토

MFA (Multi-Factor Authentication):
  - 비밀번호 + OTP
  - 중요 작업에 필수

임시 자격 증명:
  - IAM Role 사용
  - Access Key 대신 STS

정책 기반 접근:
  - 명시적 허용 (Explicit Allow)
  - 명시적 거부 (Explicit Deny)

감사 로깅:
  - 모든 인증/인가 시도 기록
  - CloudTrail, Azure AD Logs
```

---

## 🔒 Zone별 배치

| Zone | 배치 | 용도 |
|------|------|------|
| **Zone 0** | Very Common | 중앙 IAM 서버 |
| **All Zones** | Very Common | 인증/인가 적용 |

---

## 🔗 관련 문서

- [Cross-Layer 정의](../00_CrossLayer_정의.md)
- [Secrets Management](../03_Secrets_Management/00_Secrets_Management_정의.md)

---

**문서 끝**
