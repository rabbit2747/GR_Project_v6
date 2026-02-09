# Frontend (프론트엔드)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Frontend |
| **한글명** | 프론트엔드 |
| **Layer** | Layer 7 (Application) |
| **분류** | Web UI |
| **Function Tag (Primary)** | A1.1 (SPA) |
| **Function Tag (Secondary)** | A1.2 (SSR) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

프론트엔드는 **사용자가 직접 상호작용하는 웹 인터페이스**입니다.

---

## 🏗️ 주요 프레임워크

### 1. React

```javascript
import React, { useState, useEffect } from 'react';

function UserList() {
  const [users, setUsers] = useState([]);

  useEffect(() => {
    fetch('/api/users')
      .then(res => res.json())
      .then(data => setUsers(data));
  }, []);

  return (
    <div>
      {users.map(user => (
        <div key={user.id}>{user.name}</div>
      ))}
    </div>
  );
}
```

### 2. Vue.js

```vue
<template>
  <div>
    <div v-for="user in users" :key="user.id">
      {{ user.name }}
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return { users: [] };
  },
  async mounted() {
    const res = await fetch('/api/users');
    this.users = await res.json();
  }
}
</script>
```

### 3. Angular

```typescript
import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-user-list',
  template: `
    <div *ngFor="let user of users">
      {{ user.name }}
    </div>
  `
})
export class UserListComponent implements OnInit {
  users: any[] = [];

  constructor(private http: HttpClient) {}

  ngOnInit() {
    this.http.get<any[]>('/api/users')
      .subscribe(data => this.users = data);
  }
}
```

---

## 📊 렌더링 방식

| 방식 | 설명 | 장점 | 단점 |
|------|------|------|------|
| **SPA** | 클라이언트 렌더링 | 빠른 인터랙션 | 초기 로딩 느림, SEO 불리 |
| **SSR** | 서버 사이드 렌더링 | 빠른 초기 로딩, SEO 유리 | 서버 부하 |
| **SSG** | 정적 사이트 생성 | 빠름, SEO 유리 | 동적 콘텐츠 제한 |

---

## 🔒 Zone별 배치

| Zone | 배치 | 용도 |
|------|------|------|
| **Zone 1** | Very Common | Static Frontend (S3 + CDN) |
| **Zone 2** | Common | SSR Frontend (Server) |

---

## 🔗 관련 문서

- [Layer 7 정의](../00_Layer_7_정의.md)
- [Backend API](../02_Backend_API/00_Backend_API_정의.md)

---

**문서 끝**
