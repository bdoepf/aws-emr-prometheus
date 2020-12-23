output "prometheus_security_group_id" {
  value = aws_security_group.prometheus.id
}

output "grafana_url" {
  value = "${aws_instance.prometheus.public_dns}:3000"
}

