variable "alb_name" {

}


variable "subnet_ids" {

}

variable "vpc_id" {

}

variable "alb_sg_id" {

}

variable "certificate_arn" {

}

variable "frontend_health_check_path" {
   type        = string
   default     = "/"
 }

 variable "frontend_health_check_matcher" {
   type        = string
   default     = "200-399"
 }

 variable "backend_health_check_path" {
   type        = string
   default     = "/health"
 }

 variable "backend_health_check_matcher" {
   type        = string
   default     = "200-399"
 }

 variable "health_check_interval" {
   type        = number
   default     = 30
 }

 variable "health_check_timeout" {
   type        = number
   default     = 5
 }

# variable "healthy_threshold" {
#   type        = number
#   default     = 3
# }

# variable "unhealthy_threshold" {
#   type        = number
#   default     = 3
# }

variable "tags" {
  type        = map(string)
  default     = {}
}
