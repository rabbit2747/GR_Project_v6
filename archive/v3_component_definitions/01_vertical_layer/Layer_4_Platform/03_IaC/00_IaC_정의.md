# IaC (Infrastructure as Code)

## 📋 구성요소 정보

| 속성 | 값 |
|------|-----|
| **구성요소명** | IaC (Infrastructure as Code) |
| **한글명** | 코드형 인프라 |
| **Layer** | Layer 4 (Platform Services) |
| **분류** | Automation & Provisioning |
| **Function Tag (Primary)** | P3.1 (IaC Tool) |
| **Function Tag (Secondary)** | P3.2 (Configuration Management) |
| **Function Tag (Control)** | 없음 |

---

## 🎯 정의

IaC는 **인프라 구성을 코드로 정의하고 자동화하는 방법론**입니다.

### 핵심 개념

1. **선언적 구성 (Declarative)**
   - 원하는 최종 상태 정의
   - 도구가 필요한 작업 자동 결정
   - 멱등성 (Idempotency)

2. **버전 관리**
   - Git으로 인프라 이력 관리
   - 코드 리뷰 프로세스
   - 롤백 가능

3. **재사용성**
   - 모듈화
   - 템플릿
   - 일관된 배포

---

## 🏗️ IaC 도구 분류

### 1. Provisioning (프로비저닝)

```
인프라 리소스 생성 및 관리

도구: Terraform, CloudFormation, Pulumi

용도:
- VPC, 서브넷 생성
- EC2, RDS 인스턴스 프로비저닝
- 로드 밸런서, DNS 설정
```

---

### 2. Configuration Management (구성 관리)

```
서버 설정 및 소프트웨어 설치

도구: Ansible, Chef, Puppet, SaltStack

용도:
- 패키지 설치
- 설정 파일 배포
- 서비스 관리
```

---

## 🛠️ 주요 IaC 도구

### 1. Terraform

**특징**:
- HashiCorp 개발
- 멀티 클라우드 지원
- HCL (HashiCorp Configuration Language)

**설치**:
```bash
# macOS
brew install terraform

# Linux
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform
```

**기본 예시** (`main.tf`):
```hcl
# Provider 설정
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

# VPC 생성
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "main-vpc"
    Environment = "production"
  }
}

# 서브넷 생성
resource "aws_subnet" "public" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

# EC2 인스턴스
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.public[0].id

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              systemctl start nginx
              EOF

  tags = {
    Name = "web-server"
  }
}

# 보안 그룹
resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-security-group"
  }
}

# Output
output "instance_ip" {
  value = aws_instance.web.public_ip
}
```

**모듈 예시** (`modules/vpc/main.tf`):
```hcl
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

output "vpc_id" {
  value = aws_vpc.this.id
}
```

**모듈 사용**:
```hcl
module "vpc" {
  source      = "./modules/vpc"
  vpc_cidr    = "10.0.0.0/16"
  environment = "production"
}
```

**Terraform 명령어**:
```bash
# 초기화
terraform init

# 실행 계획 확인
terraform plan

# 인프라 생성
terraform apply

# 인프라 삭제
terraform destroy

# 상태 확인
terraform show

# 특정 리소스만 적용
terraform apply -target=aws_instance.web

# 리소스 Import
terraform import aws_instance.web i-0123456789
```

---

### 2. AWS CloudFormation

**특징**:
- AWS 네이티브 IaC
- JSON/YAML 템플릿
- Change Sets (변경 미리보기)

**템플릿 예시** (`template.yaml`):
```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: Web server infrastructure

Parameters:
  InstanceType:
    Type: String
    Default: t3.medium
    AllowedValues:
      - t3.small
      - t3.medium
      - t3.large

  KeyName:
    Type: AWS::EC2::KeyPair::KeyName
    Description: EC2 Key Pair

Resources:
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
      EnableDnsHostnames: true
      EnableDnsSupport: true
      Tags:
        - Key: Name
          Value: MainVPC

  PublicSubnet:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.1.0/24
      AvailabilityZone: !Select [0, !GetAZs '']
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: PublicSubnet

  InternetGateway:
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
        - Key: Name
          Value: MainIGW

  AttachGateway:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      VpcId: !Ref VPC
      InternetGatewayId: !Ref InternetGateway

  RouteTable:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref VPC
      Tags:
        - Key: Name
          Value: PublicRouteTable

  Route:
    Type: AWS::EC2::Route
    DependsOn: AttachGateway
    Properties:
      RouteTableId: !Ref RouteTable
      DestinationCidrBlock: 0.0.0.0/0
      GatewayId: !Ref InternetGateway

  SubnetRouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref PublicSubnet
      RouteTableId: !Ref RouteTable

  WebServerSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Security group for web servers
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: 0.0.0.0/0
      SecurityGroupEgress:
        - IpProtocol: -1
          CidrIp: 0.0.0.0/0

  WebServerInstance:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: !Ref InstanceType
      ImageId: ami-0c55b159cbfafe1f0
      KeyName: !Ref KeyName
      SubnetId: !Ref PublicSubnet
      SecurityGroupIds:
        - !Ref WebServerSecurityGroup
      UserData:
        Fn::Base64: |
          #!/bin/bash
          yum update -y
          yum install -y httpd
          systemctl start httpd
          systemctl enable httpd
      Tags:
        - Key: Name
          Value: WebServer

Outputs:
  WebServerPublicIP:
    Description: Public IP of web server
    Value: !GetAtt WebServerInstance.PublicIp
    Export:
      Name: !Sub ${AWS::StackName}-WebServerIP

  VPCId:
    Description: VPC ID
    Value: !Ref VPC
    Export:
      Name: !Sub ${AWS::StackName}-VPC
```

