# Fetch the default VPC only if vpc_id is not provided
data "aws_vpc" "default" {
  count   = var.vpc_id == "" ? 1 : 0
  default = true
}

# Determine the VPC ID to use: use the provided one and if not provided than use the default
locals {
  get_vpc_id = var.vpc_id != "" ? var.vpc_id : data.aws_vpc.default[0].id
}

# Fetch the subnets of the selected VPC if no Subnet ID is provided explicitly
data "aws_subnets" "default" {
  count = var.vpc_id == "" ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [local.get_vpc_id]
  }
}

# Determine the subnet ID to use: use the provided one or the first from the default VPC
locals {
  get_subnet_id = var.vpc_id != "" ? var.subnet_id : data.aws_subnets.default[0].ids[0]
}

# Create a security group in the selected VPC
resource "aws_security_group" "sg" {
  name        = var.sg_name
  description = "Allow SSH and Web traffic"
  vpc_id      = local.get_vpc_id

  tags = {
    Name = var.sg_name
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [local.get_vpc_id]
}

# Ingress rules for the security group, based on provided map
resource "aws_vpc_security_group_ingress_rule" "allow_inbound_traffic" {
  for_each          = var.sg_ingress_rule
  security_group_id = aws_security_group.sg.id
  description       = each.value.description
  cidr_ipv4         = each.value.cidr_ipv4
  ip_protocol       = each.value.ip_protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port

  depends_on = [aws_security_group.sg]
}

# Egress rule to allow all outbound IPv4 traffic
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  depends_on = [aws_security_group.sg]
}

# Egress rule to allow all outbound IPv6 traffic
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"

  depends_on = [aws_security_group.sg]
}
