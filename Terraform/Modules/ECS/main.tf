resource "aws_ecs_cluster" "myecs" {
  name = var.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.tags
}
data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "myecs_lt" {
  name_prefix   = "${var.ecs_cluster_name}-lt"
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = var.instance_profile
  }

  user_data = base64encode(<<-EOT
    #!/bin/bash
    echo "ECS_CLUSTER=myapp-cluster" >> /etc/ecs/ecs.config
    echo "ECS_AVAILABLE_LOGGING_DRIVERS=[\"awslogs\",\"json-file\"]" >> /etc/ecs/ecs.config
    systemctl enable --now ecs
  EOT
  )


  network_interfaces {
    associate_public_ip_address = false
    security_groups             = var.ecs_instance_sg_ids
  }

  block_device_mappings {
    device_name = "/dev/sda1"  
    ebs {
      volume_size           = 30 
      volume_type           = "gp2"
      delete_on_termination = true
      encrypted             = true 
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = var.tags
  }
}

resource "aws_autoscaling_group" "ecs_asg" {
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  vpc_zone_identifier = var.private_subnet_ids
  force_delete = true

  launch_template {
    id      = aws_launch_template.myecs_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.ecs_cluster_name}-ecs-instance"
    propagate_at_launch = true
  }
  default_cooldown = 300
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.ecs_cluster_name}-frontend"
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512

  network_configuration {
  subnets         = var.ecs_subnet_ids 
  security_groups = var.ecs_frontend_sg_id 
  assign_public_ip = false 
}
  container_definitions = jsonencode([
    {
      name         = "frontend"
      image        = "${var.ecr_registry_url}:frontend-latest"
      essential    = true
      portMappings = [{ containerPort = 80, protocol = "tcp" }],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.ecs_frontend_log_group_name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "frontend"
        }
      }
    }
  ])

  execution_role_arn = var.ecs_task_execution_role_arn
  task_role_arn      = var.ecs_task_role_arn
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.ecs_cluster_name}-backend"
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512

  network_configuration {
  subnets         = var.ecs_subnet_ids 
  security_groups = var.ecs_backend_sg_id 
  assign_public_ip = false 
}
  container_definitions = jsonencode([
    {
      name         = "backend"
      image        = "${var.ecr_registry_url}:backend-latest"
      essential    = true
      portMappings = [{ containerPort = 3000, protocol = "tcp" }],
      secrets = [
        {
          name      = "DB_CREDENTIALS"
          valueFrom = var.db_secret_arn
        },
      ],
      environment = [
  {
    name  = "AWS_REGION"
    value = var.aws_region
  }
]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.ecs_backend_log_group_name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "backend"
        }
      }
    }
  ])

  execution_role_arn = var.ecs_task_execution_role_arn
  task_role_arn      = var.ecs_task_role_arn
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_service" "frontend" {
  name            = "${var.ecs_cluster_name}-frontend-svc"
  cluster         = aws_ecs_cluster.myecs.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = var.service_desired_count

  load_balancer {
    target_group_arn = var.frontend_tg_arn
    container_name   = "frontend"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [task_definition]
  }

  depends_on = [
    aws_autoscaling_group.ecs_asg,
    var.lb_listener,
    var.lb_frontend_target_group
  ]
}

resource "aws_ecs_service" "backend" {
  name            = "${var.ecs_cluster_name}-backend-svc"
  cluster         = aws_ecs_cluster.myecs.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = var.service_desired_count

  load_balancer {
    target_group_arn = var.backend_tg_arn
    container_name   = "backend"
    container_port   = 3000
  }

  lifecycle {
    ignore_changes = [task_definition]
  }

  depends_on = [
    aws_autoscaling_group.ecs_asg,
    var.lb_listener,
    var.lb_backend_target_group
  ]
}
resource "aws_ecs_capacity_provider" "ecs_cp" {
  name = "${var.ecs_cluster_name}-cp"
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_asg.arn
    managed_termination_protection = "DISABLED"
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cp_assoc" {
  cluster_name       = aws_ecs_cluster.myecs.name
  capacity_providers = [aws_ecs_capacity_provider.ecs_cp.name]
  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_cp.name
    weight            = 1
  }
}
