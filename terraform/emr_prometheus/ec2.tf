locals {
  emr_master_sg_name = "EMR_Master_SG"
  emr_node_sg_name   = "EMR_Node_SG"
}

data "aws_subnet" "emr_subnet" {
  id = var.subnet_id
}

#############
# Master SG #
#############
resource "aws_security_group" "master" {
  name        = local.emr_master_sg_name
  description = "Security group for the EMR master instance"
  vpc_id      = data.aws_subnet.emr_subnet.vpc_id

  tags = merge(var.tags, {
    Name = local.emr_master_sg_name
  })
}
# We have to explicit use following six ingress rules (instead of just two with Protocol=all, Ports=all) to avoid EMR to create one of these rules by itself
# Which leads to non by terraform destroyable SGs
resource "aws_security_group_rule" "master_master_ingress_icmp" {
  type                     = "ingress"
  description              = "Master EMR-master ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  security_group_id        = aws_security_group.master.id
  source_security_group_id = aws_security_group.master.id
}

resource "aws_security_group_rule" "master_master_ingress_tcp" {
  type                     = "ingress"
  description              = "Master EMR-master ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "TCP"
  security_group_id        = aws_security_group.master.id
  source_security_group_id = aws_security_group.master.id
}

resource "aws_security_group_rule" "master_master_ingress_udp" {
  type                     = "ingress"
  description              = "Master EMR-master ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "UDP"
  security_group_id        = aws_security_group.master.id
  source_security_group_id = aws_security_group.master.id
}

resource "aws_security_group_rule" "master_node_ingress_icmp" {
  type                     = "ingress"
  description              = "Master EMR-node ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  security_group_id        = aws_security_group.master.id
  source_security_group_id = aws_security_group.node.id
}

resource "aws_security_group_rule" "master_node_ingress_tcp" {
  type                     = "ingress"
  description              = "Master EMR-node ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "TCP"
  security_group_id        = aws_security_group.master.id
  source_security_group_id = aws_security_group.node.id
}

resource "aws_security_group_rule" "master_node_ingress_udp" {
  type                     = "ingress"
  description              = "Master EMR-node ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "UDP"
  security_group_id        = aws_security_group.master.id
  source_security_group_id = aws_security_group.node.id
}

resource "aws_security_group_rule" "master_prometheus_ingress" {
  count                    = var.enable_prometheus_ingress ? 1 : 0
  type                     = "ingress"
  description              = "Master Prometheus ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.master.id
  source_security_group_id = var.prometheus_security_group_id
}

resource "aws_security_group_rule" "master_ssh" {
  type              = "ingress"
  description       = "SSH access"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  security_group_id = aws_security_group.master.id
  cidr_blocks       = [var.ingress_ip_range]
}

resource "aws_security_group_rule" "master_egress" {
  type              = "egress"
  description       = "Master EMR-nodes egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.master.id
  cidr_blocks       = ["0.0.0.0/0"]
}

###########
# Node SG #
###########
resource "aws_security_group" "node" {
  name        = local.emr_node_sg_name
  description = "Security group for the EMR node instances"
  vpc_id      = data.aws_subnet.emr_subnet.vpc_id

  tags = merge(var.tags, {
    Name = local.emr_node_sg_name
  })
}

# We have to explicit use following six ingress rules (instead of just two with Protocol=all, Ports=all) to avoid EMR to create one of these rules by itself
# Which leads to non by terraform destroyable SGs
resource "aws_security_group_rule" "node_master_ingress_icmp" {
  type                     = "ingress"
  description              = "Node EMR-master ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.master.id
}

resource "aws_security_group_rule" "node_master_ingress_tcp" {
  type                     = "ingress"
  description              = "Node EMR-master ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "TCP"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.master.id
}

resource "aws_security_group_rule" "node_master_ingress_udp" {
  type                     = "ingress"
  description              = "Node EMR-master ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "UDP"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.master.id
}

resource "aws_security_group_rule" "node_node_ingress_icmp" {
  type                     = "ingress"
  description              = "Node EMR-node ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.node.id
}

resource "aws_security_group_rule" "node_node_ingress_tcp" {
  type                     = "ingress"
  description              = "Node EMR-node ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "TCP"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.node.id
}

resource "aws_security_group_rule" "node_node_ingress_udp" {
  type                     = "ingress"
  description              = "Node EMR-node ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "UDP"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.node.id
}

resource "aws_security_group_rule" "node_prometheus_ingress" {
  count                    = var.enable_prometheus_ingress ? 1 : 0
  type                     = "ingress"
  description              = "Node Prometheus ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = var.prometheus_security_group_id
}

resource "aws_security_group_rule" "node_egress" {
  type              = "egress"
  description       = "Node EMR-nodes egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.node.id
  cidr_blocks       = ["0.0.0.0/0"]
}
