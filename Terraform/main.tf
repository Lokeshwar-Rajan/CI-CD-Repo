module "vpc_primary" {
  source                  = "./Modules/VPC"
  vpc_cidr                = var.primary_vpc_cidr
  vpc_name                = var.primary_vpc_name
  azs                     = var.primary_azs
  public_subnet_cidrs     = var.primary_public_subnet_cidrs
  private_subnet_cidrs    = var.primary_private_subnet_cidrs
  db_subnet_cidrs         = var.primary_db_subnet_cidrs
  nat_gw_subnet_indexes   = var.nat_gw_subnet_indexes
}


module "Bastion_SG" {
  source = "./Modules/Security_Groups"
  vpc_id = module.vpc_primary.vpc_id
  sg_name = var.bastion_sg_name
  sg_description = "Allow SSH"
  ingress_rules = [
    {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["49.207.186.65/32"]
  }
  ]
    
}
module "alb_sg" {
  source = "./Modules/Security_Groups"
  vpc_id = module.vpc_primary.vpc_id
  sg_name = var.alb_sg_name
  sg_description = "Allow HTTP and HTTPS Request"
  ingress_rules = [
    {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ]
}
module "ecs_frontend_sg" {
  source = "./Modules/Security_Groups"
  vpc_id = module.vpc_primary.vpc_id
  sg_name = var.ecs_frontend_sg_name
  sg_description = "Allow HTTP and HTTPS Request"
  ingress_rules = [
    {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/24", "10.1.1.0/24"]
  },
  {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/24", "10.1.1.0/24"]
  },
  {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["49.207.186.65/32"]
  }
  ]
}
module "ecs_backend_sg" {
  source = "./Modules/Security_Groups"
  vpc_id = module.vpc_primary.vpc_id
  sg_name = var.ecs_backend_sg_name
  sg_description = "Allow HTTP and HTTPS Request"
  ingress_rules = [
    {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/24", "10.1.1.0/24"]
  },
  {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/24", "10.1.1.0/24"]
  },
  {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["49.207.186.65/32"]
  },
  {
    description = "Allow"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/24", "10.1.1.0/24"]
  }
  ]
}

module "db_sg" {
  source = "./Modules/Security_Groups"
  vpc_id = module.vpc_primary.vpc_id
  sg_name = var.db_sg_name
  sg_description = "Allow Backend ECS to DB"
  ingress_rules = [
    {
    description = "Allow Postgres Req"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.1.2.0/24", "10.1.3.0/24"]
  }
  ]
}
module "alb" {
  source = "./Modules/ALB"
  alb_name                         = var.alb_name
  subnet_ids                       = module.vpc_primary.public_subnet_ids
  vpc_id                           = module.vpc_primary.vpc_id
  alb_sg_id                        = module.alb_sg.security_group_id
  certificate_arn                  = var.certificate_arn
  # frontend_health_check_path     = var.frontend_health_check_path
  # frontend_health_check_matcher  = var.frontend_health_check_matcher
  # backend_health_check_path      = var.backend_health_check_path
  # backend_health_check_matcher   = var.backend_health_check_matcher
  # health_check_interval          = var.health_check_interval
  # health_check_timeout           = var.health_check_timeout
  # healthy_threshold              = var.healthy_threshold
  # unhealthy_threshold            = var.unhealthy_threshold

  tags = var.tags
}


module "bastion" {
  source             = "./modules/Bastion"
  ami_id             = var.bastion_ami_id           
  instance_type      = var.bastion_instance_type
  subnet_id          = module.vpc_primary.public_subnet_ids[0]
  security_group_ids = [module.Bastion_SG.security_group_id]
  root_volume_size   = var.root_volume_size
  key_pair_name      = var.key_pair_name
  
