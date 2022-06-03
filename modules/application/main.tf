locals {
  dns_split    = split(".", var.domain_name)
  record_name  = local.dns_split[0]
  service_name = "${var.container_name}-${var.environment}"
}
data "aws_region" "now" {}

###########################################################################
# Route 53
###########################################################################
resource "aws_route53_record" "main" {
  type    = "A"
  name    = local.record_name
  zone_id = var.hosted_zone_id
  alias {
    evaluate_target_health = false
    name                   = var.cf_domain_name
    zone_id                = var.cf_hosted_zone_id
  }
}

###########################################################################
# ALB
###########################################################################
resource "aws_lb" "main" {
  name                       = local.service_name
  load_balancer_type         = "application"
  subnets                    = var.public_subnet_ids
  security_groups            = [aws_security_group.alb.id]
  internal                   = false
  enable_deletion_protection = false
}
resource "aws_lb_listener" "http" {
  protocol = "HTTP"
  port     = "80"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  load_balancer_arn = aws_lb.main.arn
  tags = {
    Name = local.service_name
  }
}
resource "aws_lb_listener" "https" {
  protocol   = "HTTPS"
  port       = "443"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
  load_balancer_arn = aws_lb.main.arn
  certificate_arn   = var.lb_certificate_arn
  tags = {
    Name = local.service_name
  }
}
resource "aws_lb_target_group" "main" {
  name                 = local.service_name
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  port                 = var.container_port
  deregistration_delay = var.lb_deregistration_delay
  health_check {
    port                = var.container_port
    matcher             = var.lb_health_check_matcher
    healthy_threshold   = var.lb_health_check_healthy_threshold
    unhealthy_threshold = var.lb_health_check_unhealthy_threshold
    interval            = var.lb_health_check_interval
    timeout             = var.lb_health_check_timeout
    path                = var.lb_health_check_path
  }
  lifecycle {
    create_before_destroy = true
  }
}

###########################################################################
# ECS
###########################################################################
resource "aws_ecs_cluster" "main" {
  name = local.service_name
  depends_on = [
    aws_lb.main
  ]
}
resource "aws_ecs_task_definition" "main" {
  family                   = local.service_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.ecs_task.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  container_definitions = jsonencode([{
    name      = var.container_name
    image     = var.container_image_uri
    cpu       = var.container_cpu
    memory    = var.container_memory
    essential = true
    portMappings = [
      {
        containerPort = var.container_port
        hostPort      = var.container_port
      }
    ]
    secrets = [
      {
        "name" : "DB_HOST"
        "valueFrom" : "${var.rds_secrets_arn}:host::"
      },
      {
        "name" : "DB_PORT"
        "valueFrom" : "${var.rds_secrets_arn}:port::"
      },
      {
        "name" : "DB_NAME"
        "valueFrom" : "${var.rds_secrets_arn}:dbname::"
      },
      {
        "name" : "DB_USERNAME"
        "valueFrom" : "${var.rds_secrets_arn}:username::"
      },
      {
        "name" : "DB_PASSWORD"
        "valueFrom" : "${var.rds_secrets_arn}:password::"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-stream-prefix : "ecs"
        awslogs-region : data.aws_region.now.name
        awslogs-group : aws_cloudwatch_log_group.main.name
      }
    }
  }])
}
resource "aws_ecs_service" "main" {
  launch_type                       = "FARGATE"
  name                              = local.service_name
  cluster                           = aws_ecs_cluster.main.id
  task_definition                   = aws_ecs_task_definition.main.arn
  desired_count                     = length(var.availability_zones)
  depends_on                        = [aws_lb_listener.http, aws_lb_listener.https]
  health_check_grace_period_seconds = 300
  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
  network_configuration {
    assign_public_ip = false
    subnets          = var.application_subnet_ids
    security_groups  = [aws_security_group.ecs_service.id]
  }
  lifecycle {
    ignore_changes = [desired_count, task_definition, load_balancer]
  }
}
resource "aws_cloudwatch_log_group" "main" {
  name = "/ecs/${local.service_name}"
}

###########################################################################
# Security Group
###########################################################################
resource "aws_security_group" "alb" {
  name        = "${local.service_name}-alb"
  description = "Attached to ${local.service_name}-alb"
  vpc_id      = var.vpc_id
  ingress {
    description     = "Only HTTPS from CloudFront"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
data "aws_ec2_managed_prefix_list" "cloudfront" {
  filter {
    name   = "prefix-list-name"
    values = ["com.amazonaws.global.cloudfront.origin-facing"]
  }
}
resource "aws_security_group" "ecs_service" {
  name        = "${local.service_name}-service"
  description = "Attached to ${local.service_name}-service"
  vpc_id      = var.vpc_id
  ingress {
    description = "Ingress container port"
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    security_groups = [
      aws_security_group.alb.id
    ]
  }
  ingress {
    description = "HTTP from all"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [
      aws_security_group.alb.id
    ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

###########################################################################
# IAM
###########################################################################

# ecs-tasksの信頼ポリシーを作成
data "aws_iam_policy_document" "ecs_tasks_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECSタスク実行用IAMロールを作成
resource "aws_iam_role" "ecs_task_execution" {
  name               = "${local.service_name}-task-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
}
# ECSタスクを実行するためのAWS管理ポリシーをECSタスク実行用IAMロールにアタッチ
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
# 特定のSecrets ManagerへのGet権限ポリシーを作成
resource "aws_iam_policy" "get_secrets" {
  name        = "${local.service_name}-get-secrets"
  path        = "/"
  description = "GetSecretValue attached to TaskExecutionRole"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
        ]
        Effect   = "Allow"
        Resource = var.rds_secrets_arn
      },
    ]
  })
}
# 特定のSecrets ManagerへのGet権限ポリシーをECSタスク実行用IAMロールにアタッチ
resource "aws_iam_role_policy_attachment" "get_secrets" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.get_secrets.arn
}

# ECSタスク用のIAMロールを作成
resource "aws_iam_role" "ecs_task" {
  name               = "${local.service_name}-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
}
# TODO
resource "aws_iam_policy" "ecs_task" {
  name        = "${local.service_name}-ecs-task"
  path        = "/"
  description = "ECS Task Role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
# ダミーポリシーをECSタスク用のIAMロールにアタッチ
resource "aws_iam_role_policy_attachment" "ecs_task" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task.arn
}
