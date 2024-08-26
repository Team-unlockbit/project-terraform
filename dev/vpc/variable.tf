variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "server_port" {
  description = "Webserver's http port"
  type        = number
}

variable "region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-3"
}

variable "vpc_name" {
  description = "VPC의 이름"
  type        = string
  default     = "vpc"
}

variable "subnet_name" {
  description = "subnet names"
  type        = list(string)
}

variable "igw_name" {
  description = "VPC의 이름"
  type        = string
  default     = "igw"
}

variable "nat_name" {
  description = "nat names"
  type        = list(string)
}

variable "public_subnet_a_cidr" {
  description = "가용영역 A의 Public 서브넷 CIDR 블록"
  type        = string
}

variable "public_subnet_c_cidr" {
  description = "가용영역 C의 Public 서브넷 CIDR 블록"
  type        = string
}

variable "private_subnet_a_cidr" {
  description = "가용영역 A의 Private 서브넷 A CIDR 블록"
  type        = string
}

variable "private_subnet_nat_a_cidr" {
  description = "가용영역 A의 Private 서브넷 Nat A CIDR 블록"
  type        = string
}

variable "private_subnet_c_cidr" {
  description = "가용영역 C의 Private 서브넷 C CIDR 블록"
  type        = string
}

variable "private_subnet_nat_c_cidr" {
  description = "가용영역 C의 Private 서브넷 Nat C CIDR 블록"
  type        = string
}