# API Gateway
variable "vpc_id" {
  type = string
}

variable "default_security_group_id" {
  type = string
}

variable "allow_origins" {
  type = list(string)
}

variable "cors_max_age" {
  type = number
  default = 80000
}

variable "log_retention_in_days" {
  type    = number
  default = 7
}

variable "cognito_user_pool_endpoint" {
  type = string
}

variable "user_pool_client_ids" {
  type = list(string)
}

# ECS Task
variable "ecs_task" {
  type = object({
    memory = optional(number, 512)
    cpu    = optional(number, 256)
  })
}

# ECS Service
variable "ecs_service" {
  type = object({
    desired_count = optional(number, 1)
    http_methods  = optional(set(string), ["GET"])
  })
}

variable "private_subnet_ids" {
  type = list(string)
}
