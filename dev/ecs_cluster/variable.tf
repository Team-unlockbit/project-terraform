variable ecs_name {
  description = "ECS name"
  type        = string
}

variable "ec2_name" {
  description = "openvpn instance name"
  type        = string
}

variable "ami_id" {
  description = "EC2 인스턴스에 사용할 AMI ID"
  type        = string
#   default     = "ami-044359f47748149a8"
}

variable "instance_type" {
  description = "EC2 인스턴스 유형"
  type        = string
#   default     = "t2.micro"
}

variable "public_subnet_a_id" {
  description = "EC2 인스턴스를 배치할 서브넷 ID"
  type        = string
}

variable "public_subnet_c_id" {
  description = "EC2 인스턴스를 배치할 서브넷 ID"
  type        = string
}

variable "prvsub_nat_a_id" {
  description = "EC2 인스턴스를 배치할 서브넷 ID"
  type        = string
}

variable "prvsub_nat_c_id" {
  description = "EC2 인스턴스를 배치할 서브넷 ID"
  type        = string
}

variable "security_group_id" {
  description = "EC2 인스턴스에 할당할 보안 그룹 ID"
  type        = string
}

variable "security_group_task_id" {
  description = "ECS task 할당할 보안 그룹 ID"
  type        = string
}

variable "security_group_alb_id" {
  description = "ECS alb 할당할 보안 그룹 ID"
  type        = string
}

variable "repository_url" {
  description = "ECR repository url"
  type        = string
}

variable "vpc_id" {
  description = "ECR repository url"
  type        = string
}