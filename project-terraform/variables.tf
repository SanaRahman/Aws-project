variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "15.0.0.0/16"
}

variable "region" {
  description = "AWS region where resources will be provisioned"
  type        = string
  default     = "ap-southeast-1"
}
variable "database_secret_name" {
  description = "Name of the secret in Secrets Manager"
  type        = string
  default = "postgres"
}

variable "database_name" {
  description = "Database name for RDS cluster"
  type        = string
  default = "postgres"
}

variable "master_username" {
  description = "Master username for RDS cluster"
  type        = string
   default = "postgres"
}

variable "master_password" {
  description = "Master password for RDS cluster"
  type        = string
  default = "postgres"
}

variable "rds_cluster_instance_class" {
  description = "The RDS instance class for the Aurora cluster"
  type        = string
  default     = "db.serverless"
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "15.0.1.0/24"
}

variable "public_subnet_cidr_block2" {
  description = "CIDR block for the public subnet2"
  type        = string
  default     = "15.0.5.0/24"
}

variable "private_subnet1_cidr_block" {
  description = "CIDR block for private subnet 1"
  type        = string
  default     = "15.0.2.0/24"
}

variable "private_subnet2_cidr_block" {
  description = "CIDR block for private subnet 2"
  type        = string
  default     = "15.0.3.0/24"
}

variable "public_subnet_ava_zone" {
  description = "Availability zone for the public subnet"
  type        = string
  default     = "ap-southeast-1a"
}

variable "private_subnet1_ava_zone" {
  description = "Availability zone for private subnet 1"
  type        = string
  default     = "ap-southeast-1b"
}

variable "private_subnet2_ava_zone" {
  description = "Availability zone for private subnet 2"
  type        = string
  default     = "ap-southeast-1c"
}

variable "rds_port" {
  description = "RDS ingress to port"
  type        = number
  default     = 5432
}

variable "arora_engine_v" {
  description = "Arora Engine Version"
  type        = string
  default     = "13.6"
}

variable "tags" {
  type = map(string)

  default = {
    Name    = "Default_Name"
    Creator = "Sana Rahman"
    Project = "Sprint 2"
  }
}

variable "cidr_block" {
  description = "Public CIDR Block"
  type        = string
  default     = "0.0.0.0/0"
}

variable "egress_port" {
  description = "TCP egress to port"
  type        = number
  default     = 0
}

variable "egress_protocol" {
  description = "TCP egress protocol"
  type        = string
  default     = "tcp"
}

variable "egress_cidr_blocks" {
  description = "TCP egress CIDR blocks"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ecs_memory" {
  description = "Memory value for ECS task"
  type        = string
  default     = "2048"
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "my-ecs-cluster"
}

variable "ecs_network_mode" {
  description = "Network mode for ECS task"
  type        = string
  default     = "awsvpc"
}

variable "frontend_container_name" {
  description = "Name of the frontend container"
  type        = string
  default     = "frontend_container"
}

variable "alb_name" {
  description = "Name of the Application Load Balanacer"
  type        = string
  default     = "api-alb"
}

variable "load_balancer_type" {
  description = "Load Balancer Type"
  type        = string
  default     = "application"
}

variable "enable_deletion_protection" {
  description = "Opption for enabling deletion protection"
  type        = string
  default     = "false"
}

variable "front_tg_name" {
  description = "Name for the frontend target group"
  type        = string
  default     = "frontend-tg"
}

variable "target_type" {
  description = "Type of target for the target group"
  type        = string
  default     = "ip"
}

variable "ecr_iam_policy_name" {
  description = "Name for the AWS IAM policy for ECR"
  type        = string
  default     = "ecr_policy"
}

variable "ecs_iam_role_name" {
  description = "Name for the AWS IAM role for ECS"
  type        = string
  default     = "ecs_execution_role"
}

variable "ecr_repository_name" {
  description = "Name of the existing AWS ECR repository"
  type        = string
  default     = "my_ecr_repo"
}

variable "ecs_service_name" {
  description = "Name for the AWS ECS service"
  type        = string
  default     = "api-service"
}

variable "sg_name_ecs" {
  description = "Prefix for the AWS security group name for Ecs"
  type        = string
  default     = "ecs-sg"
}

variable "sg_name_alb" {
  description = "Prefix for the AWS security group name for Alb"
  type        = string
  default     = "alb-sg"
}

variable "alb_internal" {
  description = "Sets Alb to internal"
  type        = string
  default     = "false"
}

variable "ecs_task_family" {
  description = "Family name for the AWS ECS task definition"
  type        = string
  default     = "api-task"
}

variable "image_tag" {
  description = "Image tag for the ECS task definition"
  default     = "carbon"
}

variable "http_port" {
  description = "HTTP port"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "HTTPS port"
  type        = number
  default     = 443
}

variable "custom_port_1" {
  description = "Custom port 1"
  type        = number
  default     = 3000
}

variable "protocol_tcp" {
  description = "TCP protocol"
  type        = string
  default     = "tcp"
}

variable "protocol_http" {
  description = "HTTP protocol"
  type        = string
  default     = "http"
}

variable "domain_name" {
  description = "The root domain name"
  type        = string
  default     = "bootcamp1.xgrid.co"
}

variable "subdomain_name" {
  description = "The subdomain name"
  type        = string
  default     = "sana.bootcamp1.xgrid.co"
}

variable "ecs_cpu" {
  description = "CPU value for ECS task"
  type        = string
  default     = "1024"
}

variable "all_ports" {
  description = "Allows all ports"
  type        = number
  default     = 0
}