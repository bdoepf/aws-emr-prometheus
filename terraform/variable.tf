
variable "cidr_access" {
  description = "CIDR to whch gets access to the EMR cluster and Grafana/Proemtheus instance. Example: '<your-current-ip>/32'"
}

variable "ssh_key_name" {
  description = "AWS ssh key name to use when deploying the instances"
}

variable "public_subnet_id" {
  description = "Public subnet id to deploy the resources into"
}

variable "bucket_name" {
  description = "Bucket to use as staging bucket"
}

variable "enable_prometheus" {
  type = bool
  description = "Deploy the prometheus/grafana EC2 instance"
  default = true
}

variable "enable_emr" {
  type = bool
  description = "Deploy the example EMR cluster"
  default = true
}
