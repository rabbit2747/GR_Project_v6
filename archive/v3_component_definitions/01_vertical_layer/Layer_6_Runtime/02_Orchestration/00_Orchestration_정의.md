# Orchestration (오케스트레이션)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Orchestration |
| **한글명** | 오케스트레이션 |
| **Layer** | Layer 6 (Runtime) |
| **분류** | Container Orchestration |
| **Function Tag (Primary)** | R2.1 (Kubernetes) |
| **Function Tag (Secondary)** | R2.2 (ECS/EKS) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

오케스트레이션은 **컨테이너의 배포, 확장, 관리를 자동화하는 시스템**입니다.

---

## 🏗️ Kubernetes 기본

### Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myapp:1.0
        ports:
        - containerPort: 3000
        resources:
          limits:
            cpu: "500m"
            memory: "512Mi"
          requests:
            cpu: "250m"
            memory: "256Mi"
```

### Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  type: LoadBalancer
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 3000
```

---

## 📊 주요 명령어

```bash
# Pod 목록
kubectl get pods

# Deployment 생성
kubectl apply -f deployment.yaml

# 스케일링
kubectl scale deployment myapp --replicas=5

# 로그 확인
kubectl logs myapp-pod-name

# 롤링 업데이트
kubectl set image deployment/myapp myapp=myapp:2.0
```

---

## ⚡ 주요 기능

```yaml
자동 스케일링:
  - HPA (Horizontal Pod Autoscaler)
  - VPA (Vertical Pod Autoscaler)

롤링 업데이트:
  - 무중단 배포
  - 롤백 가능

셀프 힐링:
  - Pod 장애 자동 재시작
  - Health Check

로드 밸런싱:
  - Service 자동 로드 밸런싱
```

---

## 🔒 Zone별 배치

| Zone | 배치 | 용도 |
|------|------|------|
| **Zone 2** | Very Common | Kubernetes Cluster |

---

## 🔗 관련 문서

- [Layer 6 정의](../00_Layer_6_정의.md)
- [Container](../01_Container/00_Container_정의.md)

---

**문서 끝**
