# Fetches the default KMS key used for EBS encryption
data "aws_ebs_default_kms_key" "default" {}

# Creates an EC2 instance with optional EIP association, encrypted root volume, and user-provided configuration
resource "aws_instance" "web" {
  ami                         = data.aws_ami.ami.id
  instance_type               = var.instance_type
  associate_public_ip_address = var.enable_eip ? false : true
  vpc_security_group_ids      = [aws_security_group.sg.id]
  key_name                    = aws_key_pair.ssh_key_pair.key_name
  user_data                   = var.user_data_file_path
  subnet_id                   = local.get_subnet_id

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = data.aws_ebs_default_kms_key.default.key_arn
  }

  tags = {
    Name = var.instance_name
  }

  # Prevents instance recreation if public IP association is changed outside Terraform
  lifecycle {
    ignore_changes = [associate_public_ip_address]
  }

  depends_on = [data.aws_ami.ami, aws_key_pair.ssh_key_pair, aws_security_group.sg, data.aws_ebs_default_kms_key.default]
}

# Allocates and associates an Elastic IP to the EC2 instance if enabled
resource "aws_eip" "eip" {
  count = var.enable_eip ? 1 : 0
  domain   = "vpc"
  instance = aws_instance.web.id

  tags = {
    Name = "${var.instance_name}-eip"
  }
}
