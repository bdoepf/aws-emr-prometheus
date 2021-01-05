locals {
  jmx_configs_s3_paths = [
  for o in aws_s3_bucket_object.hdfs_jmx_config:
  "s3://${o.bucket}/${o.key}"
  ]
  //  jmx_config_s3_path = aws_s3_bucket_object.hdfs_jmx_config.*.key
  //  [for
  //  i
  //in aws_s3_bucket_object.hdfs_jmx_config]
  //  jmx_configs_s3_paths = formatlist("s3://${aws_s3_bucket_object.hdfs_jmx_config.0.bucket}/%s", local.hdfs_jmx_configs)


}

resource "aws_emr_cluster" "emr" {
  name          = var.emr_name
  release_label = var.emr_release_label
  service_role  = var.emr_service_role_arn
  applications  = ["Spark", "Hadoop", "Flink"]

  ec2_attributes {
    subnet_id                         = var.subnet_id
    emr_managed_master_security_group = aws_security_group.master.id
    emr_managed_slave_security_group  = aws_security_group.node.id
    instance_profile                  = var.emr_ec2_instance_profile_arn
    key_name                          = var.ec2_ssh_key_name
  }
  log_uri = "s3://${var.emr_s3_staging_bucket}/emr/logs/"

  master_instance_group {
    name          = "Master Group"
    instance_type = var.emr_master_ec2_instance_type
    bid_price     = var.bid_price
  }

  core_instance_group {
    name           = "Core Group"
    instance_type  = var.emr_core_ec2_instance_type
    instance_count = var.emr_core_ec2_instance_count
    bid_price      = var.bid_price
  }

  bootstrap_action {
    name = "Configure cluster"
    path = "s3://${aws_s3_bucket_object.bootstrap_script.bucket}/${aws_s3_bucket_object.bootstrap_script.key}"
    args = concat([var.prometheus_node_exporter_version,
      var.prometheus_jmx_exporter_version,
      "s3://${aws_s3_bucket_object.node_exporter_service.bucket}/${aws_s3_bucket_object.node_exporter_service.key}",
      "s3://${aws_s3_bucket_object.after_provision_action.bucket}/${aws_s3_bucket_object.after_provision_action.key}"],
    local.jmx_configs_s3_paths
    )
  }

  configurations_json = <<EOF
[
  {
    "Classification": "flink-conf",
    "Properties": {
      "metrics.reporter.prom.class": "org.apache.flink.metrics.prometheus.PrometheusReporter",
      "metrics.reporter.prom.port": "9249"
    }
  }
]
EOF

  tags = var.tags
}