  project_name       = var.project_name
  environment        = var.environment
  owner              = var.owner

  
}

module "ecs" {
  source = "./Modules/ECS"
  ecs_cluster_name            = var.ecs_cluster_name
  instance_type               = var.instance_type
  key_name                    = var.key_name
  private_subnet_ids          = module.vpc_primary.private_subnet_ids
  ecs_instance_sg_ids         = [module.ecs_frontend_sg.security_group_id, module.ecs_backend_sg.security_group_id]
  asg_min_size                = var.asg_min_size
  asg_max_size                = var.asg_max_size
  asg_desired_capacity        = var.asg_desired_capacity
  frontend_sg_id              = module.ecs_frontend_sg.security_group_id
  backend_sg_id               = module.ecs_backend_sg.security_group_id
  ecs_frontend_log_group_name = module.cloudwatch_monitoring.ecs_frontend_log_group_name
  ecs_backend_log_group_name  = module.cloudwatch_monitoring.ecs_backend_log_group_name
  aws_region                  = var.aws_region
  ecs_task_execution_role_arn = module.ecs_task_execution_role.role_arn
  service_desired_count       = var.service_desired_count
  frontend_tg_arn             = module.alb.frontend_target_group_arn
  backend_tg_arn              = module.alb.backend_target_group_arn
  ecr_registry_url            = module.ecr.repository_url
  ecr_repo_name               = module.ecr.ecr_repo_name
  db_secret_arn               = module.rds_db_secret.secret_arn
  lb_listener                  = module.alb.lb_listener_arn
  lb_frontend_target_group     = module.alb.frontend_target_group_arn
  lb_backend_target_group      = module.alb.backend_target_group_arn
  tags                        = var.tags
}
module "rds_db_secret" {
  source                  = "./Modules/SecretsManager"
  secret_name             = var.secret_name
  description             = var.description
  recovery_window_in_days = 7
  db_username             = var.db_username
  db_endpoint             = module.database.db_endpoint
  db_name                 = var.db_name
}

module "database" {
  source = "./Modules/RDS" 
  allocated_storage      = var.db_allocated_storage
  engine                 = var.db_engine
  subnet_ids             = module.vpc_primary.db_subnet_ids
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  monitoring_interval    = var.monitoring_interval
  monitoring_role_arn    = module.rds_role.role_arn
  db_identifier          = var.db_identifier
  parameter_group_name   = var.parameter_group_name
  db_name                = var.db_name
  db_username            = var.db_username
  db_password            = module.rds_db_secret.random_password
  security_group_ids     = [module.db_sg.security_group_id]
}


module "ecr" {
  source           = "./Modules/ECR"
  scan_on_push     = true
}


module "cloudwatch_monitoring" {
  source                      = "./Modules/CLOUDWATCH"
  environment                 = var.environment
  application_name            = var.application_name
  owner                       = var.owner
  ecs_frontend_log_group_name = var.ecs_frontend_log_group_name
  ecs_backend_log_group_name  = var.ecs_backend_log_group_name
  log_retention_in_days       = var.log_retention_in_days
  ok_actions                  = [module.aws_sns_topic.sns_topic_arn]
  alarm_actions               = [module.aws_sns_topic.sns_topic_arn]
  ecs_cluster_name            = var.ecs_cluster_name
  ecs_cpu_threshold           = var.ecs_cpu_threshold
  ecs_memory_threshold        = var.ecs_memory_threshold
  ec2_asg_name                = var.ec2_asg_name
  ec2_cpu_threshold           = var.ec2_cpu_threshold
  alb_name                    = var.alb_name
  alb_5xx_threshold           = var.alb_5xx_threshold
  alb_latency_threshold       = var.alb_latency_threshold
}

module "aws_sns_topic" {
  source                      = "./Modules/SNS"
  alert_email               = var.alert_email
  sns_topic_name              = var.sns_topic_name
  environment                 = var.environment
  application_name            = var.application_name
  owner                       = var.owner
  
}
module "rds_role" {
  source                      = "./Modules/IAM"
  role_name                   = var.rds_role_name
  trusted_services            = var.rds_trusted_services
  policy_arns                 = var.rds_policy_arns
}
module "ecs_task_execution_role" {
  source                      = "./Modules/IAM"
  role_name                   = var.ecs_role_name
  trusted_services            = var.ecs_trusted_services
  policy_arns                 = var.ecs_policy_arns
}
