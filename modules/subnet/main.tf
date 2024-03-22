resource "aws_subnet" "terraform_main" {
  vpc_id     = var.vpc_id
  cidr_block = var.cidr_main
  availability_zone = "${var.region}a"

  tags = {
    Name = "Main"
  }
}

resource "aws_subnet" "terraform_secondary" {
  vpc_id     = var.vpc_id
  cidr_block = var.cidr_secondary
  availability_zone = "${var.region}c"

  tags = {
    Name = "Secondary"
  }
}
