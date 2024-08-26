output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.my_vpc.cidr_block
}

output "pubsub_a_id" {
  value = aws_subnet.pub_sub_a.id
}

output "pubsub_c_id" {
  value = aws_subnet.pub_sub_c.id
}

output "prvsub_a_id" {
  value = aws_subnet.prv_sub_a.id
}

output "prvsub_c_id" {
  value = aws_subnet.prv_sub_c.id
}

output "prvsub_nat_a_id" {
  value = aws_subnet.prv_sub_nat_a.id
}

output "prvsub_nat_c_id" {
  value = aws_subnet.prv_sub_nat_c.id
}
