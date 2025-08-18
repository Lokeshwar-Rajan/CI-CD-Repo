variable "primary_vpc_cidr" {}
variable "primary_vpc_name" {}
variable "primary_azs" {}
variable "primary_public_subnet_cidrs" {}
variable "primary_private_subnet_cidrs" {}
variable "primary_db_subnet_cidrs" {}
variable "nat_gw_subnet_indexes" {}

variable "sec_vpc_cidr" {
  
}
variable "sec_vpc_name" {
  
}
variable "sec_azs" {

}
variable "sec_public_subnet_cidrs" {

}
variable "sec_private_subnet_cidrs" {

}
variable "sec_db_subnet_cidrs" {

}


variable "bastionus_ami_id" {}
variable "bastioneu_ami_id" {}
variable "bastion_instance_type" {}
variable "root_volume_size" {}
variable "key_pair_name" {}
variable "project_name" {}
variable "environment" {}
variable "application" {}
variable "owner" {}


variable "db_allocated_storage" {}
variable "db_engine" {}
variable "db_engine_version" {}
variable "db_instance_class" {}
variable "db_identifier" {}
variable "db_name" {}
variable "parameter_group_name" {}
variable "db_username" {}
variable "secret_name" {}
variable "description" {}


variable "alb_name" {}
variable "certificate_arn" {}
variable "frontend_health_check_path" {}
 variable "frontend_health_check_matcher" {}
 variable "backend_health_check_path" {}
 variable "backend_health_check_matcher" {}
 variable "health_check_interval" {}
 variable "health_check_timeout" {}
 variable "healthy_threshold" {}
 variable "unhealthy_threshold" {}


variable "ecs_cluster_name" {}
variable "instance_type" {}
variable "key_name" {}
variable "asg_min_size" {}
variable "asg_max_size" {}
variable "asg_desired_capacity" {}
variable "service_desired_count" {}
variable "tags" {}
variable "application_name" {}
variable "additional_tags" {}
variable "aws_region_us" {}
variable "aws_region_eu" {}

variable "ecs_frontend_log_group_name" {}
variable "ecs_backend_log_group_name"  {}
variable "log_retention_in_days"       {}
variable "ecs_cpu_threshold"    {}
variable "ecs_memory_threshold" {}
variable "ec2_asg_name"     {}
variable "ec2_cpu_threshold" {}
variable "alb_5xx_threshold"     {}
variable "alb_latency_threshold" {}

variable "alert_email" {}
variable "sns_topic_name" {}

variable "db_port" {}

variable "rds_role_name" {
  
}
variable "rds_trusted_services" {
  
}
variable "rds_policy_arns" {
  
}
variable "ecs_role_name" {}
variable "ecs_trusted_services" {
  
}
variable "ecs_policy_arns" {
  
}
variable "ecs_instance_role_name" {}
variable "ecs_instance_trusted_services" {}
variable "ecs_instance_policy_arns" {}
variable "ecs_task_role_name" {
  default = "my-ecs-task-role"
}

variable "ecs_task_trusted_services" {
  default = ["ecs-tasks.amazonaws.com"]
}
variable "ecs_task_policy_arns" {}
variable "recovery_window_in_days" {
  
}
variable "monitoring_interval" {
  
}
variable "bastion_sg_name" {
  
}

variable "alb_sg_name" {
  
}

variable "ecs_frontend_sg_name" {
  
}

variable "ecs_backend_sg_name" {
  
}
variable "db_sg_name" {
  
}
