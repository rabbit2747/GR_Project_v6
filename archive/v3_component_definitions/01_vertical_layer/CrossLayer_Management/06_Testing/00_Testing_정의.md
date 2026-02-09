# Testing (테스트)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Testing |
| **한글명** | 테스트 |
| **Layer** | Cross-Layer (Management) |
| **분류** | Quality Assurance |
| **Function Tag (Primary)** | M6.1 (Unit Testing) |
| **Function Tag (Secondary)** | M6.2 (Integration Testing), M6.3 (E2E Testing) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

Testing은 **소프트웨어 품질을 보증하기 위한 체계적인 검증 및 테스트 프로세스**입니다.

---

## 🏗️ 테스트 피라미드

```yaml
              /\
             /  \  E2E Tests (10%)
            /____\
           /      \
          / Integ. \  Integration Tests (20%)
         /  Tests   \
        /____________\
       /              \
      /  Unit Tests    \  Unit Tests (70%)
     /__________________\

Unit Tests:
  - 빠름 (ms)
  - 저렴
  - 많은 수

Integration Tests:
  - 중간 속도 (초)
  - 중간 비용
  - 적당한 수

E2E Tests:
  - 느림 (분)
  - 비싸
  - 적은 수
```

---

## 🏗️ 1. Unit Testing (단위 테스트)

### JavaScript (Jest)

```javascript
// sum.js
function sum(a, b) {
  return a + b;
}

module.exports = sum;
```

```javascript
// sum.test.js
const sum = require('./sum');

describe('sum function', () => {
  test('adds 1 + 2 to equal 3', () => {
    expect(sum(1, 2)).toBe(3);
  });

  test('adds -1 + 1 to equal 0', () => {
    expect(sum(-1, 1)).toBe(0);
  });
});
```

### Python (pytest)

```python
# calculator.py
class Calculator:
    def add(self, a, b):
        return a + b

    def divide(self, a, b):
        if b == 0:
            raise ValueError("Cannot divide by zero")
        return a / b
```

```python
# test_calculator.py
import pytest
from calculator import Calculator

def test_add():
    calc = Calculator()
    assert calc.add(2, 3) == 5

def test_divide():
    calc = Calculator()
    assert calc.divide(10, 2) == 5

def test_divide_by_zero():
    calc = Calculator()
    with pytest.raises(ValueError):
        calc.divide(10, 0)
```

### Java (JUnit)

```java
// Calculator.java
public class Calculator {
    public int add(int a, int b) {
        return a + b;
    }
}
```

```java
// CalculatorTest.java
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class CalculatorTest {
    @Test
    void testAdd() {
        Calculator calc = new Calculator();
        assertEquals(5, calc.add(2, 3));
    }
}
```

---

## 🏗️ 2. Integration Testing (통합 테스트)

```javascript
// API 통합 테스트 (Supertest)
const request = require('supertest');
const app = require('../app');

describe('User API', () => {
  test('POST /api/users creates a new user', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({
        name: 'John Doe',
        email: 'john@example.com'
      })
      .expect(201);

    expect(response.body).toHaveProperty('id');
    expect(response.body.name).toBe('John Doe');
  });

  test('GET /api/users returns all users', async () => {
    const response = await request(app)
      .get('/api/users')
      .expect(200);

    expect(Array.isArray(response.body)).toBe(true);
  });
});
```

```python
# Django 통합 테스트
from django.test import TestCase, Client
from django.urls import reverse

class UserAPITestCase(TestCase):
    def setUp(self):
        self.client = Client()

    def test_create_user(self):
        response = self.client.post(
            reverse('user-list'),
            {'name': 'John Doe', 'email': 'john@example.com'},
            content_type='application/json'
        )
        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.json()['name'], 'John Doe')
```

---

## 🏗️ 3. E2E Testing (엔드투엔드 테스트)

### Playwright

```javascript
const { test, expect } = require('@playwright/test');

test.describe('E-commerce checkout flow', () => {
  test('complete purchase', async ({ page }) => {
    // 1. 홈페이지 방문
    await page.goto('https://example.com');

    // 2. 상품 검색
    await page.fill('#search', 'laptop');
    await page.click('button[type="submit"]');

    // 3. 상품 선택
    await page.click('.product-card:first-child');
    await expect(page.locator('h1')).toContainText('Laptop');

    // 4. 장바구니 추가
    await page.click('#add-to-cart');
    await expect(page.locator('.cart-count')).toHaveText('1');

    // 5. 결제
    await page.click('#checkout');
    await page.fill('#email', 'test@example.com');
    await page.fill('#card-number', '4242424242424242');
    await page.click('#submit-payment');

    // 6. 주문 완료 확인
    await expect(page.locator('.success-message')).toBeVisible();
  });
});
```

