output "ec2_public_ip" { value = aws_instance.app.public_ip}
output "ec2_instance_id" { value = aws_instance.app.id }
output "ec2_Sg_id" { value = aws_security_group_ec2_sg.id}
