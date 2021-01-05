output "emr_master_dns" {
  value = aws_emr_cluster.emr.master_public_dns
}

output "emr_cluster_id" {
  value = aws_emr_cluster.emr.id
}
