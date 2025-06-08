# Output the public IP of the EC2 instance.
# If EIP is enabled, output the EIP; otherwise, use the EC2's default public IP.
output "ec2_pub_ip" {
  value = var.enable_eip ? aws_eip.eip[0].public_ip : aws_instance.web.public_ip
}