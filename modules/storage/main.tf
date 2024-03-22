resource "aws_db_subnet_group" "terraform_snyk_rds_subnet_grp" {
  name       = "terraform_snyk_rds_subnet_grp_${var.environment}"
  subnet_ids = var.private_subnet

  tags = merge(var.default_tags, {
    Name = "terraform_snyk_rds_subnet_grp_${var.environment}"
  })
}

resource "aws_security_group" "terraform_snyk_rds_sg" {
  name   = "terraform_snyk_rds_sg"
  vpc_id = var.vpc_id

  tags = merge(var.default_tags, {
    Name = "terraform_snyk_rds_sg_${var.environment}"
  })

  # HTTP access from anywhere
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "terraform_snyk_rds_sg2" {
  name   = "terraform_snyk_rds_sg2"
  vpc_id = var.vpc_id

  tags = merge(var.default_tags, {
    Name = "terraform_snyk_rds_sg2_${var.environment}"
  })

  # HTTP access from anywhere
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_kms_key" "terraform_snyk_db_kms_key" {
  description             = "KMS Key for DB instance ${var.environment}"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = merge(var.default_tags, {
    Name = "terraform_snyk_db_kms_key_${var.environment}"
  })
}

resource "aws_db_instance" "terraform_snyk_db" {
  db_name                      = "terraform_snyk_db_${var.environment}"
  allocated_storage         = 20
  engine                    = "postgres"
  engine_version            = "16.2"
  instance_class            = "db.t3.micro"
  storage_type              = "gp2"
  password                  = var.db_password
  username                  = var.db_username
  vpc_security_group_ids    = [aws_security_group.terraform_snyk_rds_sg.id]
  db_subnet_group_name      = aws_db_subnet_group.terraform_snyk_rds_subnet_grp.id
  identifier                = "terraform-snyk-db-${var.environment}"
  storage_encrypted         = true
  skip_final_snapshot       = true
  final_snapshot_identifier = "terraform-snyk-db-${var.environment}-db-destroy-snapshot"
  kms_key_id                = aws_kms_key.terraform_snyk_db_kms_key.arn
  tags = merge(var.default_tags, {
    Name = "terraform_snyk_db_${var.environment}"
  })
}

resource "aws_ssm_parameter" "terraform_snyk_ssm_db_host" {
  name        = "/snyk-${var.environment}/DB_HOST"
  description = "Snyk Database"
  type        = "SecureString"
  value       = aws_db_instance.terraform_snyk_db.endpoint

  tags = merge(var.default_tags, {})
}

resource "aws_ssm_parameter" "terraform_snyk_ssm_db_password" {
  name        = "/snyk-${var.environment}/DB_PASSWORD"
  description = "Snyk Database Password"
  type        = "SecureString"
  value       = aws_db_instance.terraform_snyk_db.password

  tags = merge(var.default_tags, {})
}

resource "aws_ssm_parameter" "terraform_snyk_ssm_db_user" {
  name        = "/snyk-${var.environment}/DB_USER"
  description = "Snyk Database Username"
  type        = "SecureString"
  value       = aws_db_instance.terraform_snyk_db.username

  tags = merge(var.default_tags, {})
}
resource "aws_ssm_parameter" "terraform_snyk_ssm_db_name" {
  name        = "/snyk-${var.environment}/DB_NAME"
  description = "Snyk Database Name"
  type        = "SecureString"
  value       = aws_db_instance.terraform_snyk_db.db_name

  tags = merge(var.default_tags, {
    environment = "${var.environment}"
  })
}

#this resource is tied to the bucket names below to consistently provide random bucket names
resource "random_id" "terraform_example" {
  byte_length = 8
}

resource "aws_s3_bucket" "terraform_snyk_storage" {
  bucket = "snyk-storage-${var.environment}-demo-${random_id.terraform_example.hex}"
  tags = merge(var.default_tags, {  
    name = "snyk_blob_storage_${var.environment}"
  })
}

resource "aws_s3_bucket" "terraform_my_new_undeployed_bucket" {
  bucket = "snyk-public-${var.environment}-demo-${random_id.terraform_example.hex}"
}

resource "aws_s3_bucket_public_access_block" "terraform_snyk_public" {
  bucket = aws_s3_bucket.terraform_my_new_undeployed_bucket.id

  ignore_public_acls = var.public_var_test
  block_public_acls   = var.public_var_test
  block_public_policy = var.public_var_test
}

resource "aws_s3_bucket_public_access_block" "terraform_snyk_private" {
  bucket = aws_s3_bucket.terraform_snyk_storage.id

  ignore_public_acls  = true
  block_public_acls   = true
  block_public_policy = true
}
