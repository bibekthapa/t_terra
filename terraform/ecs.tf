resource "aws_security_group" "consumer_sg" {
  name        = "consumer-sg"
  description = "Allow outbound traffic to DB"
  vpc_id      = data.aws_vpc.default.id

ingress {
  from_port   = 8082
  to_port     = 8082
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  # open to the world for testing
}

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "consumer_log_group" {
  name              = "/ecs/consumer"
  retention_in_days = 1   # optional, set how long logs are kept
}



resource "aws_ecs_task_definition" "consumer_task" {
  family                   = "consumer-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "consumer"
    image     = "${aws_ecr_repository.consumer_repo.repository_url}:${var.consumer_image_tag}"
    essential = true
    environment = [
        
      { name = "DB_HOST", value = var.consumer_db_host },
      { name = "DB_PORT", value = tostring(var.consumer_db_port) },
      { name = "DB_USER", value = var.consumer_db_user },
      { name = "DB_PASSWORD", value = var.consumer_db_password }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/consumer"
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}
resource "aws_ecs_service" "consumer_service" {
  name            = "consumer-service"
  cluster         = aws_ecs_cluster.consumer_cluster.id
  task_definition = aws_ecs_task_definition.consumer_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.aws_subnets.default.ids
    security_groups = [aws_security_group.consumer_sg.id]
    assign_public_ip = true
  }
}
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
