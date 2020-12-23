variable "ec2_instance_type" {
    description = "EC2 type to use as machine"
    default = "t3.small"
}

variable "ec2_ssh_key_name" {
  description = "ssh key name to use for the prometheus ec2 instance"
}

variable "subnet_id" {
  description = "The subnet to deploy the prometheus ec2 instance into"
}

variable "ingress_ip_range" {
  description = "ip range to allow access (ssh -> Port 22, prometheus -> Port 9090, grafana -> Port 3000) eg. <your ip address>/32"
}

variable "tags" {
  type = map(string)
  description = "Tags to add to all resources"
}
//
//variable "prometheus_scrape_cidr" {
//  description = "CIDR where prometheus should scrape metrics from"
//}
