# Auto Scaling (자동 확장)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Auto Scaling |
| **한글명** | 자동 확장 |
| **Layer** | Layer 3 (Computing Infrastructure) |
| **분류** | Elastic Compute |
| **Function Tag (Primary)** | C5.1 (Horizontal Scaling) |
| **Function Tag (Secondary)** | C5.2 (Vertical Scaling) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

Auto Scaling은 **트래픽 변화에 따라 컴퓨팅 리소스를 자동으로 증감하는 시스템**입니다.

### 핵심 기능

1. **동적 용량 조정**
   - 수요에 따른 자동 증감
   - 비용 최적화
   - 고가용성 유지

2. **상태 모니터링**
   - 인스턴스 헬스 체크
   - 장애 인스턴스 자동 교체
   - 로드 밸런서 통합

3. **예측 및 스케줄링**
   - 시간 기반 스케일링
   - 예측 스케일링 (ML 기반)
   - 이벤트 기반 스케일링

---

## 🏗️ Auto Scaling 유형

### 1. Horizontal Scaling (수평 확장)

```
인스턴스 수를 증감

Before (2 instances):
[VM1] [VM2]
  ↓      ↓
  [LB]

After Scale Out (4 instances):
[VM1] [VM2] [VM3] [VM4]
  ↓      ↓      ↓      ↓
       [LB]

장점:
- 무제한 확장 가능
- 고가용성 (단일 장애점 없음)
- 클라우드 네이티브

단점:
- 복잡한 상태 관리
- 네트워크 오버헤드
```

---

### 2. Vertical Scaling (수직 확장)

```
인스턴스 크기 증가

Before:
[VM: 2 vCPU, 4GB]

After Scale Up:
[VM: 8 vCPU, 16GB]

장점:
- 간단한 구현
- 상태 유지 쉬움
- 레거시 앱 호환

단점:
- 확장 한계 (하드웨어)
- 다운타임 발생
- 비용 증가
```

---

## ☁️ 주요 Auto Scaling 서비스

### 1. AWS Auto Scaling Group (ASG)

**구성요소**:
```yaml
Launch Template:
  - AMI, 인스턴스 타입
  - 보안 그룹, 키 페어
  - User Data (초기화 스크립트)

Auto Scaling Group:
  - Min: 2
  - Desired: 4
  - Max: 10
  - 가용 영역: Multi-AZ

Scaling Policy:
  - Target Tracking
  - Step Scaling
  - Simple Scaling
```

**Launch Template 예시**:
```json
{
  "LaunchTemplateName": "web-server-template",
  "VersionDescription": "v1",
  "LaunchTemplateData": {
    "ImageId": "ami-0c55b159cbfafe1f0",
    "InstanceType": "t3.medium",
    "KeyName": "my-key",
    "SecurityGroupIds": ["sg-0123456789"],
    "UserData": "IyEvYmluL2Jhc2gKY3VybCAtc0wgaHR0cDovL2dpdC5pby9ub2RlanMgfCBiYXNo",
    "TagSpecifications": [{
      "ResourceType": "instance",
      "Tags": [{"Key": "Name", "Value": "Web-ASG"}]
    }]
  }
}
```

**ASG 생성** (AWS CLI):
```bash
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name web-asg \
  --launch-template LaunchTemplateName=web-server-template \
  --min-size 2 \
  --max-size 10 \
  --desired-capacity 4 \
  --vpc-zone-identifier "subnet-a,subnet-b,subnet-c" \
  --target-group-arns "arn:aws:elasticloadbalancing:..." \
  --health-check-type ELB \
  --health-check-grace-period 300
```

---

### 2. Azure Virtual Machine Scale Sets (VMSS)

**특징**:
- 동일 VM 세트 관리
- Load Balancer 통합
- 최대 1,000개 인스턴스

**생성 예시** (Azure CLI):
```bash
az vmss create \
  --resource-group myResourceGroup \
  --name myScaleSet \
  --image UbuntuLTS \
  --vm-sku Standard_B2s \
  --instance-count 4 \
  --admin-username azureuser \
  --generate-ssh-keys \
  --load-balancer myLoadBalancer \
  --vnet-name myVnet \
  --subnet mySubnet
```

---

### 3. Google Cloud Instance Groups

**유형**:
- **Managed Instance Groups (MIG)**: 자동 확장, 자가 치유
- **Unmanaged Instance Groups**: 수동 관리

**MIG 생성**:
```bash
gcloud compute instance-groups managed create web-mig \
  --base-instance-name web \
  --template web-template \
  --size 4 \
  --zone us-central1-a
```

---

## 📊 Scaling Policy (확장 정책)

### 1. Target Tracking Scaling (대상 추적)

