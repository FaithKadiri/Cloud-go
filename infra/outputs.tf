output "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  value       = module.ec2.ec2_public_ip
}

output "s3_bucket" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.storage.bucket
}

output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.db.endpoint
}