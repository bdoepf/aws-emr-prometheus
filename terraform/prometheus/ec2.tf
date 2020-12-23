locals {
  sg_name = "Prometheus_Grafana"
}

data "aws_ami" "prometheus_packer_image" {
  most_recent = true

  filter {
    name   = "name"
    values = ["prometheus-grafana-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["self"]
}

data "aws_subnet" "prometheus" {
  id = var.subnet_id
}

resource "aws_security_group" "prometheus" {
  name        = local.sg_name
  description = "Security group for the ec2 prometheus grafana instance"
  vpc_id      = data.aws_subnet.prometheus.vpc_id

  tags = merge(var.tags, {
    Name = local.sg_name
  })
}

resource "aws_security_group_rule" "grafana_ingress" {
  type              = "ingress"
  description       = "Grafana UI"
  from_port         = 3000
  to_port           = 3000
  protocol          = "TCP"
  cidr_blocks       = [var.ingress_ip_range]
  security_group_id = aws_security_group.prometheus.id
}

resource "aws_security_group_rule" "prometheus_ingress" {
  type              = "ingress"
  description       = "Prometheus UI"
  from_port         = 9090
  to_port           = 9090
  protocol          = "TCP"
  cidr_blocks       = [var.ingress_ip_range]
  security_group_id = aws_security_group.prometheus.id
}

resource "aws_security_group_rule" "ssh_ingress" {
  type              = "ingress"
  description       = "Prometheus UI"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = [var.ingress_ip_range]
  security_group_id = aws_security_group.prometheus.id
}

resource "aws_security_group_rule" "prometheus_egress" {
  type              = "egress"
  description       = "Prometheus scrape metrics"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.prometheus.id
}

resource "aws_instance" "prometheus" {
  ami                    = data.aws_ami.prometheus_packer_image.id
  instance_type          = var.ec2_instance_type
  key_name               = var.ec2_ssh_key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.prometheus.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_prometheus.name
  tags                   = merge(var.tags, {
    Name = "Prometheus / Grafana"
  })
}


