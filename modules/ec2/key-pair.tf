# Generates a random ID used to uniquely name the private key file
resource "random_id" "file_suffix" {
  byte_length = 4
}

# Generates an RSA SSH private key
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Writes the generated private key to a local file with secure permissions
resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${var.priv_key_output_path}/${var.instance_name}-priv-key-${random_id.file_suffix.id}.pem"
  file_permission = "0600"

  depends_on = [tls_private_key.ssh_key, random_id.file_suffix]
}

# Creates an AWS key pair using the generated public key
resource "aws_key_pair" "ssh_key_pair" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.ssh_key.public_key_openssh

  tags = {
    Name = var.key_pair_name
  }

  depends_on = [tls_private_key.ssh_key]
}