# Pulling in existing network data
data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_subnet" "private-1" {
  id = var.private1
}

data "aws_subnet" "private-2" {
  id = var.private2
}

data "aws_subnet" "public-1" {
  id = var.public1
}

data "aws_subnet" "public-2" {
  id = var.public2
}

resource "aws_ecs_cluster" "main" {
  name = "${local.prefix}-cluster"

  tags = local.common_tags
}

resource "aws_iam_policy" "task_execution_role_policy" {
  name        = "${local.prefix}-task-exec-role-policy"
  path        = "/"
  description = "Allow retrieving images and adding to logs"
  policy      = file("./templates/ecs/task-exec-role.json")
}

resource "aws_iam_role" "task_execution_role" {
  name               = "${local.prefix}-task-exec-role"
  assume_role_policy = file("./templates/ecs/assume-role-policy.json")
}

resource "aws_iam_role_policy_attachment" "task_execution_role" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.task_execution_role_policy.arn
}

resource "aws_iam_role" "app_iam_role" {
  name               = "${local.prefix}-api-task"
  assume_role_policy = file("./templates/ecs/assume-role-policy.json")

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "ecs_task_logs" {
  name = "${local.prefix}-api"

  tags = local.common_tags
}

data "template_file" "api_container_definitions" {
  template = file("templates/ecs/container-definitions.json.tpl")

  vars = {
    app_image         = var.ecr_image_api
    proxy_image       = var.ecr_image_proxy
    django_secret_key = var.django_secret_key
    db_host           = aws_db_instance.main.address
    db_name           = aws_db_instance.main.name
    db_user           = aws_db_instance.main.username
    db_pass           = aws_db_instance.main.password
    zoom_api_id       = var.zoom_api_id
    zoom_api_key      = var.zoom_api_key
    app_aws_id        = var.app_aws_id
    app_aws_key       = var.app_aws_key
    log_group_name    = aws_cloudwatch_log_group.ecs_task_logs.name
    log_group_region  = data.aws_region.current.name
    allowed_hosts     = "*"
  }
}

resource "aws_ecs_task_definition" "api" {
  family                   = "${local.prefix}-api"
  container_definitions    = data.template_file.api_container_definitions.rendered
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.app_iam_role.arn
  volume {
    name = "static"
  }

  tags = local.common_tags
}

resource "aws_security_group" "ecs_service" {
  description = "Access for the ECS service"
  name        = "${local.prefix}-ecs-service"
  vpc_id      = data.aws_vpc.main.id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [
      data.aws_subnet.private-1.cidr_block,
      data.aws_subnet.private-2.cidr_block,
    ]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_ecs_service" "api" {
  name            = "${local.prefix}-api"
  cluster         = aws_ecs_cluster.main.name
  task_definition = aws_ecs_task_definition.api.family
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets = [
      data.aws_subnet.public-1.id,
      data.aws_subnet.public-2.id,
    ]
    security_groups  = [aws_security_group.ecs_service.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.backend_api_alb.id
    container_name   = "api"
    container_port   = 8000
  }
 
  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

## Autoscaling configuration to scale ECS service based on memory and CPU utilization
resource "aws_appautoscaling_target" "api" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "api_ecs_policy_memory" {
  name               = "api-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.api.resource_id
  scalable_dimension = aws_appautoscaling_target.api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.api.service_namespace
 
  target_tracking_scaling_policy_configuration {
   predefined_metric_specification {
     predefined_metric_type = "ECSServiceAverageMemoryUtilization"
   }
   target_value       = 80
  }
}
 
resource "aws_appautoscaling_policy" "api_ecs_policy_cpu" {
  name               = "api-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.api.resource_id
  scalable_dimension = aws_appautoscaling_target.api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.api.service_namespace
 
  target_tracking_scaling_policy_configuration {
   predefined_metric_specification {
     predefined_metric_type = "ECSServiceAverageCPUUtilization"
   }
   target_value       = 70
  }
}