```yaml
정의:
  특정 메트릭을 목표값으로 유지

예시:
  메트릭: CPU Utilization
  목표값: 50%

동작:
  - CPU 60% → Scale Out (인스턴스 추가)
  - CPU 40% → Scale In (인스턴스 제거)
  - 자동으로 조정량 계산

장점:
  - 간단한 설정
  - 자동 조정
  - 권장 방식
```

**AWS 예시**:
```json
{
  "TargetValue": 50.0,
  "PredefinedMetricSpecification": {
    "PredefinedMetricType": "ASGAverageCPUUtilization"
  }
}
```

---

### 2. Step Scaling (단계 확장)

```yaml
정의:
  임계값 단계에 따라 조정

예시:
  CPU < 40% → Scale In (1개 제거)
  CPU 40-60% → 유지
  CPU 60-80% → Scale Out (2개 추가)
  CPU > 80% → Scale Out (4개 추가)

장점:
  - 세밀한 제어
  - 급격한 변화 대응
```

**AWS 예시**:
```json
{
  "AdjustmentType": "ChangeInCapacity",
  "MetricAggregationType": "Average",
  "StepAdjustments": [
    {
      "MetricIntervalLowerBound": 0,
      "MetricIntervalUpperBound": 10,
      "ScalingAdjustment": 1
    },
    {
      "MetricIntervalLowerBound": 10,
      "MetricIntervalUpperBound": 20,
      "ScalingAdjustment": 2
    },
    {
      "MetricIntervalLowerBound": 20,
      "ScalingAdjustment": 4
    }
  ]
}
```

---

### 3. Scheduled Scaling (예약 확장)

```yaml
정의:
  특정 시간에 용량 조정

예시:
  평일 09:00 → 10 인스턴스
  평일 18:00 → 4 인스턴스
  주말 → 2 인스턴스

용도:
  - 예측 가능한 트래픽 패턴
  - 비용 최적화
```

**AWS 예시**:
```bash
# 평일 아침 스케일 아웃
aws autoscaling put-scheduled-action \
  --auto-scaling-group-name web-asg \
  --scheduled-action-name morning-scale-out \
  --recurrence "0 9 * * 1-5" \
  --desired-capacity 10

# 평일 저녁 스케일 인
aws autoscaling put-scheduled-action \
  --auto-scaling-group-name web-asg \
  --scheduled-action-name evening-scale-in \
  --recurrence "0 18 * * 1-5" \
  --desired-capacity 4
```

---

### 4. Predictive Scaling (예측 확장)

```yaml
정의:
  ML 기반 트래픽 예측 후 사전 확장

작동:
  1. 과거 데이터 분석 (2주)
  2. 패턴 학습 (일별, 주별)
  3. 미래 부하 예측
  4. 사전 프로비저닝

장점:
  - 트래픽 급증 대응
  - 지연 없는 확장
  - 비용 최적화

지원:
  - AWS (Predictive Scaling)
  - Azure (Autoscale with ML)
```

---

## 🔧 Scaling Metrics (확장 메트릭)

### 주요 메트릭

| 메트릭 | 설명 | 권장 임계값 |
|--------|------|------------|
| **CPU Utilization** | CPU 사용률 | 50-70% |
| **Memory Utilization** | 메모리 사용률 | 70-80% |
| **Request Count** | 요청 수 (ALB) | 1000 req/instance |
| **Network In/Out** | 네트워크 트래픽 | 변동적 |
| **Queue Length** | 메시지 큐 길이 | 10 msgs/instance |
| **Response Time** | 응답 시간 | <200ms |

---

### Custom Metrics (커스텀 메트릭)

```python
# AWS CloudWatch Custom Metric 전송
import boto3

cloudwatch = boto3.client('cloudwatch')

cloudwatch.put_metric_data(
    Namespace='MyApp',
    MetricData=[
        {
            'MetricName': 'ActiveConnections',
            'Value': 1250,
            'Unit': 'Count',
            'Timestamp': datetime.utcnow()
        }
    ]
)
```

---

## ⚙️ Scaling 전략

### 1. Cooldown Period (재조정 대기 시간)

```yaml
목적:
  - 급격한 스케일링 방지
  - 비용 최적화
  - 안정성 확보

설정:
  Scale Out: 60초 (빠르게)
  Scale In: 300초 (천천히)

이유:
  - Scale Out: 트래픽 급증 대응
  - Scale In: Flapping 방지
```

---

### 2. Health Check (헬스 체크)

```yaml
EC2 Health Check:
  - 인스턴스 상태 확인
  - 실패 시 자동 교체

ELB Health Check:
  - HTTP/HTTPS 엔드포인트
  - 정상 응답 확인
  - 더 정확한 상태 판단

설정:
  Health Check Grace Period: 300초
  Unhealthy Threshold: 2회 연속 실패
```

