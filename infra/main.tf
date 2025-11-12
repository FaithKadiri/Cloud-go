provider "aws" {
  region = var.region
}


module "vpc" {
  source = "./modules/vpc"
  region = var.region
}

module "ec2" {
  source         = "./modules/ec2"
  region         = var.region
  vpc_id         = module.vpc.vpc_id
  subnet_id      = module.vpc.public_subnet_id
  ami_id         = var.ami_id
  key_name       = var.key_name
  github_repo    = var.github_repo
  rds_endpoint   = aws_db_instance.db.endpoint
  db_name        = var.db_name
  db_user        = var.db_user
  db_pass        = var.db_pass
  s3_bucket      = aws_s3_bucket.storage.bucket
  log_group_name = aws_cloudwatch_log_group.app_logs.name

  depends on = [aws_db_instance.db]
}


resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
}

resource "aws_s3_bucket" "storage" {
  bucket = "flask-app-storage-${random_string.suffix.result}"
  tags   = { Name = "flask-app-storage" }
}


resource "aws_cloudwatch_log_group" "app_logs" {
  name = "/ec2/flask"
  retention_in_days = 7
  tags = { Name = "flask-logs" }
}

resource "aws_db_subnet_group" "main" {
  name = "flask-db-subnet-group" 
  subnet_ids = [module.vpc.public_sunet_id]
}

resource "aws_security_group" "rds_sg" {
  name = "flask-rds-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [module.ec2.ec_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "flask-rds-sg" }
}

resource "aws_db_instance" "db" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "15.4"
  instance_class         = "db.t3.micro"
  db_name                = var.db_name
  username               = var.db_user
  password               = var.db_pass
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  skip_final_snapshot    = true
  tags                   = { Name = "flask-rds" }
}







