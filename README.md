# Microservices E-Commerce Application on AWS ECS


This project demonstrates deploying a **cloud-native microservices application on AWS** using **Amazon ECS (Elastic Container Service)** and **Amazon ECR (Elastic Container Registry)**.

The application is based on the **Online Boutique microservices demo**, a distributed e-commerce platform composed of multiple independent services communicating with each other.

Each microservice runs inside its own **Docker container**, stored in **Amazon ECR**, and deployed as a service inside an **Amazon ECS Cluster**.

---

# Architecture Overview

The system follows a **microservices architecture** where each service is deployed as a containerized ECS service.

```
User
 │
 │
 ▼
Frontend Service (ECS)
 │
 ├── ProductCatalogService
 ├── RecommendationService
 ├── CartService
 │       └── Redis
 ├── CheckoutService
 │       ├── PaymentService
 │       ├── ShippingService
 │       ├── EmailService
 │       └── CurrencyService
 └── AdService
```

All services communicate internally within the **ECS cluster network**.

---

# AWS Services Used

| Service        | Purpose                  |
| -------------- | ------------------------ |
| Amazon ECS     | Container orchestration  |
| Amazon ECR     | Container image registry |
| Docker         | Containerization         |
| AWS CloudWatch | Logging and monitoring   |
| AWS Networking | Service communication    |

---

# Microservices in the Application

| Service               | Description                     | Port  |
| --------------------- | ------------------------------- | ----- |
| frontend              | Web UI for the store            | 8080  |
| productcatalogservice | Provides product catalog        | 3550  |
| recommendationservice | Recommends related products     | 8080  |
| cartservice           | Manages shopping cart           | 7070  |
| redis-cart            | Redis database for cart         | 6379  |
| checkoutservice       | Handles order checkout          | 5050  |
| paymentservice        | Simulates payment processing    | 50051 |
| shippingservice       | Calculates shipping cost        | 5051  |
| emailservice          | Sends order confirmation emails | 5000  |
| currencyservice       | Currency conversion             | 7000  |
| adservice             | Provides advertisements         | 9555  |

---

# Container Image Workflow

The deployment follows a standard container workflow:

```
Build Docker Images
        │
        ▼
Push Images to Amazon ECR
        │
        ▼
Create ECS Task Definitions
        │
        ▼
Deploy ECS Services
        │
        ▼
Run Containers inside ECS Cluster
```

---

# Example ECR Image

Each service image is pushed to Amazon ECR.

Example:

```
<account-id>.dkr.ecr.<region>.amazonaws.com/microservices-project:frontend-v0.10.0
```

---

# Deployment Steps

### 1. Build Docker Images

```
docker build -t frontend .
docker build -t productcatalogservice .
docker build -t checkoutservice .
```

---

### 2. Authenticate Docker to ECR

```
aws ecr get-login-password --region <region> \
| docker login \
--username AWS \
--password-stdin <account-id>.dkr.ecr.<region>.amazonaws.com
```

---

### 3. Tag Docker Images

```
docker tag frontend:latest \
<account-id>.dkr.ecr.<region>.amazonaws.com/microservices-project:frontend-v0.10.0
```

---

### 4. Push Images to ECR

```
docker push <account-id>.dkr.ecr.<region>.amazonaws.com/microservices-project:frontend-v0.10.0
```

---

### 5. Deploy on ECS

Create:

* ECS Cluster
* Task Definitions
* ECS Services

Each microservice runs as an **independent ECS service**.

---

# Verification

List ECS services:

```
aws ecs list-services --cluster <cluster-name>
```

List running tasks:

```
aws ecs list-tasks --cluster <cluster-name>
```

Check logs using CloudWatch.

---

# Technologies Used

* Docker
* Amazon ECS
* Amazon ECR
* AWS CloudWatch
* Microservices Architecture

---


Through this project I gained hands-on experience with:

* Deploying microservices on AWS ECS
* Managing container images using Amazon ECR
* Running distributed applications in containers
* Service-to-service communication
* Cloud-based microservices architecture

---




**Abdo Mohamed**

DevOps / Cloud Engineer

---

