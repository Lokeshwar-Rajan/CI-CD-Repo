
resource "aws_lb" "us-lb" {
  name               = var.alb_name
  internal           = "false"
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = [var.alb_sg_id]
  enable_deletion_protection = false
  tags = { 
    Name = var.alb_name }
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.us-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}


# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.us-lb.arn
#   port              = 443
#   protocol          = "HTTPS"
#   certificate_arn   = var.certificate_arn

#     default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.frontend.arn
#   }
# }


resource "aws_lb_target_group" "frontend" {
  name        = "${var.alb_name}-frontend"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  # health_check {
  #   path                = var.frontend_health_check_path
  #   matcher             = var.frontend_health_check_matcher
  #   interval            = var.health_check_interval
  #   timeout             = var.health_check_timeout
  #   healthy_threshold   = var.healthy_threshold
  #   unhealthy_threshold = var.unhealthy_threshold
  # }

  tags = { Name = "${var.alb_name}-frontend" }
}


resource "aws_lb_target_group" "backend" {
  name        = "${var.alb_name}-backend"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  # health_check {
  #   path                = var.backend_health_check_path
  #   matcher             = var.backend_health_check_matcher
  #   interval            = var.health_check_interval
  #   timeout             = var.health_check_timeout
  #   healthy_threshold   = var.healthy_threshold
  #   unhealthy_threshold = var.unhealthy_threshold
  # }

  tags = { Name = "${var.alb_name}-backend" }
}


resource "aws_lb_listener_rule" "frontend_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
    action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
  
}


resource "aws_lb_listener_rule" "backend_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20
  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}
