###########################################################
# main.tf - ECS Fargate Microservices Deployment
###########################################################

# ------------------------------
# CloudWatch Log Group
# ------------------------------
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/microservices-cluster"
  retention_in_days = 14
}

# ------------------------------
# ECS Cluster
# ------------------------------
resource "aws_ecs_cluster" "microservices_cluster" {
  name = "microservices-cluster"
}

# ------------------------------
# IAM Role for ECS Tasks
# ------------------------------
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ------------------------------
# Default VPC and subnets
# ------------------------------
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ------------------------------
# Security Group
# ------------------------------
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg"
  description = "Allow HTTP/HTTPS traffic"
  vpc_id      = data.aws_vpc.default.id

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
}

# ------------------------------
# Microservices definition
# ------------------------------
variable "microservices" {
  default = {
    adservice = { port = 9555, env = [{ name = "PORT", value = "9555" }] }
    cartservice = { port = 7070, env = [
        { name = "PORT", value = "7070" },
        { name = "REDIS_ADDR", value = "redis-cart:6379" }
    ] }
    checkoutservice = { port = 5050, env = [
        { name = "PORT", value = "5050" },
        { name = "PRODUCT_CATALOG_SERVICE_ADDR", value = "productcatalogservice:3550" },
        { name = "SHIPPING_SERVICE_ADDR", value = "shippingservice:5051" },
        { name = "PAYMENT_SERVICE_ADDR", value = "paymentservice:50051" },
        { name = "EMAIL_SERVICE_ADDR", value = "emailservice:5000" },
        { name = "CURRENCY_SERVICE_ADDR", value = "currencyservice:7000" },
        { name = "CART_SERVICE_ADDR", value = "cartservice:7070" }
    ] }
    currencyservice = { port = 7000, env = [
        { name = "PORT", value = "7000" },
        { name = "DISABLE_PROFILER", value = "1" }
    ] }
    emailservice = { port = 8080, env = [] }
    frontend = { port = 8080, env = [
        { name = "PORT", value = "8080" },
        { name = "PRODUCT_CATALOG_SERVICE_ADDR", value = "productcatalogservice:3550" },
        { name = "SHIPPING_SERVICE_ADDR", value = "shippingservice:5051" },
        { name = "PAYMENT_SERVICE_ADDR", value = "paymentservice:50051" },
        { name = "EMAIL_SERVICE_ADDR", value = "emailservice:5000" },
        { name = "CURRENCY_SERVICE_ADDR", value = "currencyservice:7000" },
        { name = "CART_SERVICE_ADDR", value = "cartservice:7070" },
        { name = "RECOMMENDATION_SERVICE_ADDR", value = "recommendationservice:8080" } # ✅ Added missing env
    ] }
    mysql = { port = 3306, env = [{ name = "MYSQL_ROOT_PASSWORD", value = "rootpass" }] }
    paymentservice = { port = 50051, env = [
        { name = "PORT", value = "50051" },
        { name = "DISABLE_PROFILER", value = "1" }
    ] }
    productcatalogservice = { port = 3550, env = [{ name = "PORT", value = "3550" }] }
    recommendationservice = { port = 8080, env = [
        { name = "PORT", value = "8080" },
        { name = "PRODUCT_CATALOG_SERVICE_ADDR", value = "productcatalogservice:3550" }
    ] }
    shippingservice = { port = 5051, env = [{ name = "PORT", value = "5051" }] }
    redis_cart = { port = 6379, env = [] }
  }
}

# ------------------------------
# ECS Task Definitions
# ------------------------------
resource "aws_ecs_task_definition" "tasks" {
  for_each = var.microservices

  family                   = each.key
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = each.key
    image     = lookup({
      adservice = "500330120032.dkr.ecr.eu-north-1.amazonaws.com/microservices-project:adservice-v0.10.0"
      cartservice = "500330120032.dkr.ecr.eu-north-1.amazonaws.com/microservices-project:cartservice-v0.10.0"
      checkoutservice = "500330120032.dkr.ecr.eu-north-1.amazonaws.com/microservices-project:checkoutservice-v0.10.0"
      currencyservice = "500330120032.dkr.ecr.eu-north-1.amazonaws.com/microservices-project:currencyservice-v0.10.0"
      emailservice = "500330120032.dkr.ecr.eu-north-1.amazonaws.com/microservices-project:emailservice-v0.7.0"
      frontend = "500330120032.dkr.ecr.eu-north-1.amazonaws.com/microservices-project:frontend-v0.10.0"
      mysql = "mysql:5.7"
      paymentservice = "500330120032.dkr.ecr.eu-north-1.amazonaws.com/microservices-project:paymentservice-v0.10.0"
      productcatalogservice = "500330120032.dkr.ecr.eu-north-1.amazonaws.com/microservices-project:productcatalogservice-v0.10.0"
      recommendationservice = "500330120032.dkr.ecr.eu-north-1.amazonaws.com/microservices-project:recommendationservice-v0.8.0"
      shippingservice = "500330120032.dkr.ecr.eu-north-1.amazonaws.com/microservices-project:shippingservice-v0.10.0"
      redis_cart = "redis:alpine"
    }, each.key, "redis:alpine")
    essential = true
    portMappings = [{
      containerPort = each.value.port
      protocol      = "tcp"
    }]
    environment = each.value.env
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs_log_group.name
        "awslogs-region"        = "eu-north-1"
        "awslogs-stream-prefix" = each.key
      }
    }
  }])
}

# ------------------------------
# ECS Services
# ------------------------------
resource "aws_ecs_service" "services" {
  for_each = var.microservices

  name            = each.key
  cluster         = aws_ecs_cluster.microservices_cluster.id
  task_definition = aws_ecs_task_definition.tasks[each.key].arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.aws_subnets.default.ids
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true # ✅ Public IP to access frontend
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_policy]
}