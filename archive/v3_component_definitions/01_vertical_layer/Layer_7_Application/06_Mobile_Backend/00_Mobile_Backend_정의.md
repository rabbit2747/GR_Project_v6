# Mobile Backend (모바일 백엔드)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Mobile Backend |
| **한글명** | 모바일 백엔드 |
| **Layer** | Layer 7 (Application) |
| **분류** | Backend as a Service (BaaS) |
| **Function Tag (Primary)** | A6.1 (BaaS) |
| **Function Tag (Secondary)** | A6.2 (mBaaS) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

Mobile Backend는 **모바일 앱 개발을 위한 백엔드 서비스를 제공하는 플랫폼**입니다.

---

## 🏗️ 주요 Mobile Backend 플랫폼

### 1. Firebase (Google)

**특징**: 완전 관리형, 실시간 동기화

```javascript
// Firebase Realtime Database
import { getDatabase, ref, set, onValue } from 'firebase/database';

// 데이터 쓰기
const db = getDatabase();
set(ref(db, 'users/' + userId), {
  username: username,
  email: email,
  profile_picture: imageUrl
});

// 실시간 데이터 읽기
const userRef = ref(db, 'users/' + userId);
onValue(userRef, (snapshot) => {
  const data = snapshot.val();
  console.log(data);
});
```

```javascript
// Firebase Cloud Firestore
import { collection, addDoc, query, where, onSnapshot } from 'firebase/firestore';

// 문서 추가
const docRef = await addDoc(collection(db, "users"), {
  name: "John Doe",
  email: "john@example.com",
  age: 30
});

// 실시간 쿼리
const q = query(collection(db, "users"), where("age", ">", 18));
const unsubscribe = onSnapshot(q, (querySnapshot) => {
  querySnapshot.forEach((doc) => {
    console.log(doc.id, " => ", doc.data());
  });
});
```

**가격**:
```yaml
Firestore:
  - 문서 읽기: $0.06 per 100K
  - 문서 쓰기: $0.18 per 100K
  - 문서 삭제: $0.02 per 100K
  - 저장소: $0.18 per GB/월

Realtime Database:
  - 저장소: $5 per GB/월
  - 다운로드: $1 per GB

Authentication:
  - 무료 (전화번호 인증 제외)

Cloud Functions:
  - 2M invocations/월 무료
```

---

### 2. AWS Amplify

**특징**: AWS 서비스 통합, 풀스택 개발

```javascript
// Amplify DataStore
import { DataStore } from '@aws-amplify/datastore';
import { User } from './models';

// 데이터 생성
await DataStore.save(
  new User({
    name: "John Doe",
    email: "john@example.com"
  })
);

// 데이터 조회
const users = await DataStore.query(User);
const activeUsers = await DataStore.query(User, u => u.status.eq('active'));

// 실시간 구독
const subscription = DataStore.observe(User).subscribe(msg => {
  console.log(msg.model, msg.opType, msg.element);
});
```

```javascript
// Amplify Auth
import { Auth } from 'aws-amplify';

// 회원가입
async function signUp() {
  try {
    const { user } = await Auth.signUp({
      username,
      password,
      attributes: {
        email,
        phone_number,
      }
    });
    console.log(user);
  } catch (error) {
    console.log('error signing up:', error);
  }
}

// 로그인
async function signIn() {
  try {
    const user = await Auth.signIn(username, password);
    console.log(user);
  } catch (error) {
    console.log('error signing in', error);
  }
}
```

---

### 3. Supabase

**특징**: 오픈소스, PostgreSQL 기반

```javascript
// Supabase
import { createClient } from '@supabase/supabase-js';

const supabase = createClient('https://your-project.supabase.co', 'your-anon-key');

// 데이터 삽입
const { data, error } = await supabase
  .from('users')
  .insert([
    { name: 'John Doe', email: 'john@example.com' }
  ]);

// 데이터 조회
const { data: users } = await supabase
  .from('users')
  .select('*')
  .eq('status', 'active');

// 실시간 구독
const subscription = supabase
  .channel('users')
  .on('postgres_changes', { event: '*', schema: 'public', table: 'users' }, payload => {
    console.log('Change received!', payload);
  })
  .subscribe();

// 인증
const { user, error } = await supabase.auth.signUp({
  email: 'john@example.com',
  password: 'password'
});
```

---

## 📊 Mobile Backend 주요 기능

```yaml
인증 (Authentication):
  - 이메일/비밀번호
  - 소셜 로그인 (Google, Facebook, Apple)
  - 전화번호 인증
  - 익명 로그인

데이터베이스:
  - 실시간 동기화
  - 오프라인 지원
  - 쿼리 최적화

스토리지:
  - 파일 업로드/다운로드
  - 이미지 최적화
  - CDN 통합

푸시 알림:
  - FCM (Firebase Cloud Messaging)
  - APNs (Apple Push Notification service)
  - 타겟팅, 스케줄링

분석 (Analytics):
  - 사용자 행동 추적
  - 이벤트 로깅
  - 퍼널 분석
```

---

## 🔄 React Native 통합 예시

```javascript
// App.js
import React, { useEffect, useState } from 'react';
import { View, Text, FlatList } from 'react-native';
import { getFirestore, collection, onSnapshot } from 'firebase/firestore';

function UserList() {
  const [users, setUsers] = useState([]);

  useEffect(() => {
    const db = getFirestore();
    const unsubscribe = onSnapshot(collection(db, 'users'), (snapshot) => {
      const userList = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      setUsers(userList);
    });

    return () => unsubscribe();
  }, []);

  return (
    <View>
      <FlatList
        data={users}
        keyExtractor={item => item.id}
        renderItem={({ item }) => (
          <View>
            <Text>{item.name}</Text>
            <Text>{item.email}</Text>
          </View>
        )}
      />
    </View>
  );
}

export default UserList;
```

---

## 📊 Mobile Backend 선택 기준

| 플랫폼 | 장점 | 단점 | 적합한 경우 |
|--------|------|------|------------|
| **Firebase** | 빠른 개발, 실시간 | 벤더 종속성 | MVP, 소규모 앱 |
| **AWS Amplify** | AWS 통합, 확장성 | 복잡도 높음 | 엔터프라이즈 |
| **Supabase** | 오픈소스, SQL | 성숙도 낮음 | SQL 필요 시 |

---

## 🔒 Zone별 배치

| Zone | 배치 | 용도 |
|------|------|------|
| **Zone 1** | Very Common | Public Mobile Backend |

---

## 🔗 관련 문서

- [Layer 7 정의](../00_Layer_7_정의.md)
- [Backend API](../02_Backend_API/00_Backend_API_정의.md)

---

**문서 끝**
