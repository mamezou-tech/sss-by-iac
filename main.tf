# ECS Cluster
resource "aws_ecs_cluster" "this" {
  name = local.ecs_cluster_name
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = ["FARGATE"]
}

# Security Group of ECS
resource "aws_security_group" "ecs" {
  name   = local.ecs_security_group_name
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "${local.prefix}-ecs-security-group"
  }
}

# CloudMap(Service Discovery)
resource "aws_service_discovery_private_dns_namespace" "this" {
  name = local.service_discovery_dns_namespace
  vpc  = var.vpc_id
}

// TODO cloudwatch
# resource "aws_directory_service_log_subscription" "this" {

# }

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_exec" {
  name               = local.ecs_task_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec" {
  role       = aws_iam_role.ecs_task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cloud_watch_policy" {
  statement {
    actions   = ["cloudwatch:PutMetricData"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ecs_task_exec_cloud_watch_policy" {
    name   = "${local.prefix}-cloud-watch-policy"
    role   = aws_iam_role.ecs_task_exec.id
    policy = data.aws_iam_policy_document.cloud_watch_policy.json

}

resource "aws_iam_role_policies_exclusive" "ecs_task_exec" {
  role_name    = aws_iam_role.ecs_task_exec.name
  policy_names = [
    aws_iam_role_policy.ecs_task_exec_cloud_watch_policy.name,
  ]
}
