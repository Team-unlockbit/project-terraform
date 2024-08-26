locals {
  vpc_cidr        = "10.0.1.0/24"
  ecs_name        = "ECS-93-web"
  ec2_name        = "EC2-93-ecs"
  ami_id          = "ami-044359f47748149a8"
  #instance_type = "t3.medium"
  instance_type   = "t3.micro"
  container_name  = "web"
  open_vpn_ip     = "10.0.10.150" 
  ubuntu_ami      = "ami-0d6eb0b45cbef13b4"
  gitlabami_id    = "ami-0db6b6e701fbc0603"
  keypair_name    = "KEY-93-banana"
}

provider "aws" {
  region = "ap-northeast-3"
}
# VPC 모듈
module "vpc" {
  source                    = "./vpc"

  vpc_cidr                  = local.vpc_cidr
  server_port               = 80
  vpc_name                  = "VPC-93-ECS"
  subnet_name               = [ "sub-93-pub-a", "sub-93-pub-c", "sub-93-prv-a", "sub-93-prv-c", "sub-93-prv-nat-a", "sub-93-prv-nat-c" ]
  igw_name                  = "IGW-93"
  nat_name                  = [ "NAT-93-a", "NAT-93-c" ]
  public_subnet_a_cidr      = cidrsubnet(local.vpc_cidr, 3, 0)
  public_subnet_c_cidr      = cidrsubnet(local.vpc_cidr, 3, 1)
  private_subnet_a_cidr     = cidrsubnet(local.vpc_cidr, 3, 2)
  private_subnet_nat_a_cidr = cidrsubnet(local.vpc_cidr, 3, 3)
  private_subnet_c_cidr     = cidrsubnet(local.vpc_cidr, 3, 4)
  private_subnet_nat_c_cidr = cidrsubnet(local.vpc_cidr, 3, 5)
}

# 보안그룹 모듈
module "sg" {
  source          = "./security_group"

  vpc_id          = module.vpc.vpc_id
  vpc_cidr_block  = module.vpc.vpc_cidr_block
}

# ECS 모듈
module "ecs" {
  source                  = "./ecs_cluster"

  ecs_name                = "ECS-93-wordpress"
  ec2_name                = "EC2-93-ecs"
  ami_id                  = "ami-044359f47748149a8"
  instance_type           = "t3.medium"
  vpc_id                  = module.vpc.vpc_id
  public_subnet_a_id      = module.vpc.pubsub_a_id
  public_subnet_c_id      = module.vpc.pubsub_c_id
  prvsub_nat_a_id         = module.vpc.prvsub_nat_a_id
  prvsub_nat_c_id         = module.vpc.prvsub_nat_c_id
  security_group_id       = module.sg.ecs_sg_id
  security_group_task_id  = module.sg.ecs_task_id
  security_group_alb_id   = module.sg.ecs_alb_id
  repository_url          = module.ecr.demo_app_repo_url
}

# ECR 모듈
module "ecr" {
  source    = "./ecr"

  ecr_name  = "ecr-su"
}

# EC2 module
module "openvpn" {
  source            = "./ec2/openvpn"
  subnet_id         = module.vpc.pubsub_a_id
  security_group_id = module.sg.openvpn_sg_id
  ami_id            = local.ubuntu_ami
  ec2_name          = "ec2-openvpn"
  keypair_name      = local.keypair_name
  volume_size       = 30
}

module "gitlab" {
  source            = "./ec2/gitlab"
  subnet_id         = module.vpc.prvsub_nat_a_id
  security_group_id = module.sg.gitlab_sg_id
  ami_id            = local.gitlabami_id
  instance_type     = "t2.large"
  ec2_name          = "ec2-gitlab"
  keypair_name      = local.keypair_name
  volume_size       = 30
  private_ip        = local.open_vpn_ip
}
