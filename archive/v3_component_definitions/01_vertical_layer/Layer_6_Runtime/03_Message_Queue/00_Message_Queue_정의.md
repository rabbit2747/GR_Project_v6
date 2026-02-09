# Message Queue (메시지 큐)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Message Queue |
| **한글명** | 메시지 큐 |
| **Layer** | Layer 6 (Runtime) |
| **분류** | Asynchronous Messaging |
| **Function Tag (Primary)** | R3.1 (Message Broker) |
| **Function Tag (Secondary)** | R3.2 (Event Streaming) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

메시지 큐는 **비동기 메시징을 통해 서비스 간 통신을 중개하는 시스템**입니다.

---

## 🏗️ 주요 메시지 큐

### 1. RabbitMQ

**특징**: AMQP 프로토콜, 높은 신뢰성

**사용 예시**:
```python
import pika

connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
channel = connection.channel()

# 큐 선언
channel.queue_declare(queue='tasks')

# 메시지 발행
channel.basic_publish(exchange='', routing_key='tasks', body='Hello')

# 메시지 소비
def callback(ch, method, properties, body):
    print(f"Received {body}")
    ch.basic_ack(delivery_tag=method.delivery_tag)

channel.basic_consume(queue='tasks', on_message_callback=callback)
channel.start_consuming()
```

---

### 2. Apache Kafka

**특징**: 고처리량, 이벤트 스트리밍

**사용 예시**:
```python
from kafka import KafkaProducer, KafkaConsumer

# Producer
producer = KafkaProducer(bootstrap_servers=['localhost:9092'])
producer.send('events', b'event data')

# Consumer
consumer = KafkaConsumer('events', bootstrap_servers=['localhost:9092'])
for message in consumer:
    print(message.value)
```

---

### 3. AWS SQS

**특징**: 완전 관리형, 무제한 확장

**가격**:
```yaml
Standard Queue:
  - 처음 1M requests: 무료
  - $0.40 per 1M requests

FIFO Queue:
  - $0.50 per 1M requests
```

---

## 📊 사용 패턴

```yaml
Work Queue (작업 큐):
  - 비동기 작업 처리
  - 이메일 발송, 이미지 처리

Pub/Sub (발행/구독):
  - 여러 구독자에게 메시지 전달
  - 이벤트 알림

Event Streaming:
  - 실시간 이벤트 처리
  - 로그 수집, 분석
```

---

## 🔒 Zone별 배치

| Zone | 배치 | 용도 |
|------|------|------|
| **Zone 2** | Common | Message Broker |
| **Zone 3** | Common | Event Streaming |

---

## 🔗 관련 문서

- [Layer 6 정의](../00_Layer_6_정의.md)
- [Orchestration](../02_Orchestration/00_Orchestration_정의.md)

---

**문서 끝**