### Cypress

```javascript
describe('Login flow', () => {
  it('should login successfully', () => {
    cy.visit('/login');

    cy.get('#email').type('user@example.com');
    cy.get('#password').type('password123');
    cy.get('button[type="submit"]').click();

    cy.url().should('include', '/dashboard');
    cy.get('.welcome-message').should('contain', 'Welcome back');
  });

  it('should show error for invalid credentials', () => {
    cy.visit('/login');

    cy.get('#email').type('wrong@example.com');
    cy.get('#password').type('wrongpassword');
    cy.get('button[type="submit"]').click();

    cy.get('.error-message').should('be.visible');
    cy.get('.error-message').should('contain', 'Invalid credentials');
  });
});
```

---

## 🏗️ 4. Performance Testing (성능 테스트)

### k6

```javascript
import http from 'k6/http';
import { sleep, check } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 100 },  // Ramp up to 100 users
    { duration: '5m', target: 100 },  // Stay at 100 users
    { duration: '2m', target: 0 },    // Ramp down to 0 users
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],  // 95% of requests must complete below 500ms
    http_req_failed: ['rate<0.01'],    // Error rate must be less than 1%
  },
};

export default function () {
  let response = http.get('https://api.example.com/users');

  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });

  sleep(1);
}
```

### JMeter

```xml
<!-- HTTP Request -->
<HTTPSamplerProxy>
  <elementProp name="HTTPsampler.Arguments">
    <collectionProp name="Arguments.arguments"/>
  </elementProp>
  <stringProp name="HTTPSampler.domain">api.example.com</stringProp>
  <stringProp name="HTTPSampler.port">443</stringProp>
  <stringProp name="HTTPSampler.protocol">https</stringProp>
  <stringProp name="HTTPSampler.path">/api/users</stringProp>
  <stringProp name="HTTPSampler.method">GET</stringProp>
</HTTPSamplerProxy>

<!-- Thread Group -->
<ThreadGroup>
  <stringProp name="ThreadGroup.num_threads">100</stringProp>
  <stringProp name="ThreadGroup.ramp_time">60</stringProp>
  <stringProp name="ThreadGroup.duration">300</stringProp>
</ThreadGroup>
```

---

## 📊 테스트 커버리지

```bash
# Jest 커버리지
npm test -- --coverage

# 출력
--------------------|---------|----------|---------|---------|
File                | % Stmts | % Branch | % Funcs | % Lines |
--------------------|---------|----------|---------|---------|
All files           |   85.5  |   78.2   |   90.1  |   85.5  |
 src/               |   88.9  |   80.5   |   95.2  |   88.9  |
  calculator.js     |  100.0  |  100.0   |  100.0  |  100.0  |
  utils.js          |   75.0  |   60.0   |   88.0  |   75.0  |
--------------------|---------|----------|---------|---------|

목표:
  - Statements: 80% 이상
  - Branches: 75% 이상
  - Functions: 85% 이상
  - Lines: 80% 이상
```

---

## 🔄 CI/CD 통합

```yaml
# GitHub Actions
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Run unit tests
        run: npm test

      - name: Run integration tests
        run: npm run test:integration

      - name: Run E2E tests
        run: npm run test:e2e

      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

---

## 🏗️ TDD (Test-Driven Development)

```yaml
Red-Green-Refactor:
  1. Red: 실패하는 테스트 작성
  2. Green: 테스트를 통과하는 최소한의 코드 작성
  3. Refactor: 코드 개선

예시:
  1. [Red] test: "user can login"
     - 실패 (login 함수 없음)

  2. [Green] 최소 구현
     function login(username, password) {
       return true;
     }

  3. [Refactor] 개선
     function login(username, password) {
       return db.validateCredentials(username, password);
     }
```

---

## 📊 테스트 메트릭

```yaml
Quality Metrics:
  - Code Coverage: 80%+
  - Test Pass Rate: 95%+
  - Defect Density: <1 per 1000 LOC

Performance Metrics:
  - Unit Test Execution: <5 seconds
  - Integration Test: <30 seconds
  - E2E Test Suite: <10 minutes

CI/CD Metrics:
  - Build Success Rate: 95%+
  - Test Failure Rate: <5%
  - Flaky Test Rate: <1%
```

---

## 🔒 Zone별 배치

| Zone | 배치 | 용도 |
|------|------|------|
| **All Zones** | Very Common | 테스트 실행 |

---

## 🔗 관련 문서

- [Cross-Layer 정의](../00_CrossLayer_정의.md)
- [CI/CD](../../Layer_4_Platform/03_CI_CD/00_CI_CD_정의.md)

---

**문서 끝**
