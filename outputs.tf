output "apigateway_endpoint" {
  value = aws_apigatewayv2_api.this.api_endpoint
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs.id
}

output "ecs_cluster_arn" {
  value = aws_ecs_cluster.this.arn
}
