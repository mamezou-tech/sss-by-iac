# CloudMap(Service Discovery) Service
resource "aws_service_discovery_service" "mz_dev_app" {
  name         = local.app_name
  namespace_id = aws_service_discovery_private_dns_namespace.this.id

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = 300
      type = "SRV"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

# ECS Service
resource "aws_ecs_service" "mz_dev_app" {
  name                 = local.app_name

  cluster              = aws_ecs_cluster.this.id
  task_definition      = aws_ecs_task_definition.mz_dev_app.arn
  desired_count        = var.ecs_service.desired_count
  force_new_deployment = true
  launch_type          = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.ecs.id]
  }

  service_registries {
    registry_arn   = aws_service_discovery_service.mz_dev_app.arn
    container_name = local.app_name
    container_port = 80
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
}

# API Gateway Integration
resource "aws_apigatewayv2_integration" "mz_dev_app" {
  api_id             = aws_apigatewayv2_api.this.id

  integration_type   = "HTTP_PROXY"
  integration_uri    = aws_service_discovery_service.mz_dev_app.arn
  integration_method = "ANY"

  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.this.id
}

# API Gateway Route
resource "aws_apigatewayv2_route" "mz_dev_app" {
  for_each = var.ecs_service.http_methods

  api_id             = aws_apigatewayv2_api.this.id

  route_key          = "${each.key} /{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.mz_dev_app.id}"

  authorizer_id      = aws_apigatewayv2_authorizer.jwt_authorizer.id
  authorization_type = "JWT"
}
