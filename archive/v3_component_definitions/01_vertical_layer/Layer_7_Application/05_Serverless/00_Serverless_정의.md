# Serverless (서버리스)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Serverless |
| **한글명** | 서버리스 |
| **Layer** | Layer 7 (Application) |
| **분류** | Function as a Service (FaaS) |
| **Function Tag (Primary)** | A5.1 (Lambda) |
| **Function Tag (Secondary)** | A5.2 (Edge Functions) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

Serverless는 **서버 관리 없이 코드를 실행하는 이벤트 기반 컴퓨팅 모델**입니다.

---

## 🏗️ 주요 Serverless 플랫폼

### 1. AWS Lambda

**특징**: 가장 성숙한 FaaS, 다양한 언어 지원

```javascript
// Node.js Lambda 함수
exports.handler = async (event) => {
    const { userId } = JSON.parse(event.body);

    // 데이터베이스 조회
    const user = await db.query('SELECT * FROM users WHERE id = ?', [userId]);

    return {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify(user)
    };
};
```

**가격**:
```yaml
요청:
  - 처음 1M requests/월: 무료
  - 그 이상: $0.20 per 1M requests

실행 시간:
  - 처음 400,000 GB-seconds/월: 무료
  - 그 이상: $0.0000166667 per GB-second

예시:
  - 128MB, 100ms 실행, 10M requests/월
  - 비용: $2.08/월
```

---

### 2. Google Cloud Functions

```python
# Python Cloud Function
import functions_framework
from google.cloud import firestore

@functions_framework.http
def get_user(request):
    user_id = request.args.get('userId')

    db = firestore.Client()
    doc = db.collection('users').document(user_id).get()

    if doc.exists:
        return doc.to_dict(), 200
    else:
        return {'error': 'User not found'}, 404
```

---

### 3. Azure Functions

```csharp
// C# Azure Function
[FunctionName("GetUser")]
public static async Task<IActionResult> Run(
    [HttpTrigger(AuthorizationLevel.Function, "get", Route = "users/{id}")] HttpRequest req,
    string id,
    ILogger log)
{
    var user = await _dbContext.Users.FindAsync(id);

    if (user == null)
        return new NotFoundResult();

    return new OkObjectResult(user);
}
```

---

## 📊 Serverless 트리거 유형

```yaml
HTTP 트리거:
  - API Gateway + Lambda
  - 웹 API 구현

스케줄 트리거:
  - CloudWatch Events (Cron)
  - 정기 작업 실행

이벤트 트리거:
  - S3 업로드 → Lambda
  - DynamoDB Stream → Lambda
  - SNS/SQS → Lambda

스트림 처리:
  - Kinesis → Lambda
  - 실시간 데이터 처리
```

---

## 🔄 Serverless 프레임워크

### Serverless Framework

```yaml
# serverless.yml
service: user-service

provider:
  name: aws
  runtime: nodejs18.x
  region: ap-northeast-2
  environment:
    DB_HOST: ${env:DB_HOST}
    DB_USER: ${env:DB_USER}

functions:
  getUser:
    handler: handler.getUser
    events:
      - http:
          path: users/{id}
          method: get
          cors: true

  createUser:
    handler: handler.createUser
    events:
      - http:
          path: users
          method: post
          cors: true

  processImage:
    handler: handler.processImage
    events:
      - s3:
          bucket: user-uploads
          event: s3:ObjectCreated:*
          rules:
            - prefix: images/
            - suffix: .jpg

resources:
  Resources:
    UsersTable:
      Type: AWS::DynamoDB::Table
      Properties:
        TableName: users
        BillingMode: PAY_PER_REQUEST
        AttributeDefinitions:
          - AttributeName: id
            AttributeType: S
        KeySchema:
          - AttributeName: id
            KeyType: HASH
```

---

## ⚡ Serverless 최적화

### 1. Cold Start 최소화

```javascript
// 전역 변수로 DB 연결 재사용
let dbConnection;

exports.handler = async (event) => {
    // DB 연결이 없으면 생성
    if (!dbConnection) {
        dbConnection = await createDBConnection();
    }

    // 연결 재사용
    const result = await dbConnection.query('SELECT * FROM users');

    return {
        statusCode: 200,
        body: JSON.stringify(result)
    };
};
```

### 2. Provisioned Concurrency

```yaml
# 미리 준비된 실행 환경
functions:
  getUser:
    handler: handler.getUser
    provisionedConcurrency: 5  # 항상 5개 준비
```

---

## 📊 Serverless vs Traditional

| 비교 | Serverless | Traditional |
|------|-----------|-------------|
| **서버 관리** | 불필요 | 필요 |
| **확장성** | 자동 | 수동 설정 |
| **비용** | 사용량 기반 | 고정 비용 |
| **Cold Start** | 있음 | 없음 |
| **실행 시간 제한** | 있음 (15분) | 없음 |

---

## 🔒 Zone별 배치

| Zone | 배치 | 용도 |
|------|------|------|
| **Zone 1** | Common | Public API (Lambda + API Gateway) |
| **Zone 2** | Very Common | Internal Functions |

---

## 🔗 관련 문서

- [Layer 7 정의](../00_Layer_7_정의.md)
- [API Gateway](../03_API_Gateway/00_API_Gateway_정의.md)

---

**문서 끝**
