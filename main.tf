# Calling a terraform module ec2 to provision a instance.
module "web_app" {
  source               = "./modules/ec2"
  instance_name        = var.instance_name
  vpc_id               = var.vpc_id
  subnet_id            = var.subnet_id
  enable_eip           = var.enable_eip
  sg_name              = var.sg_name
  sg_ingress_rule      = var.sg_ingress_rule
  key_pair_name        = var.key_pair_name
  instance_type        = var.instance_type
  user_data_file_path = file("${path.module}/${var.user_data_file_path}")
  priv_key_output_path = "${path.module}/${var.priv_key_output_path}"
  web_app_dir_path     = "${path.module}/${var.web_app_dir_path}"
}