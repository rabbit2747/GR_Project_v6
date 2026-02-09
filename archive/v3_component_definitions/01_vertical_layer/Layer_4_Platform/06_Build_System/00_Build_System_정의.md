# Build System (빌드 시스템)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Build System |
| **한글명** | 빌드 시스템 |
| **Layer** | Layer 4 (Platform Services) |
| **분류** | Build & Package Tool |
| **Function Tag (Primary)** | P6.1 (Build Tool) |
| **Function Tag (Secondary)** | P6.2 (Package Manager) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

Build System은 **소스 코드를 실행 가능한 아티팩트로 변환하는 도구 및 프로세스**입니다.

### 핵심 기능

1. **컴파일**
   - 소스 코드 → 바이너리
   - 의존성 해결
   - 에러 검출

2. **패키징**
   - 아티팩트 생성 (JAR, WAR, DLL, 바이너리)
   - 압축 및 번들링
   - 메타데이터 포함

3. **최적화**
   - 코드 최소화 (Minification)
   - 트리 쉐이킹 (Tree Shaking)
   - 번들 최적화

---

## 🏗️ 빌드 시스템 분류

### 1. Java/JVM 기반

```yaml
Maven:
  - XML 기반 (pom.xml)
  - Convention over Configuration
  - 중앙 저장소 (Maven Central)

Gradle:
  - Groovy/Kotlin DSL
  - 유연성 및 성능
  - Android 공식 빌드 도구

Ant:
  - XML 기반
  - 레거시
  - 낮은 추상화
```

---

### 2. JavaScript/Node.js

```yaml
npm:
  - Node Package Manager
  - package.json
  - npm scripts

Yarn:
  - 빠른 속도
  - 결정론적 의존성
  - Workspaces (Monorepo)

pnpm:
  - 디스크 효율성
  - 엄격한 의존성
  - 빠른 설치

Webpack:
  - 모듈 번들러
  - Code Splitting
  - 플러그인 생태계

Vite:
  - 빠른 개발 서버
  - ES 모듈 기반
  - 프로덕션 최적화
```

---

### 3. C/C++

```yaml
Make:
  - Makefile
  - UNIX 표준
  - 레거시

CMake:
  - 크로스 플랫폼
  - 메타 빌드 시스템
  - 현대적
```

---

## 🛠️ 주요 빌드 도구

### 1. Maven

**특징**:
- XML 기반
- Lifecycle (compile → test → package)
- 플러그인 아키텍처

**pom.xml 예시**:
```xml
<project xmlns="http://maven.apache.org/POM/4.0.0">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.example</groupId>
  <artifactId>myapp</artifactId>
  <version>1.0.0</version>
  <packaging>jar</packaging>

  <properties>
    <maven.compiler.source>17</maven.compiler.source>
    <maven.compiler.target>17</maven.compiler.target>
    <spring.boot.version>3.1.0</spring.boot.version>
  </properties>

  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
      <version>${spring.boot.version}</version>
    </dependency>

    <dependency>
      <groupId>org.junit.jupiter</groupId>
      <artifactId>junit-jupiter</artifactId>
      <version>5.9.3</version>
      <scope>test</scope>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
        <version>${spring.boot.version}</version>
      </plugin>

      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-surefire-plugin</artifactId>
        <version>3.0.0</version>
      </plugin>
    </plugins>
  </build>
</project>
```

**Maven 명령어**:
```bash
# 의존성 다운로드
mvn dependency:resolve

# 컴파일
mvn compile

# 테스트
mvn test

# 패키징
mvn package

# 설치 (로컬 저장소)
mvn install

# 배포 (원격 저장소)
mvn deploy

# 전체 빌드 (clean + package)
mvn clean package

# 특정 테스트 실행
mvn test -Dtest=MyTest
```

---

### 2. Gradle

**특징**:
- Groovy/Kotlin DSL
- 증분 빌드
- 빌드 캐시

**build.gradle (Groovy) 예시**:
```groovy
plugins {
    id 'java'
    id 'org.springframework.boot' version '3.1.0'
}

group = 'com.example'
version = '1.0.0'
sourceCompatibility = '17'

repositories {
    mavenCentral()
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}

tasks.named('test') {
    useJUnitPlatform()
}

// 커스텀 태스크
task hello {
    doLast {
        println 'Hello, Gradle!'
    }
}
```

**build.gradle.kts (Kotlin) 예시**:
```kotlin
plugins {
    java
    id("org.springframework.boot") version "3.1.0"
}

group = "com.example"
version = "1.0.0"

repositories {
    mavenCentral()
}

dependencies {
    implementation("org.springframework.boot:spring-boot-starter-web")
    testImplementation("org.springframework.boot:spring-boot-starter-test")
}

tasks.test {
    useJUnitPlatform()
}
```

**Gradle 명령어**:
```bash
# 빌드
./gradlew build

# 테스트
./gradlew test

# 클린 빌드
./gradlew clean build

# 태스크 목록
./gradlew tasks

# 의존성 트리
./gradlew dependencies

# 데몬 중지
./gradlew --stop
```

---

### 3. npm (Node Package Manager)

**특징**:
- Node.js 기본 패키지 매니저
- package.json
- npm scripts