**CloudFormation 명령어**:
```bash
# 스택 생성
aws cloudformation create-stack \
  --stack-name web-stack \
  --template-body file://template.yaml \
  --parameters ParameterKey=InstanceType,ParameterValue=t3.medium \
               ParameterKey=KeyName,ParameterValue=my-key

# 스택 업데이트
aws cloudformation update-stack \
  --stack-name web-stack \
  --template-body file://template.yaml

# Change Set 생성 (미리보기)
aws cloudformation create-change-set \
  --stack-name web-stack \
  --change-set-name my-changes \
  --template-body file://template.yaml

# Change Set 실행
aws cloudformation execute-change-set \
  --change-set-name my-changes \
  --stack-name web-stack

# 스택 삭제
aws cloudformation delete-stack \
  --stack-name web-stack

# 스택 상태 확인
aws cloudformation describe-stacks \
  --stack-name web-stack
```

---

### 3. Ansible

**특징**:
- Red Hat 개발
- 에이전트리스 (SSH 기반)
- YAML Playbook

**설치**:
```bash
# macOS
brew install ansible

# Ubuntu
sudo apt-add-repository ppa:ansible/ansible
sudo apt update
sudo apt install ansible
```

**Inventory 파일** (`inventory.ini`):
```ini
[webservers]
web1 ansible_host=10.0.1.10 ansible_user=ubuntu
web2 ansible_host=10.0.1.11 ansible_user=ubuntu

[dbservers]
db1 ansible_host=10.0.2.10 ansible_user=ubuntu

[all:vars]
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

**Playbook 예시** (`webserver.yml`):
```yaml
---
- name: Configure web servers
  hosts: webservers
  become: yes
  vars:
    nginx_port: 80
    app_user: www-data

  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes
        cache_valid_time: 3600

    - name: Install Nginx
      apt:
        name: nginx
        state: present

    - name: Install Python dependencies
      apt:
        name:
          - python3-pip
          - python3-venv
        state: present

    - name: Copy Nginx configuration
      template:
        src: templates/nginx.conf.j2
        dest: /etc/nginx/sites-available/default
      notify: Restart Nginx

    - name: Create app directory
      file:
        path: /var/www/myapp
        state: directory
        owner: "{{ app_user }}"
        group: "{{ app_user }}"
        mode: '0755'

    - name: Deploy application
      copy:
        src: ../dist/
        dest: /var/www/myapp/
        owner: "{{ app_user }}"
        group: "{{ app_user }}"

    - name: Ensure Nginx is started
      service:
        name: nginx
        state: started
        enabled: yes

  handlers:
    - name: Restart Nginx
      service:
        name: nginx
        state: restarted
