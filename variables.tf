variable "ami_name" {
  description = "Provide the name of the AMI"
  type = string
  default = "ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"
}

# Optional VPC ID to use for the EC2 instance.
# If not provided, the default VPC will be used.
variable "vpc_id" {
  description = "Optional VPC ID. If provided, subnet_id must also be set."
  type        = string
  default     = ""
}

# Optional subnet ID within the specified VPC.
# Required only if vpc_id is provided.
variable "subnet_id" {
  description = "Optional Public Subnet ID. Must be set if vpc_id is provided."
  type        = string
  default     = ""

  validation {
    condition     = var.vpc_id == "" || (var.vpc_id != "" && var.subnet_id != "")
    error_message = "If vpc_id is provided, public subnet_id must also be provided."
  }
}

# EC2 instance type to launch (e.g., t2.micro, t2.small).
variable "instance_type" {
  description = "Provide the instane type"
  type        = string
  default     = "t3.small"
}

# Map of ingress rules for the Security Group.
# Each rule should define keys like description, cidr_ipv4, ip_protocol, from_port, and to_port.
variable "sg_ingress_rule" {
  description = "Provide the ingress rule for Security Groups"
  type        = map(map(string))
  default     = {
    "ssh_rule" = {
      "description" = "Allow SSH port"
      "from_port"   = 22
      "to_port"     = 22
      "ip_protocol" = "tcp"
      "cidr_ipv4"   = "0.0.0.0/0"
    },
    "web_rule" = {
      "description" = "Allow Web traffic"
      "from_port"   = 8081
      "to_port"     = 8081
      "ip_protocol" = "tcp"
      "cidr_ipv4"   = "0.0.0.0/0"
    }
  }
}

# Boolean flag to create and associate an Elastic IP (EIP) with the instance.
variable "enable_eip" {
  description = "Provide true if you want to create EIP."
  type        = bool
  default     = false
}

# Tag name for the EC2 instance.
variable "instance_name" {
  description = "Provide a name of the Ec2 instance"
  type        = string
  default     = "devops-assignment"
}

# Name to assign to the Security Group.
variable "sg_name" {
  description = "Provide the name for he Security Group"
  type        = string
  default     = "devops-assignment-sg"
}

# Name of the SSH Key Pair to associate with the EC2 instance.
variable "key_pair_name" {
  description = "Provide the name for the AWS Key Pair"
  type        = string
  default     = "devops-assignment-key"
}

# User data script to be run during instance launch.
variable "user_data_file_path" {
  description = "User data script content"
  type        = string
  default = "user_data.sh"
}

# Local directory path to save the generated private key file.
variable "priv_key_output_path" {
  description = "Path of the private key"
  type        = string
  default = "ssh_key_pair/"
}

# Local directory path containing the web application to copy.
variable "web_app_dir_path" {
  description = "Provide the path of applciation directory."
  type        = string
  default = "app"
}