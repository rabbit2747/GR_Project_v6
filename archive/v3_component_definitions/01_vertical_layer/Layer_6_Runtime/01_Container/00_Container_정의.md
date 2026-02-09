# Container (컨테이너)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Container |
| **한글명** | 컨테이너 |
| **Layer** | Layer 6 (Runtime) |
| **분류** | Container Runtime |
| **Function Tag (Primary)** | R1.1 (Docker) |
| **Function Tag (Secondary)** | R1.2 (containerd) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

컨테이너는 **애플리케이션과 모든 의존성을 패키징한 격리된 실행 환경**입니다.

---

## 🏗️ Docker 기본

### Dockerfile

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["node", "index.js"]
```

### 주요 명령어

```bash
# 이미지 빌드
docker build -t myapp:1.0 .

# 컨테이너 실행
docker run -d -p 3000:3000 --name myapp myapp:1.0

# 로그 확인
docker logs myapp

# 컨테이너 중지
docker stop myapp

# 컨테이너 삭제
docker rm myapp
```

---

## 📊 Container vs VM

| 항목 | Container | VM |
|------|-----------|-----|
| **부팅** | 초 단위 | 분 단위 |
| **크기** | MB | GB |
| **격리** | 프로세스 | 완전 |
| **오버헤드** | 낮음 | 높음 |

---

## 🔒 Zone별 배치

| Zone | 배치 | 용도 |
|------|------|------|
| **Zone 2** | Very Common | Application Containers |

---

## 🔗 관련 문서

- [Layer 6 정의](../00_Layer_6_정의.md)
- [Orchestration](../02_Orchestration/00_Orchestration_정의.md)

---

**문서 끝**