**ELB Target Group Health Check**:
```json
{
  "HealthCheckEnabled": true,
  "HealthCheckIntervalSeconds": 30,
  "HealthCheckPath": "/health",
  "HealthCheckProtocol": "HTTP",
  "HealthCheckTimeoutSeconds": 5,
  "HealthyThresholdCount": 2,
  "UnhealthyThresholdCount": 2,
  "Matcher": {
    "HttpCode": "200"
  }
}
```

---

### 3. Instance Warm-up (인스턴스 준비 시간)

```yaml
정의:
  새 인스턴스가 트래픽을 받기 전 준비 시간

설정:
  Default Warmup: 300초

단계:
  1. 인스턴스 시작 (0s)
  2. User Data 실행 (0-120s)
  3. 애플리케이션 시작 (120-250s)
  4. Health Check 통과 (250-300s)
  5. 트래픽 수신 시작 (300s+)

주의:
  - Warmup 동안 메트릭 제외
  - 너무 짧으면 503 에러 발생
```

---

## 💰 비용 최적화

### 1. Min/Max/Desired 설정

```yaml
적절한 설정:
  Min: 2 (고가용성)
  Desired: 4 (평상시 부하)
  Max: 10 (피크 시간)

비용 영향:
  Min ↑ → 최소 비용 ↑
  Max ↑ → 최대 비용 ↑
  Desired → 평균 비용

권장:
  - Min: 최소 가용성 요구사항
  - Max: 예산 한도
  - Desired: 자동 조정 (Scaling Policy)
```

---

### 2. Scale In Protection (축소 보호)

```yaml
목적:
  특정 인스턴스를 Scale In에서 보호

Use Case:
  - 배치 작업 실행 중
  - 데이터 동기화 중
  - 중요 세션 처리 중

설정:
  aws autoscaling set-instance-protection \
    --instance-ids i-0123456789 \
    --auto-scaling-group-name web-asg \
    --protected-from-scale-in
```

---

### 3. Lifecycle Hooks (생명주기 후크)

```yaml
정의:
  인스턴스 시작/종료 시 커스텀 작업 수행

Use Case:
  Launching:
    - 설정 파일 다운로드
    - 캐시 워밍업
    - 서비스 등록

  Terminating:
    - 로그 저장
    - 연결 종료
    - 서비스 해제

Timeout:
  - Default: 3600초 (1시간)
  - 작업 완료 후 continue 호출
```

**Lambda 통합 예시**:
```python
# Lifecycle Hook Lambda
def lambda_handler(event, context):
    instance_id = event['detail']['EC2InstanceId']
    lifecycle_hook_name = event['detail']['LifecycleHookName']

    # 커스텀 작업 수행
    perform_cleanup(instance_id)

    # 완료 신호
    asg_client.complete_lifecycle_action(
        LifecycleHookName=lifecycle_hook_name,
        AutoScalingGroupName=asg_name,
        LifecycleActionResult='CONTINUE',
        InstanceId=instance_id
    )
```

---

## 🔒 Zone별 배치

| Zone | 배치 | 예시 |
|------|------|------|
| **Zone 1** | Common | Public Web 서버 ASG |
| **Zone 2** | Very Common | App 서버 ASG |
| **Zone 3** | Uncommon | Read Replica DB (스케일 아웃) |

---

## ⚡ 실무 고려사항

### 1. Multi-AZ 구성

```yaml
권장 구성:
  가용 영역: 최소 3개 (AZ-A, AZ-B, AZ-C)
  Min: 6 (각 AZ당 2개)

장점:
  - 고가용성
  - AZ 장애 대응
  - 네트워크 지연 최소화

주의:
  - 데이터 전송 비용 (Cross-AZ)
```

---

### 2. 스테이트리스 설계

```yaml
필수 요구사항:
  - 세션은 외부 저장 (Redis, DynamoDB)
  - 로그는 중앙 집중 (CloudWatch, ELK)
  - 파일은 공유 스토리지 (S3, EFS)

안티패턴:
  ❌ 로컬 세션 저장
  ❌ 로컬 파일 저장
  ❌ 인스턴스 간 상태 의존
```

---

### 3. 모니터링 및 알림

```yaml
주요 메트릭:
  - GroupDesiredCapacity (현재 목표)
  - GroupInServiceInstances (실행 중)
  - GroupPendingInstances (시작 중)
  - GroupTerminatingInstances (종료 중)

알림:
  - Desired Capacity 변경
  - Scale Out 실패
  - Unhealthy Instances
  - Max Capacity 도달
```

---

## 🔗 관련 문서

- [Layer 3 정의](../00_Layer_3_정의.md)
- [Virtual Machine](../02_Virtual_Machine/00_Virtual_Machine_정의.md)
- [Cloud Platform](../01_Cloud_Platform/00_Cloud_Platform_정의.md)
- [Load Balancer](../../Layer_2_Network/01_Load_Balancer/00_Load_Balancer_정의.md)

---

**문서 끝**
