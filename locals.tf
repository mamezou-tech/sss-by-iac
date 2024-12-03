locals {
  prefix   = "mz-dev"
  app_name = "${local.prefix}-app"

  ecs_task_execution_role_name = "${local.prefix}-ecs-task-exec-role"
  ecs_execution_role_name      = "${local.prefix}-ecs-exec-role"
  ecs_cluster_name             = "${local.prefix}-ecs-cluster"
  ecs_security_group_name      = "${local.prefix}-ecs-sg"

  service_discovery_dns_namespace = "${local.prefix}-application-service.internal"
}
