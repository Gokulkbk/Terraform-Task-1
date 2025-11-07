output "mumbai_instance_public_ip" {
  value = aws_instance.ec2_mumbai.public_ip
}

output "singapore_instance_public_ip" {
  value = aws_instance.ec2_singapore.public_ip
}
