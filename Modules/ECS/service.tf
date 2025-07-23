resource "aws_ecs_service" "apache" {
  name            = "apache-service"
  cluster         = aws_ecs_cluster.ECS_Amrize.id
  task_definition = aws_ecs_task_definition.apache.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_targets.arn
    container_name   = "apache"
    container_port   = 80
  }

  depends_on = [aws_lb_target_group.ecs_targets]
}

# Target Group for ALB
resource "aws_lb_target_group" "ecs_targets" {
  name        = "${var.ECS_Name}-targets"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.ECS_Name}-target-group"
  }
}