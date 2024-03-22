provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"
}

module "subnet"  {
  source = "./modules/subnet"
  vpc_id = module.vpc.vpc_id
  region = var.region
}

module "storage" {
  source = "./modules/storage"

  acl = var.s3_acl
  db_password = "supersecret"
  db_username = "snyk"
  environment = var.env
  vpc_id = module.vpc.vpc_id
  private_subnet = [module.subnet.subnet_id_main, module.subnet.subnet_id_secondary]
}

module "iam" {
  source = "./modules/iam"

  environment = var.env
}

module "instance" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  ami                    = var.ami
  instance_type          = "t2.micro"
  name                   = "terraform-example-server"

  vpc_security_group_ids = [module.vpc.vpc_sg_id]
  subnet_id              = module.subnet.subnet_id_main

  tags = {
    Terraform            = "true"
    Environment          = var.env
  }
}

