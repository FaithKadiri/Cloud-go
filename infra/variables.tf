variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for Amazon Linux 2"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository URL"
  type        = string
}

variable "db_name" {
  description = "RDS database name"
  default     = "mydb"
}

variable "db_user" {
  description = "RDS database username"
  default     = "admin"
}

variable "db_pass" {
  description = "RDS database password"
  type        = string
  sensitive   = true
}
