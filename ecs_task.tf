# ECS Task Definition
resource "aws_ecs_task_definition" "mz_dev_app" {
  family                = "${local.prefix}-site"

  container_definitions = <<EOF
[
    {
        "name": "${local.app_name}",
        "image": "public.ecr.aws/docker/library/httpd:latest",
        "portMappings": [
            {
                "containerPort": 80,
                "hostPort": 80,
                "protocol": "tcp"
            }
        ],
        "essential": true,
        "entryPoint": [
            "sh",
            "-c"
        ],
        "command": [
            "/bin/sh -c \"echo '<html> <head> <title>Amazon ECS Sample App</title> <style>body {margin-top: 40px; background-color: #333;} </style> </head><body> <div style=color:white;text-align:center> <h1>Amazon ECS Sample App</h1> <h2>Congratulations!</h2> <p>Your application is now running on a container in Amazon ECS.</p> </div></body></html>' >  /usr/local/apache2/htdocs/index.html && httpd-foreground\""
        ],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${aws_cloudwatch_log_group.mz_dev_app.name}",
                "awslogs-region": "ap-northeast-1",
                "awslogs-stream-prefix": "${local.app_name}"
            }
        }
    }
]
EOF

  execution_role_arn       = aws_iam_role.ecs_task_exec.arn
  task_role_arn            = aws_iam_role.mz_dev_app.arn

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task.cpu
  memory                   = var.ecs_task.memory
}

resource "aws_cloudwatch_log_group" "mz_dev_app" {
  name              = "/aws/ecs/fargate/${local.app_name}"
  retention_in_days = var.log_retention_in_days
}

# ECS Task Role
resource "aws_iam_role" "mz_dev_app" {
  name               = "${local.app_name}-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role_policy.json
}

resource "aws_iam_role_policy" "cloud_watch_log_policy" {
  name   = "${local.app_name}-cloud-watch-log-policy"
  role   = aws_iam_role.mz_dev_app.id
  policy = data.aws_iam_policy_document.cloud_watch_policy.json
}

resource "aws_iam_role_policies_exclusive" "mz_dev_app" {
  role_name    = aws_iam_role.mz_dev_app.name
  policy_names = [
    aws_iam_role_policy.cloud_watch_log_policy.name
  ]
}
