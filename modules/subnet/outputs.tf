output "subnet_id_main" {
  value = aws_subnet.terraform_main.id
}

output "subnet_id_secondary" {
  value = aws_subnet.terraform_secondary.id
}
