variable "emr_name" {
  description = "Name of the EMR cluster"
}

variable "emr_release_label" {
  default = "emr-6.1.0"
  description = "EMR version to use"
}

variable "emr_services" {
  type        = list(string)
  description = "EMR services to deploy"
  default     = ["Spark"]
}

variable "emr_master_ec2_instance_type" {
  description = "EMR master ec2 instance type to use"
  default     = "m6g.xlarge"
}

variable "emr_core_ec2_instance_type" {
  description = "EMR slave ec2 instance type to use"
  default     = "m6g.xlarge"
}

variable "emr_core_ec2_instance_count" {
  type        = number
  description = "Number of EMR core instances"
  default     = 2
}

variable "ec2_ssh_key_name" {
  description = "ssh key name to use for all EC2 instances"
}

variable "subnet_id" {
  description = "The subnet to deploy the EMR Cluster into"
}

variable "bid_price" {
  description = "Leave empty to use on demand instances"
  default = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags to add to all resources"
}

variable "emr_s3_staging_bucket" {
  description = "Bucket used to upload bootstrap and EMR config scripts."
}

variable "emr_s3_staging_key" {
  description = "Key in the staging bucket used to upload bootstrap and EMR config scripts."
}

variable "prometheus_node_exporter_version" {
  description = "Version of prometheus node exporter to use on EMR cluster nodes"
  default = "1.0.1"
}

variable "prometheus_jmx_exporter_version" {
  description = "Version of prometheus jmx exporter to use on EMR cluster nodes"
  default = "0.14.0"
}

variable "emr_service_role_arn" {
  description = "EMR service role ARN to use for the emr cluster"
}

variable "emr_ec2_instance_profile_arn" {
  description = "EC2 instance profile used for the master and worker instances"
}

variable "enable_prometheus_ingress" {
  type = bool
  description = "If true, then an ingress role for the prometheus instance will be created"
}

variable "prometheus_security_group_id" {
  description = "Security group id of Prometheus instance. If 'enable_prometheus_ingress' is false, then this will be ignored."
}

variable "ingress_ip_range" {
  description = "ip range to allow access (ssh -> Port 22) eg. <your ip address>/32"
}
