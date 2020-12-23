provider "aws" {
  region = "eu-west-1"
}

module "prometheus" {
  count  = var.enable_prometheus ? 1 : 0
  source = "./prometheus"

  ec2_ssh_key_name = var.ssh_key_name
  ingress_ip_range = var.cidr_access
  subnet_id        = var.public_subnet_id
  tags             = {}
}

module "emr_prometheus" {
  count  = var.enable_emr ? 1 : 0
  source = "./emr_prometheus"

  ec2_ssh_key_name             = var.ssh_key_name
  emr_name                     = "EMR"
  emr_s3_staging_bucket        = var.bucket_name
  emr_s3_staging_key           = "emr_prometheus_staging"
  subnet_id                    = var.public_subnet_id
  emr_service_role_arn         = aws_iam_role.emr_service_role.arn
  emr_ec2_instance_profile_arn = aws_iam_instance_profile.emr_ec2_instance_profile.arn
  emr_core_ec2_instance_type   = "m6g.xlarge"
  emr_core_ec2_instance_count  = 2
  emr_master_ec2_instance_type = "m6g.xlarge"
  enable_prometheus_ingress    = var.enable_prometheus
  prometheus_security_group_id = var.enable_prometheus ? module.prometheus.0.prometheus_security_group_id : ""
  ingress_ip_range             = var.cidr_access
  tags                         = {
    application = "hadoop"
  }
}
