# api gateway
resource "aws_apigatewayv2_api" "this" {
  name          = "${local.prefix}-api-gateway"

  protocol_type = "HTTP"

  cors_configuration {
    allow_origins     = var.allow_origins
    allow_headers     = ["authorization", "origin", "content-type", "accept", "x-requested-with"]
    allow_methods     = ["GET", "POST", "PUT", "DELETE"]
    allow_credentials = true
    max_age           = var.cors_max_age
  }
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/api-gateway/mz-dev"
  retention_in_days = var.log_retention_in_days
}

resource "aws_apigatewayv2_stage" "this" {
  name        = "$default"

  api_id      = aws_apigatewayv2_api.this.id
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format          = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      path           = "$context.path"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
      errMsg         = "$context.integrationErrorMessage"
    })
  }
}

resource "aws_apigatewayv2_vpc_link" "this" {
  name               = "${local.prefix}-vpc-link"
  security_group_ids = [var.default_security_group_id]
  subnet_ids         = var.private_subnet_ids
}

# for jwt authorizer
resource "aws_apigatewayv2_authorizer" "jwt_authorizer" {
  name             = "${local.prefix}-jwt-authorizer"

  api_id           = aws_apigatewayv2_api.this.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    audience = var.user_pool_client_ids
    issuer   = "https://${var.cognito_user_pool_endpoint}"
  }
}
