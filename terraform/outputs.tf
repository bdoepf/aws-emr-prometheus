output "grafana_url" {
  value = var.enable_prometheus ? module.prometheus.0.grafana_url : ""
}

output "emr_master_dns" {
  value = var.enable_emr ? module.emr_prometheus.0.emr_master_dns : ""
}

output "emr_cluster_id" {
  value = var.enable_emr ? module.emr_prometheus.0.emr_cluster_id : ""
}
