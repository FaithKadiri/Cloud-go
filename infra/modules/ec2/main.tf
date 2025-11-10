resource "aws_security_group" "ec2_sg" {
    vpc_id = var.vpc_id

    ingress {
        description = "Allow HTTP for flask"
        from_port = 5000
        to_port = 5000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "Allow SSH from local IP"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "Allow all outbound traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
         cidr_blocks = ["0.0.0.0/0"]
    }

    tags = { Name = "flask-ec2-sg" }
}

resource "aws_instance" "app" {
    ami = var.ami_id
    instance_type = "t2.micro"
    subnet_id = var.subnet_id
    vpc_security_group_ids = [aws_security_group.ec2_sg.id]
    key_name = var.key_name
    iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

    user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y python3 git amazon-cloudwatch-agent
    pip3 install flask==2.0.1 boto3==1.18.0 psycopg2-binary==2.9.3 python-dotenv==0.19.0
    git clone ${var.github_repo} /app
    cd /app
    psql -h ${var.rds_endpoint} -U ${var.db_user} -d ${var.db_name} -c "CREATE TABLE IF NOT EXISTS uploads (id SERIAL PRIMARY KEY, filename VARCHAR(255));"
    echo "DB_HOST=${var.rds_endpoint}" > /app/.env
    echo "DB_NAME=${var.db_name}" >> /app/.env
    echo "DB_USER=${var.db_user}" >> /app/.env
    echo "DB_PASS=${var.db_pass}" >> /app/.env
    echo "S3_BUCKET=${var.s3_bucket}" >> /app/.env
    cat <<EOT > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
    {
      "logs": {
        "logs_collected": {
          "files": {
            "collect_list": [
              {
                "file_path": "/app/nohup.out",
                "log_group_name": "${var.log_group_name}",
                "log_stream_name": "{instance_id}"
              }
            ]
          }
        }
      }
    }
    EOT
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
    cd /app
    nohup python3 app.py &
    EOF

  tags = { Name = "flask-app-ec2" }
}

resource "aws_iam_role" "ec2_role" {
    name = "flask_ec2_role"
    assume_role_policy = jsonencode ({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
               Service = "ec2.amazonaws.com" 
            }
        }]
    })
}

resource "aws_iam_role_policy" "ec2_policy" {
    role = aws_iam_role.ec2_role.id
    
    policy = jsonencode ({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = ["s3:PutObject", "s3:GetObject"]
                Resource = "arn:aws:S3:::${var.s3_bucket}/*"
            },
            {
              Effect = "Allow"
              Action = ["logs:CreateLogStream", "logs:PutLogEvents"]
              Resource = "arn:aws:logs:${var.region}:*:log-group:${var.log_group_name}:*"
            }
        ]
    })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "flask-app-ec2-profile"
  role = aws_iam_role.ec2_role.name
}