resource "aws_instance" "openvpn" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  security_groups = [var.security_group_id]

  key_name = var.keypair_name

  root_block_device {
    volume_size = 30
  }

  tags = {
    Name = var.ec2_name
  }
}