```

**템플릿** (`templates/nginx.conf.j2`):
```nginx
server {
    listen {{ nginx_port }};
    server_name _;

    root /var/www/myapp;
    index index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    location /api {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

**Ansible 명령어**:
```bash
# Playbook 실행
ansible-playbook -i inventory.ini webserver.yml

# Dry run (체크 모드)
ansible-playbook -i inventory.ini webserver.yml --check

# 특정 태그만 실행
ansible-playbook -i inventory.ini webserver.yml --tags "deploy"

# Ad-hoc 명령어
ansible webservers -i inventory.ini -m ping
ansible webservers -i inventory.ini -m shell -a "uptime"
ansible webservers -i inventory.ini -m apt -a "name=nginx state=present" --become
```

---

### 4. Pulumi

**특징**:
- 실제 프로그래밍 언어 사용
- TypeScript, Python, Go, C#
- 멀티 클라우드

**설치**:
```bash
curl -fsSL https://get.pulumi.com | sh
```

**TypeScript 예시**:
```typescript
import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";

// VPC 생성
const vpc = new aws.ec2.Vpc("main-vpc", {
    cidrBlock: "10.0.0.0/16",
    enableDnsHostnames: true,
    enableDnsSupport: true,
    tags: {
        Name: "main-vpc",
    },
});

// 서브넷 생성
const publicSubnet = new aws.ec2.Subnet("public-subnet", {
    vpcId: vpc.id,
    cidrBlock: "10.0.1.0/24",
    availabilityZone: "ap-northeast-2a",
    mapPublicIpOnLaunch: true,
    tags: {
        Name: "public-subnet",
    },
});

// 보안 그룹
const webSg = new aws.ec2.SecurityGroup("web-sg", {
    vpcId: vpc.id,
    description: "Security group for web servers",
    ingress: [
        { protocol: "tcp", fromPort: 80, toPort: 80, cidrBlocks: ["0.0.0.0/0"] },
        { protocol: "tcp", fromPort: 443, toPort: 443, cidrBlocks: ["0.0.0.0/0"] },
    ],
    egress: [
        { protocol: "-1", fromPort: 0, toPort: 0, cidrBlocks: ["0.0.0.0/0"] },
    ],
});

// EC2 인스턴스
const webServer = new aws.ec2.Instance("web-server", {
    ami: "ami-0c55b159cbfafe1f0",
    instanceType: "t3.medium",
    subnetId: publicSubnet.id,
    vpcSecurityGroupIds: [webSg.id],
    userData: `#!/bin/bash
        apt-get update
        apt-get install -y nginx
        systemctl start nginx
    `,
    tags: {
        Name: "web-server",
    },
});

// Output
export const publicIp = webServer.publicIp;
export const vpcId = vpc.id;
```

**Pulumi 명령어**:
```bash
# 프로젝트 초기화
pulumi new aws-typescript

# 미리보기
pulumi preview

# 배포
pulumi up

# 상태 확인
pulumi stack

# 스택 삭제
pulumi destroy
```

---

## 📊 IaC 도구 비교

| 특성 | Terraform | CloudFormation | Ansible | Pulumi |
|------|-----------|----------------|---------|--------|
| **언어** | HCL | YAML/JSON | YAML | TypeScript/Python/Go |
| **클라우드** | Multi | AWS only | Multi | Multi |
| **상태 관리** | State file | AWS 관리 | Stateless | State service |
| **러닝 커브** | 중간 | 중간 | 낮음 | 중간-높음 |
| **용도** | Provisioning | Provisioning | Configuration | Provisioning |
| **커뮤니티** | 매우 큼 | 큼 | 매우 큼 | 중간 |

---

## 🔒 모범 사례

### 1. 상태 관리

```yaml
Terraform:
  Remote State:
    - S3 + DynamoDB (잠금)
    - Terraform Cloud
    - Consul

  상태 파일 보안:
    - 암호화 (S3 KMS)
    - 접근 제어 (IAM)
    - 버전 관리 (S3 Versioning)
```

**Terraform Backend 설정**:
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

---

### 2. 시크릿 관리

```yaml
방법:
  - 환경 변수
  - AWS Secrets Manager
  - HashiCorp Vault
  - 절대 코드에 포함 금지

Terraform:
  data "aws_secretsmanager_secret_version" "db_password" {
    secret_id = "prod/db/password"
  }

Ansible:
  ansible-vault encrypt vars/secrets.yml
```

---

### 3. 모듈화 및 재사용

```yaml
Terraform Modules:
  modules/
    ├── vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ec2/
    └── rds/

환경별 분리:
  environments/
    ├── dev/
    ├── staging/
    └── production/
```

---

## 🔒 Zone별 배치

| Zone | 배치 | 구성요소 |
|------|------|----------|
| **Zone 4** | Very Common | IaC 실행 환경 (CI/CD) |

---

## ⚡ 실무 고려사항

### 1. 점진적 도입

```yaml
단계:
  1. 소규모 프로젝트 시작
  2. 템플릿/모듈 구축
  3. 팀 교육
  4. 기존 인프라 Import
  5. 전사 확대
```

---

### 2. 테스트 전략

```yaml
도구:
  - Terratest (Terraform)
  - Checkov (보안 스캔)
  - TFLint (린팅)
  - Molecule (Ansible)

CI/CD 통합:
  - PR 시 terraform plan
  - 자동 보안 스캔
  - 승인 후 terraform apply
```

---

### 3. 문서화

```yaml
필수 문서:
  - README.md (프로젝트 개요)
  - 변수 설명 (variables.tf)
  - 출력 설명 (outputs.tf)
  - 아키텍처 다이어그램
```

---

## 🔗 관련 문서

- [Layer 4 정의](../00_Layer_4_정의.md)
- [CI/CD](../01_CICD/00_CICD_정의.md)
- [GitOps](../04_GitOps/00_GitOps_정의.md)

---

**문서 끝**
