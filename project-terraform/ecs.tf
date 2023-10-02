resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.ecs_cluster_name

  tags = merge(var.tags, {
    Name = "MyECSCluster"
  })
}

# ECS task definition for the API
resource "aws_ecs_task_definition" "task" {
  family = var.ecs_task_family

  network_mode             = var.ecs_network_mode
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_cpu
  memory                   = var.ecs_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = var.frontend_container_name,
      image = "${data.aws_ecr_repository.existing_repo.repository_url}:carbonapp",

      portMappings = [
        {
          containerPort = var.custom_port_1,
         
        },
      ],
      essential = true,
    }
  ])

  tags = merge(var.tags, {
    Name = "MyECSTaskDefinition"
  })
}

# ECS service for the API
resource "aws_ecs_service" "api_service" {
  name          = var.ecs_service_name
  cluster       = aws_ecs_cluster.ecs_cluster.id
  desired_count = 1

  # Use the latest ACTIVE revision of the task definition
  task_definition      = aws_ecs_task_definition.task.arn
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA" # Use "DAEMON" for daemon scheduling
  force_new_deployment = true

  network_configuration {
    assign_public_ip = false
    subnets          = [aws_subnet.private_subnet.id]
    security_groups = [
      aws_security_group.ecs_sg.id,
      aws_security_group.rds_sg.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_tg.arn
    container_name   = var.frontend_container_name
    container_port   = var.custom_port_1
  }

  tags = merge(var.tags, {
    Name = "MyAppAutoScalingPolicy"
  })
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.api_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  tags = merge(var.tags, {
    Name = "MyAppAutoScalingTarget"
  })
}

resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      scaling_adjustment          = 1
      metric_interval_lower_bound = 0
    }

    step_adjustment {
      scaling_adjustment          = -1
      metric_interval_upper_bound = 0
    }
  }
}

# resource "aws_ecr_repository" "ecr_repo" {
#   name = var.ecr_repo_name
# }