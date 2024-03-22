output "vpc_id" {
  value = aws_vpc.terraform_example.id
}

output "vpc_sg_id" {
  value = aws_default_security_group.terraform_default.id
}
