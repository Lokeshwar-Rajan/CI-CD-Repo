variable "ecs_cluster_name" {

}

variable "ecs_backend_log_group_name" {

}
variable "ecs_frontend_log_group_name" {

  
}
variable "aws_region" {

}
variable "instance_type" {

}
variable "ecs_task_role_name" {}
variable "key_name" {

}

variable "instance_profile" {}
variable "ecs_instance_sg_ids" {

}

variable "private_subnet_ids" {

}

variable "asg_min_size" {

}

variable "asg_max_size" {

}

variable "asg_desired_capacity" {

}


variable "ecs_task_execution_role_arn" {

}

variable "service_desired_count" {

}

variable "frontend_tg_arn" {

}

variable "backend_tg_arn" {

}

variable "frontend_sg_id" {

}

variable "backend_sg_id" {

}
variable "lb_frontend_target_group" {

}
variable "lb_backend_target_group" {
  
}
variable "lb_listener" {

}
variable "tags" {
  type        = map(string)
  default     = {}
}

variable "ecr_registry_url" {
}
variable "ecr_repo_name" {
}

variable "db_secret_arn" {
  
}
