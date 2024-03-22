resource "aws_vpc" "terraform_example" {
  cidr_block = var.cidr
}

resource "aws_default_security_group" "terraform_default" {
  vpc_id = aws_vpc.terraform_example.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }
}

resource "aws_security_group" "terraform_allow_ssh" {
  name        = "terraform_allow_ssh"
  description = "Allow SSH inbound from anywhere"
  vpc_id      = aws_vpc.terraform_example.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "terraform_allow_ssh_with_valid_cidr" {
  name        = "terraform_allow_ssh_with_valid_cidr"
  description = "Allow SSH inbound from specific range"
  vpc_id      = aws_vpc.terraform_example.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = tolist([ var.cidr ])
  }
}
