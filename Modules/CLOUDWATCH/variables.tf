variable "environment" {

}

variable "application_name" {

}

variable "owner" {

}
variable "ok_actions" {
  type = list(string)
}
variable "alarm_actions" {
  type = list(string)
}
variable "ecs_frontend_log_group_name" {

}

variable "ecs_backend_log_group_name" {

}

variable "log_retention_in_days" {

}


variable "ecs_cluster_name" {

}

variable "ecs_cpu_threshold" {

}

variable "ecs_memory_threshold" {

}

variable "ec2_asg_name" {

}

variable "ec2_cpu_threshold" {

}

variable "alb_name" {

}

variable "alb_5xx_threshold" {

}

variable "alb_latency_threshold" {

}

