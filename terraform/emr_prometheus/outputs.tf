output "emr_master_dns" {
  value = aws_emr_cluster.emr.master_public_dns
}
