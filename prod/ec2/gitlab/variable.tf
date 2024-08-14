variable "ec2_name" {
  description = "openvpn instance name"
  type        = string
}
variable "ami_id" {
  description = "EC2 인스턴스에 사용할 AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 인스턴스 유형"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "EC2 인스턴스를 배치할 서브넷 ID"
  type        = string
}

variable "security_group_id" {
  description = "EC2 인스턴스에 할당할 보안 그룹 ID"
  type        = string
}

variable "keypair_name" {
  description = "키페어 이름"
  type        = string
}

variable "volume_size" {
  description = "EC2 volume size"
  type        = number
}

variable "private_ip" {
  description = "gitlab static ip"
  type        = string
}
