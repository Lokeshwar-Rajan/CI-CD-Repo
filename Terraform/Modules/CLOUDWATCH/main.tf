
resource "aws_cloudwatch_log_group" "ecs_frontend" {
  name              = var.ecs_frontend_log_group_name
  retention_in_days = var.log_retention_in_days
  tags = {
    Environment = var.environment
    Application = var.application_name
    Owner       = var.owner
  }
}

resource "aws_cloudwatch_log_group" "ecs_backend" {
  name              = var.ecs_backend_log_group_name
  retention_in_days = var.log_retention_in_days
  tags = {
    Environment = var.environment
    Application = var.application_name
    Owner       = var.owner
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_high_cpu" {
  alarm_name          = "ecs-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = var.ecs_cpu_threshold
  alarm_description   = "This metric monitors ecs cpu utilization"
  dimensions = {
    ClusterName = var.ecs_cluster_name
  }
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions
}

resource "aws_cloudwatch_metric_alarm" "ecs_high_memory" {
  alarm_name          = "ecs-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "MemoryUtilization"
  namespace           = "ECS/ContainerInsights"
  period              = 300
  statistic           = "Average"
  threshold           = var.ecs_memory_threshold
  alarm_description   = "This metric monitors ecs memory utilization"
  dimensions = {
    ClusterName = var.ecs_cluster_name
  }
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions
}


resource "aws_cloudwatch_metric_alarm" "ec2_high_cpu" {
  alarm_name          = "ec2-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = var.ec2_cpu_threshold
  alarm_description   = "This metric monitors ec2 cpu utilization"
  dimensions = {
    AutoScalingGroupName = var.ec2_asg_name
  }
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "alb-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = var.alb_5xx_threshold
  alarm_description   = "ALB 5xx errors alarm"
  dimensions = {
    LoadBalancer = var.alb_name
  }
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions
}

resource "aws_cloudwatch_metric_alarm" "alb_high_latency" {
  alarm_name          = "alb-high-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = var.alb_latency_threshold
  alarm_description   = "ALB high latency alarm"
  dimensions = {
    LoadBalancer = var.alb_name
  }
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions
}
