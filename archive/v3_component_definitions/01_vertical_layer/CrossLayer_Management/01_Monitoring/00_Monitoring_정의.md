# Monitoring (모니터링)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Monitoring |
| **한글명** | 모니터링 |
| **Layer** | Cross-Layer (Management) |
| **분류** | Observability |
| **Function Tag (Primary)** | M1.1 (Metrics) |
| **Function Tag (Secondary)** | M1.2 (Logging), M1.3 (Tracing) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

Monitoring은 **시스템의 상태를 실시간으로 수집, 분석, 시각화하는 관찰성(Observability) 시스템**입니다.

---

## 🏗️ 3가지 Observability Pillar

### 1. Metrics (메트릭)

**Prometheus + Grafana**

```yaml
# Prometheus 설정
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'application'
    static_configs:
      - targets: ['app1:8080', 'app2:8080']
```

```python
# Python 애플리케이션에서 메트릭 수집
from prometheus_client import Counter, Histogram, start_http_server
import time

# 메트릭 정의
request_count = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint'])
request_duration = Histogram('http_request_duration_seconds', 'HTTP request latency')

@request_duration.time()
def handle_request(method, endpoint):
    request_count.labels(method=method, endpoint=endpoint).inc()
    # 비즈니스 로직
    time.sleep(0.1)

# Prometheus 서버 시작
start_http_server(8000)
```

**주요 메트릭**:
```yaml
인프라:
  - CPU 사용률: node_cpu_seconds_total
  - 메모리 사용률: node_memory_MemAvailable_bytes
  - 디스크 사용률: node_filesystem_avail_bytes

애플리케이션:
  - 요청 수: http_requests_total
  - 응답 시간: http_request_duration_seconds
  - 에러율: http_requests_failed_total

데이터베이스:
  - 연결 수: db_connections_active
  - 쿼리 시간: db_query_duration_seconds
  - 트랜잭션 수: db_transactions_total
```

---

### 2. Logging (로깅)

**ELK Stack (Elasticsearch + Logstash + Kibana)**

```yaml
# Filebeat 설정
filebeat.inputs:
  - type: log
    enabled: true
    paths:
      - /var/log/nginx/*.log
      - /var/log/app/*.log

output.elasticsearch:
  hosts: ["localhost:9200"]
  index: "logs-%{+yyyy.MM.dd}"
```

```python
# 구조화된 로깅
import logging
import json

class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_data = {
            'timestamp': self.formatTime(record),
            'level': record.levelname,
            'message': record.getMessage(),
            'module': record.module,
            'function': record.funcName,
            'line': record.lineno
        }
        return json.dumps(log_data)

logger = logging.getLogger(__name__)
handler = logging.StreamHandler()
handler.setFormatter(JSONFormatter())
logger.addHandler(handler)

# 사용
logger.info('User login successful', extra={'user_id': 123, 'ip': '192.168.1.1'})
```

---

### 3. Tracing (분산 추적)

**Jaeger (OpenTelemetry)**

```python
from opentelemetry import trace
from opentelemetry.exporter.jaeger.thrift import JaegerExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

# Tracer 설정
trace.set_tracer_provider(TracerProvider())
jaeger_exporter = JaegerExporter(
    agent_host_name="localhost",
    agent_port=6831,
)
trace.get_tracer_provider().add_span_processor(
    BatchSpanProcessor(jaeger_exporter)
)

tracer = trace.get_tracer(__name__)

# Span 생성
def process_order(order_id):
    with tracer.start_as_current_span("process_order") as span:
        span.set_attribute("order.id", order_id)

        # 하위 작업
        with tracer.start_as_current_span("validate_order"):
            validate(order_id)

        with tracer.start_as_current_span("charge_payment"):
            charge(order_id)

        with tracer.start_as_current_span("ship_order"):
            ship(order_id)
```

---

## 📊 AWS CloudWatch

```python
import boto3

cloudwatch = boto3.client('cloudwatch')

# 메트릭 전송
cloudwatch.put_metric_data(
    Namespace='MyApp',
    MetricData=[
        {
            'MetricName': 'ResponseTime',
            'Value': 0.5,
            'Unit': 'Seconds',
            'Timestamp': datetime.utcnow()
        },
    ]
)

# 알람 생성
cloudwatch.put_metric_alarm(
    AlarmName='HighCPU',
    ComparisonOperator='GreaterThanThreshold',
    EvaluationPeriods=2,
    MetricName='CPUUtilization',
    Namespace='AWS/EC2',
    Period=300,
    Statistic='Average',
    Threshold=80.0,
    ActionsEnabled=True,
    AlarmActions=['arn:aws:sns:region:account-id:topic-name']
)
```

**가격**:
```yaml
CloudWatch:
  - Metrics: $0.30 per metric/월
  - Logs: $0.50 per GB ingested
  - Alarms: $0.10 per alarm/월

Datadog:
  - Pro: $15 per host/월
  - Enterprise: $23 per host/월
```

---

## 🚨 알람 설정

```yaml
# Prometheus Alertmanager
groups:
  - name: example
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_failed_total[5m]) > 0.05
        for: 10m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }}% over the last 5 minutes"

      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes > 0.9
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage"
```

---

## 🔒 Zone별 배치

| Zone | 배치 | 용도 |
|------|------|------|
| **Zone 0** | Very Common | 중앙 모니터링 서버 |
| **All Zones** | Very Common | 에이전트 배포 |

---

## 🔗 관련 문서

- [Cross-Layer 정의](../00_CrossLayer_정의.md)
- [SIEM](../04_SIEM/00_SIEM_정의.md)

---

**문서 끝**
