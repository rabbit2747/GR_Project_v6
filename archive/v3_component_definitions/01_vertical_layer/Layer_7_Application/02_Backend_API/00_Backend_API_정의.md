# Backend API (백엔드 API)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Backend API |
| **한글명** | 백엔드 API |
| **Layer** | Layer 7 (Application) |
| **분류** | RESTful API |
| **Function Tag (Primary)** | A2.1 (REST API) |
| **Function Tag (Secondary)** | A2.2 (Microservices) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

백엔드 API는 **비즈니스 로직을 처리하고 데이터를 제공하는 서버 애플리케이션**입니다.

---

## 🏗️ 주요 프레임워크

### 1. Node.js (Express)

```javascript
const express = require('express');
const app = express();

app.get('/api/users', async (req, res) => {
  const users = await db.query('SELECT * FROM users');
  res.json(users);
});

app.post('/api/users', async (req, res) => {
  const { name, email } = req.body;
  const result = await db.query('INSERT INTO users VALUES (?, ?)', [name, email]);
  res.status(201).json({ id: result.insertId });
});

app.listen(3000);
```

### 2. Java (Spring Boot)

```java
@RestController
@RequestMapping("/api/users")
public class UserController {
    @Autowired
    private UserService userService;

    @GetMapping
    public List<User> getUsers() {
        return userService.findAll();
    }

    @PostMapping
    public User createUser(@RequestBody User user) {
        return userService.save(user);
    }
}
```

### 3. Python (FastAPI)

```python
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class User(BaseModel):
    name: str
    email: str

@app.get("/api/users")
async def get_users():
    return await db.fetch_all("SELECT * FROM users")

@app.post("/api/users")
async def create_user(user: User):
    result = await db.execute("INSERT INTO users VALUES (?, ?)", (user.name, user.email))
    return {"id": result}
```

---

## 📊 API 설계 원칙

```yaml
RESTful 규칙:
  - GET /api/users (목록 조회)
  - GET /api/users/:id (단일 조회)
  - POST /api/users (생성)
  - PUT /api/users/:id (전체 수정)
  - PATCH /api/users/:id (부분 수정)
  - DELETE /api/users/:id (삭제)

HTTP 상태 코드:
  - 200 OK: 성공
  - 201 Created: 생성 성공
  - 400 Bad Request: 잘못된 요청
  - 401 Unauthorized: 인증 실패
  - 404 Not Found: 리소스 없음
  - 500 Internal Server Error: 서버 오류
```

---

## 🔒 Zone별 배치

| Zone | 배치 | 용도 |
|------|------|------|
| **Zone 2** | Very Common | Backend API Server |

---

## 🔗 관련 문서

- [Layer 7 정의](../00_Layer_7_정의.md)
- [API Gateway](../03_API_Gateway/00_API_Gateway_정의.md)

---

**문서 끝**
