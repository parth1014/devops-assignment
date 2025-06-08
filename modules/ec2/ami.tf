# Fetches the most recent Ubuntu 22.04 AMI (Amazon Machine Image) published by Amazon on the basis on name filter
data "aws_ami" "ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [var.ami_name]
  }
}
