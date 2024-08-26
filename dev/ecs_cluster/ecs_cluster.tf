# ECS cluster 생성
resource "aws_ecs_cluster" "wordpress" {
  name = var.ecs_name
}

# EC2 instance용 IAM Role
data "aws_iam_policy_document" "ecs_node_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_node_role" {
  name                = "ecs-node-role-93"
  assume_role_policy  = data.aws_iam_policy_document.ecs_node_doc.json
}

resource "aws_iam_role_policy_attachment" "ecs_node_role_policy" {
  role       = aws_iam_role.ecs_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_node" {
  name        = "ecs-node-profile-93"
  path        = "/ecs/instance/"
  role        = aws_iam_role.ecs_node_role.name
}

# 시작템플릿
resource "aws_launch_template" "ecs_ec2" {
  image_id                = var.ami_id
  instance_type           = var.instance_type
  vpc_security_group_ids  = [ var.security_group_id ]
  iam_instance_profile { arn = aws_iam_instance_profile.ecs_node.arn }

  user_data = base64encode(<<-EOF
      #!/bin/bash
      echo ECS_CLUSTER=${var.ecs_name} >> /etc/ecs/ecs.config;
    EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = var.ec2_name
    }
  }
}

# Autoscaling group
resource "aws_autoscaling_group" "ecs" {
  name                      = "ecs-asg-93"
  vpc_zone_identifier       = [ var.prvsub_nat_a_id, var.prvsub_nat_c_id ]
  min_size                  = 2
  max_size                  = 10
  health_check_grace_period = 0
  health_check_type         = "ELB"
  protect_from_scale_in     = false

  launch_template {
    id      = aws_launch_template.ecs_ec2.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = var.ec2_name
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
}

# ECS Capacity Provider
resource "aws_ecs_capacity_provider" "main" {
  name = "demo-ecs-ec2"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 5
      minimum_scaling_step_size = 2
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = var.ecs_name
  capacity_providers = [aws_ecs_capacity_provider.main.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    base              = 1
    weight            = 100
  }
}

# ECS task
data "aws_iam_policy_document" "ecs_task_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name                = "su-ecs-task-role"
  assume_role_policy  = data.aws_iam_policy_document.ecs_task_doc.json
}

resource "aws_iam_role" "ecs_exec_role" {
  name                = "su-ecs-exec-role"
  assume_role_policy  = data.aws_iam_policy_document.ecs_task_doc.json
}

resource "aws_iam_role_policy_attachment" "ecs_exec_role_policy" {
  role       = aws_iam_role.ecs_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "app" {
  family             = "task-su"
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_exec_role.arn
  network_mode       = "bridge"
  cpu                = 2048
  memory             = 3072

  container_definitions = jsonencode([{
    name         = "wordpress",
    image        = "${var.repository_url}:latest",
    essential    = true,
    portMappings = [{ containerPort = 80, hostPort = 80 }],
  }])
}

# ECS service 추가
resource "aws_ecs_service" "app" {
  name            = "app"
  cluster         = aws_ecs_cluster.wordpress.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    base              = 1
    weight            = 100
  }

  deployment_controller {
    type = "ECS"
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
  
  depends_on = [aws_lb_target_group.app]

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "wordpress"
    container_port   = 80
  }
}

# 로드벨런서 생성
resource "aws_lb" "main" {
  name               = "ALB-su"
  load_balancer_type = "application"
  subnets            = [ var.public_subnet_a_id, var.public_subnet_c_id ]
  security_groups    = [var.security_group_alb_id]
}

resource "aws_lb_target_group" "app" {
  name        = "TG-su"
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  port        = 80
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/"
    port                = 80
    matcher             = "200,301,302"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.id
  }
}