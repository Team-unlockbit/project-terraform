resource "aws_instance" "gitlab" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  security_groups = [var.security_group_id]

  key_name = var.keypair_name
  private_ip = var.private_ip

  root_block_device {
    volume_size = 30
  }

  user_data = templatefile("${path.module}/docker-compose.tpl", {
    gitlab_ip = var.private_ip
  })

  tags = {
    Name = var.ec2_name
  }
}