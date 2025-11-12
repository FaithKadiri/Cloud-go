output "ec2_public_ip" { value = aws_instance.app.public_ip}
output "ec2_instance_id" { value = aws_instance.app.id }
output "ec2_sg_id" { value = aws_security_group.ec2_sg.id}