**package.json 예시**:
```json
{
  "name": "myapp",
  "version": "1.0.0",
  "description": "My application",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "dev": "nodemon --watch src --exec ts-node src/index.ts",
    "test": "jest",
    "lint": "eslint src/**/*.ts",
    "format": "prettier --write src/**/*.ts"
  },
  "dependencies": {
    "express": "^4.18.2",
    "dotenv": "^16.0.3"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "@types/express": "^4.17.17",
    "typescript": "^5.0.4",
    "ts-node": "^10.9.1",
    "nodemon": "^2.0.22",
    "jest": "^29.5.0",
    "eslint": "^8.40.0",
    "prettier": "^2.8.8"
  }
}
```

**npm 명령어**:
```bash
# 의존성 설치
npm install

# 개발 의존성 추가
npm install --save-dev jest

# 프로덕션 의존성 추가
npm install express

# 스크립트 실행
npm run build
npm start
npm test

# 전역 설치
npm install -g typescript

# 버전 업데이트
npm update

# 취약점 검사
npm audit
npm audit fix
```

---

### 4. Webpack

**특징**:
- 모듈 번들러
- 로더 및 플러그인
- Code Splitting

**webpack.config.js 예시**:
```javascript
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

module.exports = {
  mode: 'production',
  entry: './src/index.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: '[name].[contenthash].js',
    clean: true,
  },

  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env', '@babel/preset-react'],
          },
        },
      },
      {
        test: /\.css$/,
        use: [MiniCssExtractPlugin.loader, 'css-loader'],
      },
      {
        test: /\.(png|svg|jpg|jpeg|gif)$/i,
        type: 'asset/resource',
      },
    ],
  },

  plugins: [
    new HtmlWebpackPlugin({
      template: './src/index.html',
    }),
    new MiniCssExtractPlugin({
      filename: '[name].[contenthash].css',
    }),
  ],

  optimization: {
    splitChunks: {
      chunks: 'all',
      cacheGroups: {
        vendor: {
          test: /[\\/]node_modules[\\/]/,
          name: 'vendors',
          priority: 10,
        },
      },
    },
  },

  devServer: {
    static: './dist',
    hot: true,
    port: 3000,
  },
};
```

---

### 5. Vite

**특징**:
- 빠른 개발 서버 (ESM 기반)
- HMR (Hot Module Replacement)
- Rollup 기반 프로덕션 빌드

**vite.config.js 예시**:
```javascript
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  build: {
    outDir: 'dist',
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
        },
      },
    },
  },
  server: {
    port: 3000,
    open: true,
  },
});
```

**Vite 명령어**:
```bash
# 개발 서버 시작
vite

# 빌드
vite build

# 프리뷰 (빌드된 결과물)
vite preview
```

---

## 📦 패키지 관리자 비교

### npm vs Yarn vs pnpm

| 특성 | npm | Yarn | pnpm |
|------|-----|------|------|
| **속도** | 보통 | 빠름 | 매우 빠름 |
| **디스크** | 많이 사용 | 많이 사용 | 효율적 (Hard Link) |
| **Lockfile** | package-lock.json | yarn.lock | pnpm-lock.yaml |
| **Monorepo** | Workspaces | Workspaces | Workspaces |
| **Offline** | 제한적 | 지원 | 지원 |

---

## 🚀 빌드 최적화

### 1. 캐싱

```yaml
Gradle Build Cache:
  org.gradle.caching=true

Maven:
  <plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <configuration>
      <useIncrementalCompilation>true</useIncrementalCompilation>
    </configuration>
  </plugin>

npm:
  npm ci  # clean install (CI 환경)
```

---

### 2. 병렬 빌드

```yaml
Gradle:
  ./gradlew build --parallel

Maven:
  mvn -T 4 clean install  # 4 스레드

npm:
  npm install --prefer-offline
```

---

### 3. 의존성 최적화

```yaml
Tree Shaking (Webpack/Vite):
  - 사용하지 않는 코드 제거
  - ES 모듈 사용

Bundle Analysis:
  - webpack-bundle-analyzer
  - rollup-plugin-visualizer

의존성 중복 제거:
  - npm dedupe
  - yarn dedupe
```

---

## 🔒 Zone별 배치

| Zone | 배치 | 구성요소 |
|------|------|----------|
| **Zone 2** | Common | Build Agents (CI/CD) |
| **Zone 4** | Common | Artifact Repository |

---

## ⚡ 실무 고려사항

### 1. CI/CD 통합

```yaml
GitHub Actions:
  - name: Build with Maven
    run: mvn clean package

  - name: Build with Gradle
    run: ./gradlew build

  - name: Build with npm
    run: |
      npm ci
      npm run build

  - name: Upload artifacts
    uses: actions/upload-artifact@v3
    with:
      name: build-artifacts
      path: dist/
```

---

### 2. 빌드 재현성

```yaml
필수 요소:
  - Lockfile 사용 (package-lock.json, yarn.lock)
  - 고정 버전 (정확한 버전 명시)
  - 환경 격리 (Docker)

예시:
  npm ci  # package-lock.json 기반 설치
  mvn install -DskipTests  # 테스트 스킵 (빠른 빌드)
```

---

### 3. 멀티 스테이지 빌드 (Docker)

```dockerfile
# 빌드 스테이지
FROM maven:3.9-amazoncorretto-17 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn package -DskipTests

# 실행 스테이지
FROM amazoncorretto:17-alpine
WORKDIR /app
COPY --from=builder /app/target/myapp.jar ./app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

---

## 🔗 관련 문서

- [Layer 4 정의](../00_Layer_4_정의.md)
- [CI/CD](../01_CICD/00_CICD_정의.md)
- [Container Registry](../05_Container_Registry/00_Container_Registry_정의.md)

---

**문서 끝**
