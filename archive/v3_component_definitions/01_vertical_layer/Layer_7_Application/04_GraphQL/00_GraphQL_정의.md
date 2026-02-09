# GraphQL (그래프큐엘)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | GraphQL |
| **한글명** | 그래프큐엘 |
| **Layer** | Layer 7 (Application) |
| **분류** | Query Language |
| **Function Tag (Primary)** | A4.1 (GraphQL Server) |
| **Function Tag (Secondary)** | A4.2 (GraphQL Gateway) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

GraphQL은 **클라이언트가 필요한 데이터를 정확히 요청할 수 있는 API 쿼리 언어**입니다.

---

## 🏗️ GraphQL vs REST

| 비교 | REST | GraphQL |
|------|------|----------|
| **요청** | 여러 엔드포인트 | 단일 엔드포인트 |
| **데이터** | Over-fetching/Under-fetching | 정확히 필요한 데이터만 |
| **버전 관리** | /v1, /v2 | 스키마 진화 |
| **학습 곡선** | 낮음 | 중간 |

---

## 🏗️ GraphQL 서버 구현

### 1. Node.js (Apollo Server)

```javascript
const { ApolloServer, gql } = require('apollo-server');

// 스키마 정의
const typeDefs = gql`
  type User {
    id: ID!
    name: String!
    email: String!
    posts: [Post!]!
  }

  type Post {
    id: ID!
    title: String!
    content: String!
    author: User!
  }

  type Query {
    users: [User!]!
    user(id: ID!): User
    posts: [Post!]!
  }

  type Mutation {
    createUser(name: String!, email: String!): User!
    createPost(title: String!, content: String!, authorId: ID!): Post!
  }
`;

// 리졸버 구현
const resolvers = {
  Query: {
    users: () => db.users.findAll(),
    user: (_, { id }) => db.users.findById(id),
    posts: () => db.posts.findAll(),
  },
  Mutation: {
    createUser: (_, { name, email }) => {
      return db.users.create({ name, email });
    },
    createPost: (_, { title, content, authorId }) => {
      return db.posts.create({ title, content, authorId });
    },
  },
  User: {
    posts: (user) => db.posts.findByAuthorId(user.id),
  },
  Post: {
    author: (post) => db.users.findById(post.authorId),
  },
};

const server = new ApolloServer({ typeDefs, resolvers });

server.listen().then(({ url }) => {
  console.log(`🚀 Server ready at ${url}`);
});
```

---

### 2. Python (Strawberry GraphQL)

```python
import strawberry
from typing import List

@strawberry.type
class User:
    id: strawberry.ID
    name: str
    email: str

@strawberry.type
class Post:
    id: strawberry.ID
    title: str
    content: str
    author_id: strawberry.ID

@strawberry.type
class Query:
    @strawberry.field
    def users(self) -> List[User]:
        return db.query("SELECT * FROM users")

    @strawberry.field
    def user(self, id: strawberry.ID) -> User:
        return db.query("SELECT * FROM users WHERE id = ?", [id])

@strawberry.type
class Mutation:
    @strawberry.mutation
    def create_user(self, name: str, email: str) -> User:
        result = db.execute("INSERT INTO users (name, email) VALUES (?, ?)", [name, email])
        return User(id=result.lastrowid, name=name, email=email)

schema = strawberry.Schema(query=Query, mutation=Mutation)
```

---

## 📊 GraphQL 쿼리 예시

### 1. Query (조회)

```graphql
# 사용자와 게시글을 한 번에 조회
query {
  user(id: "1") {
    id
    name
    email
    posts {
      id
      title
      content
    }
  }
}

# 응답
{
  "data": {
    "user": {
      "id": "1",
      "name": "John Doe",
      "email": "john@example.com",
      "posts": [
        {
          "id": "101",
          "title": "GraphQL 소개",
          "content": "GraphQL은..."
        }
      ]
    }
  }
}
```

### 2. Mutation (생성/수정/삭제)

```graphql
# 사용자 생성
mutation {
  createUser(name: "Jane Doe", email: "jane@example.com") {
    id
    name
    email
  }
}

# 응답
{
  "data": {
    "createUser": {
      "id": "2",
      "name": "Jane Doe",
      "email": "jane@example.com"
    }
  }
}
```

### 3. Subscription (실시간)

```graphql
# 새 게시글 알림 구독
subscription {
  postCreated {
    id
    title
    author {
      name
    }
  }
}
```

---

## 🔄 GraphQL 고급 기능

```yaml
Pagination:
  - Cursor-based: after, first
  - Offset-based: offset, limit

Caching:
  - @cacheControl(maxAge: 3600)
  - DataLoader for N+1 문제 해결

Authentication:
  - Context에 user 정보 포함
  - Directive로 권한 체크

Error Handling:
  - errors 배열로 에러 전달
  - extensions로 추가 정보 제공
```

---

## 🔒 Zone별 배치

| Zone | 배치 | 용도 |
|------|------|------|
| **Zone 2** | Common | GraphQL Server |

---

## 🔗 관련 문서

- [Layer 7 정의](../00_Layer_7_정의.md)
- [Backend API](../02_Backend_API/00_Backend_API_정의.md)

---

**문서 끝**
