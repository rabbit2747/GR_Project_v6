# Secrets Management (비밀 정보 관리)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Secrets Management |
| **한글명** | 비밀 정보 관리 |
| **Layer** | Cross-Layer (Management) |
| **분류** | Security |
| **Function Tag (Primary)** | M3.1 (Vault) |
| **Function Tag (Secondary)** | M3.2 (Key Management) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

Secrets Management는 **API 키, 비밀번호, 인증서 등 민감한 정보를 안전하게 저장하고 관리하는 시스템**입니다.

---

## 🏗️ 주요 Secrets Management 솔루션

### 1. HashiCorp Vault

**특징**: 동적 비밀, 암호화, 감사 로깅

```bash
# Vault 시작
vault server -dev

# 비밀 저장
vault kv put secret/myapp/config \
  db_password="super-secret" \
  api_key="abc123"

# 비밀 조회
vault kv get secret/myapp/config

# 출력
====== Data ======
Key            Value
---            -----
api_key        abc123
db_password    super-secret
```

```python
# Python에서 Vault 사용
import hvac

client = hvac.Client(url='http://localhost:8200', token='dev-token')

# 비밀 읽기
secret = client.secrets.kv.v2.read_secret_version(path='myapp/config')
db_password = secret['data']['data']['db_password']

# 비밀 쓰기
client.secrets.kv.v2.create_or_update_secret(
    path='myapp/config',
    secret=dict(db_password='new-password', api_key='xyz789')
)
```

**동적 비밀 (Dynamic Secrets)**:
```bash
# 데이터베이스 동적 자격 증명
vault write database/roles/my-role \
  db_name=my-database \
  creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}'; GRANT SELECT ON *.* TO '{{name}}'@'%';" \
  default_ttl="1h" \
  max_ttl="24h"

# 임시 자격 증명 생성
vault read database/creds/my-role

# 출력
Key                Value
---                -----
lease_id           database/creds/my-role/abc123
lease_duration     1h
password           A1a-randompassword
username           v-token-my-role-xyz
```

---

### 2. AWS Secrets Manager

```python
import boto3
import json

client = boto3.client('secretsmanager')

# 비밀 생성
client.create_secret(
    Name='myapp/database',
    SecretString=json.dumps({
        'username': 'admin',
        'password': 'super-secret',
        'host': 'db.example.com',
        'port': 5432
    })
)

# 비밀 조회
response = client.get_secret_value(SecretId='myapp/database')
secret = json.loads(response['SecretString'])
db_password = secret['password']

# 비밀 자동 로테이션
client.rotate_secret(
    SecretId='myapp/database',
    RotationLambdaARN='arn:aws:lambda:region:account:function:rotate-secret',
    RotationRules={
        'AutomaticallyAfterDays': 30
    }
)
```

**가격**:
```yaml
AWS Secrets Manager:
  - $0.40 per secret/월
  - $0.05 per 10,000 API calls

AWS Systems Manager Parameter Store:
  - Standard: 무료
  - Advanced: $0.05 per parameter/월
```

---

### 3. Kubernetes Secrets

```yaml
# Secret 생성
apiVersion: v1
kind: Secret
metadata:
  name: myapp-secret
type: Opaque
data:
  # Base64 인코딩
  username: YWRtaW4=
  password: c3VwZXItc2VjcmV0

---
# Pod에서 사용
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
  - name: app
    image: myapp:1.0
    env:
    - name: DB_USERNAME
      valueFrom:
        secretKeyRef:
          name: myapp-secret
          key: username
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: myapp-secret
          key: password
```

**External Secrets Operator** (Vault 통합):
```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: vault-secret
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: myapp-secret
  data:
  - secretKey: username
    remoteRef:
      key: secret/data/myapp/config
      property: username
  - secretKey: password
    remoteRef:
      key: secret/data/myapp/config
      property: password
```

---

## 🔐 암호화 키 관리 (KMS)

### AWS KMS

```python
import boto3

kms = boto3.client('kms')

# 데이터 암호화
response = kms.encrypt(
    KeyId='alias/my-key',
    Plaintext='sensitive data'
)
ciphertext = response['CiphertextBlob']

# 데이터 복호화
response = kms.decrypt(
    CiphertextBlob=ciphertext
)
plaintext = response['Plaintext']
```

**Envelope Encryption (봉투 암호화)**:
```yaml
1. 데이터 암호화 키 (DEK) 생성
2. DEK로 데이터 암호화
3. KMS 마스터 키로 DEK 암호화
4. 암호화된 데이터 + 암호화된 DEK 저장
```

---

## 📊 비밀 관리 모범 사례

```yaml
절대 하지 말 것:
  - ❌ 코드에 하드코딩
  - ❌ Git에 커밋
  - ❌ 환경 변수에 평문 저장
  - ❌ 로그에 출력

해야 할 것:
  - ✅ Secrets Manager 사용
  - ✅ 암호화 저장
  - ✅ 접근 제어 (IAM)
  - ✅ 자동 로테이션
  - ✅ 감사 로깅

비밀 로테이션:
  - 정기적 자동 교체 (30-90일)
  - 침해 발생 시 즉시 교체
  - Zero-downtime 로테이션

최소 권한:
  - 필요한 비밀만 접근
  - 시간 제한 (TTL)
  - 동적 자격 증명 사용
```

---

## 🔄 비밀 주입 패턴

```yaml
환경 변수:
  - 컨테이너 시작 시 주입
  - 간단하지만 덜 안전

파일 마운트:
  - Kubernetes Secrets Volume
  - 파일로 마운트하여 읽기

Sidecar 패턴:
  - Vault Agent Sidecar
  - 자동으로 비밀 갱신

Init Container:
  - 시작 전 비밀 가져오기
  - 파일에 저장 후 앱 실행
```

---

## 🔒 Zone별 배치

| Zone | 배치 | 용도 |
|------|------|------|
| **Zone 0** | Very Common | 중앙 Secrets 저장소 |
| **All Zones** | Very Common | 비밀 소비 |

---

## 🔗 관련 문서

- [Cross-Layer 정의](../00_CrossLayer_정의.md)
- [IAM](../02_IAM/00_IAM_정의.md)

---

**문서 끝**
