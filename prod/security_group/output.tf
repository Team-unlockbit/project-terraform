output "openvpn_sg_id" {
  value = aws_security_group.openvpn_sg.id
}

output "gitlab_sg_id" {
  value = aws_security_group.gitlab_sg.id
}
