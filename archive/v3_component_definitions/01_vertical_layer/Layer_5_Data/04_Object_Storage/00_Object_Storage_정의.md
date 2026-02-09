# Object Storage (객체 스토리지)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | Object Storage |
| **한글명** | 객체 스토리지 |
| **Layer** | Layer 5 (Data Services) |
| **분류** | Unstructured Data Storage |
| **Function Tag (Primary)** | D4.1 (Cloud Storage) |
| **Function Tag (Secondary)** | D4.2 (On-Premise Storage) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

객체 스토리지는 **비구조화된 데이터를 객체 단위로 저장하는 확장 가능한 스토리지**입니다.

---

## 🏗️ 주요 객체 스토리지

### 1. AWS S3

**특징**: 높은 내구성(99.999999999%), 무제한 확장

**사용 예시**:
```python
import boto3

s3 = boto3.client('s3')

# 업로드
s3.upload_file('local.jpg', 'my-bucket', 'images/photo.jpg')

# 다운로드
s3.download_file('my-bucket', 'images/photo.jpg', 'download.jpg')

# 삭제
s3.delete_object(Bucket='my-bucket', Key='images/photo.jpg')

# Presigned URL (임시 접근)
url = s3.generate_presigned_url(
    'get_object',
    Params={'Bucket': 'my-bucket', 'Key': 'images/photo.jpg'},
    ExpiresIn=3600
)
```

**가격**:
```yaml
Standard:
  - Storage: $0.023/GB/월
  - PUT: $0.005 per 1,000 requests
  - GET: $0.0004 per 1,000 requests

Glacier (아카이브):
  - Storage: $0.004/GB/월
  - 복원: 시간당 요금
```

**Storage Classes**:
```yaml
Standard: 자주 접근
Intelligent-Tiering: 자동 최적화
Standard-IA: 드문 접근
Glacier: 아카이브 (검색 시간: 분~시간)
Glacier Deep Archive: 장기 아카이브 (검색: 12시간)
```

---

### 2. MinIO (자체 호스팅)

**특징**: S3 호환 API, 오픈소스

**설치**:
```bash
docker run -p 9000:9000 -p 9001:9001 \
  -e "MINIO_ROOT_USER=admin" \
  -e "MINIO_ROOT_PASSWORD=password" \
  minio/minio server /data --console-address ":9001"
```

---

## 📊 활용 사례

```yaml
정적 웹사이트 호스팅:
  - S3 Static Website
  - CDN 통합 (CloudFront)

백업 및 아카이브:
  - 데이터베이스 백업
  - 로그 아카이브

미디어 저장:
  - 이미지, 비디오
  - 사용자 업로드 파일

빅데이터:
  - Data Lake
  - 분석 원본 데이터
```

---

## 🔒 보안

```yaml
버킷 정책:
  {
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-bucket/public/*"
    }]
  }

암호화:
  - SSE-S3: S3 관리 키
  - SSE-KMS: AWS KMS
  - SSE-C: 고객 제공 키
```

---

## 🔒 Zone별 배치

| Zone | 배치 | 용도 |
|------|------|------|
| **Zone 3** | Common | Private Object Storage |
| **Zone 1** | Common | Public Object Storage (CDN 연동) |

---

## 🔗 관련 문서

- [Layer 5 정의](../00_Layer_5_정의.md)
- [Backup](../06_Backup/00_Backup_정의.md)
- [CDN](../../Layer_2_Network/06_CDN/00_CDN_정의.md)

---

**문서 끝**
