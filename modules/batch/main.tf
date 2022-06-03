locals {
  service_name = "sfn-${var.sfn_name}-${var.environment}"
}
data "aws_region" "now" {}
data "aws_caller_identity" "self" {}

###########################################################################
# ECS
###########################################################################
resource "aws_ecs_cluster" "main" {
  name = local.service_name
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
    command   = var.container_command
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
resource "aws_cloudwatch_log_group" "main" {
  name = "/ecs/${local.service_name}"
}

###########################################################################
# StepFunctions
###########################################################################
resource "aws_sfn_state_machine" "main" {
  name     = local.service_name
  role_arn = aws_iam_role.sfn.arn

  definition = templatefile("${path.module}/sfn_definition/${var.environment}/${var.sfn_name}.json.tmpl", {
    cluster_arn         = aws_ecs_cluster.main.arn
    task_definition_arn = aws_ecs_task_definition.main.arn
    subnets             = var.application_subnet_ids
    security_groups     = [aws_security_group.ecs_task.id]
  })
}

###########################################################################
# EventBridge
###########################################################################
resource "aws_cloudwatch_event_rule" "main" {
  name                = var.event_name
  description         = var.event_description
  schedule_expression = var.event_schedule
}
resource "aws_cloudwatch_event_target" "main" {
  target_id = aws_sfn_state_machine.main.name
  rule      = aws_cloudwatch_event_rule.main.name
  arn       = aws_sfn_state_machine.main.arn
}

###########################################################################
# Security Group
###########################################################################
resource "aws_security_group" "ecs_task" {
  name   = "${local.service_name}-task"
  vpc_id = var.vpc_id
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

# StepFunctionsの信頼ポリシーを作成
data "aws_iam_policy_document" "sfn_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["states.${data.aws_region.now.name}.amazonaws.com", ]
    }
  }
}
# StepFunctions用IAMロールの作成
resource "aws_iam_role" "sfn" {
  name               = local.service_name
  assume_role_policy = data.aws_iam_policy_document.sfn_assume.json
}
# StepFunctions実行用IAMポリシーの作成
data "aws_iam_policy_document" "sfn_execution" {
  statement {
    effect  = "Allow"
    actions = ["events:PutTargets", "events:PutRule", "events:DescribeRule"]
    resources = [
      "arn:aws:events:${data.aws_region.now.name}:${data.aws_caller_identity.self.account_id}:rule/StepFunctionsGetEventsForECSTaskRule"
    ]
  }
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole", "iam:GetRole"]
    resources = ["${aws_iam_role.ecs_task_execution.arn}", "${aws_iam_role.ecs_task.arn}"]
  }
  statement {
    effect    = "Allow"
    actions   = ["ecs:RunTask"]
    resources = [aws_ecs_task_definition.main.arn]
  }
  statement {
    effect    = "Allow"
    actions   = ["ecs:StopTask", "ecs:DescribeTasks"]
    resources = ["*"]
    condition {
      test     = "ArnEquals"
      variable = "ecs:cluster"
      values   = [aws_ecs_cluster.main.arn]
    }
  }
}
# StepFunctions実行用IAMポリシーをStepFunctions用IAMロールにアタッチ
resource "aws_iam_role_policy" "sfn_execution_policy" {
  name   = local.service_name
  role   = aws_iam_role.sfn.id
  policy = data.aws_iam_policy_document.sfn_execution.json
}