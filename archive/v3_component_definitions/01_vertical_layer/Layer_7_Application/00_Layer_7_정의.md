# Layer 7: Application (애플리케이션)

## 📋 Layer 정보

| 속성 | 값 |
|------|-----|
| **Layer 번호** | 7 |
| **한글명** | 애플리케이션 |
| **영문명** | Application |
| **변경 빈도** | Very High (일 단위) |
| **복잡도** | Medium-High |
| **다이어그램 위치** | 최상단 |

---

## 🎯 정의

Layer 7은 **사용자에게 직접 서비스를 제공하는 애플리케이션 계층**입니다.

---

## 🏗️ 주요 구성요소

| 번호 | 구성요소 | 설명 | 문서 링크 |
|------|---------|------|-----------|
| 1 | **Frontend** | 웹 프론트엔드 (React, Vue, Angular) | [상세 문서](01_Frontend/00_Frontend_정의.md) |
| 2 | **Backend API** | 백엔드 API (Node.js, Spring, Django) | [상세 문서](02_Backend_API/00_Backend_API_정의.md) |
| 3 | **API Gateway** | API 게이트웨이 | [상세 문서](03_API_Gateway/00_API_Gateway_정의.md) |
| 4 | **GraphQL** | GraphQL 서버 | [상세 문서](04_GraphQL/00_GraphQL_정의.md) |
| 5 | **Serverless** | 서버리스 함수 (Lambda, Cloud Functions) | [상세 문서](05_Serverless/00_Serverless_정의.md) |
| 6 | **Mobile Backend** | 모바일 백엔드 | [상세 문서](06_Mobile_Backend/00_Mobile_Backend_정의.md) |

---

## 🔒 Zone별 배치 개요

| Zone | 배치 빈도 | 주요 구성요소 |
|------|----------|-----------------|
| **Zone 1** | Very Common | Frontend (Static), API Gateway |
| **Zone 2** | Very Common | Backend API, Application Server |

---

## 🔗 관련 문서

- [Layer 6: Runtime](../Layer_6_Runtime/00_Layer_6_정의.md)
- [Cross-Layer: Management](../CrossLayer_Management/00_CrossLayer_정의.md)

---

**문서 끝**
