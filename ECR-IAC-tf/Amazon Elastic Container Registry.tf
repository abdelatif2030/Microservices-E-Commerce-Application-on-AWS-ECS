resource "aws_ecr_repository" "microservices_repo" {
  name                 = "microservices-project"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "microservices-ecr"
    Environment = "dev"
  }
}

# ECR repository policy to allow ECS tasks to pull images
resource "aws_ecr_repository_policy" "microservices_repo_policy" {
  repository = aws_ecr_repository.microservices_repo.name

  policy = jsonencode({
    Version = "2008-10-17",
    Statement = [
      {
        Sid = "AllowECSRolePull"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::500330120032:role/ecsTaskExecutionRole"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}