# Layer 6: Runtime (런타임 환경)

## 📋 Layer 정보

| 속성 | 값 |
|------|-----|
| **Layer 번호** | 6 |
| **한글명** | 런타임 환경 |
| **영문명** | Runtime Environment |
| **변경 빈도** | High (일-주 단위) |
| **복잡도** | High |
| **다이어그램 위치** | 상단 (Layer 5 위) |

---

## 🎯 정의

Layer 6은 **애플리케이션이 실행되는 환경과 이를 관리하는 오케스트레이션 계층**입니다.

---

## 🏗️ 주요 구성요소

| 번호 | 구성요소 | 설명 | 문서 링크 |
|------|---------|------|-----------|
| 1 | **Container** | 컨테이너 런타임 (Docker, containerd) | [상세 문서](01_Container/00_Container_정의.md) |
| 2 | **Orchestration** | 컨테이너 오케스트레이션 (Kubernetes, ECS) | [상세 문서](02_Orchestration/00_Orchestration_정의.md) |
| 3 | **Message Queue** | 메시지 큐 (RabbitMQ, Kafka, SQS) | [상세 문서](03_Message_Queue/00_Message_Queue_정의.md) |
| 4 | **Service Mesh** | 서비스 메시 (Istio, Linkerd) | [상세 문서](04_Service_Mesh/00_Service_Mesh_정의.md) |

---

## 🔒 Zone별 배치 개요

| Zone | 배치 빈도 | 주요 구성요소 |
|------|----------|-----------------|
| **Zone 2** | Very Common | Container Runtime, Orchestration |
| **Zone 3** | Common | Message Queue |

---

## 🔗 관련 문서

- [Layer 5: Data Services](../Layer_5_Data/00_Layer_5_정의.md)
- [Layer 7: Application](../Layer_7_Application/00_Layer_7_정의.md)

---

**문서 끝**
