variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the EC2 instance will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "github_repo" {
  description = "GitHub repo URL for the Flask app"
  type        = string
}

variable "rds_endpoint" {
  description = "RDS endpoint for database connection"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_user" {
  description = "Database user"
  type        = string
}

variable "db_pass" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "s3_bucket" {
  description = "S3 bucket name for uploads"
  type        = string
}

variable "log_group_name" {
  description = "CloudWatch Log Group name"
  type        = string
}
