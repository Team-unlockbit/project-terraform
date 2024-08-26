output "openvpn_sg_id" {
  value = aws_security_group.openvpn_sg.id
}

output "gitlab_sg_id" {
  value = aws_security_group.gitlab_sg.id
}

output "ecs_sg_id" {
  value = aws_security_group.ecs_sg.id
}

output "ecs_task_id" {
  value = aws_security_group.ecs_sg.id
}

output "ecs_alb_id" {
  value = aws_security_group.ecs_alb.id
}
