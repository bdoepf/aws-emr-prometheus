locals {
  bootstrap_script_path   = "scripts/bootstrap_monitoring_6_series.sh"
  after_provision_action  = "scripts/after_provision_action.sh"
  node_exporter_path      = "services/node_exporter.service"
  hdfs_jmx_directory      = "jmx_exporter_yaml"
  hdfs_jmx_configs        = ["hdfs_jmx_config_datanode.yaml",
    "hdfs_jmx_config_namenode.yaml",
    "yarn_jmx_config_node_manager.yaml",
    "yarn_jmx_config_resource_manager.yaml"]
}

resource "aws_s3_bucket_object" "after_provision_action" {
  bucket = var.emr_s3_staging_bucket
  key    = "${var.emr_s3_staging_key}/${local.after_provision_action}"
  source = "${path.module}/${local.after_provision_action}"
  etag   = filemd5("${path.module}/${local.after_provision_action}")
  tags   = var.tags
}

resource "aws_s3_bucket_object" "bootstrap_script" {
  bucket = var.emr_s3_staging_bucket
  key    = "${var.emr_s3_staging_key}/${local.bootstrap_script_path}"
  source = "${path.module}/${local.bootstrap_script_path}"
  etag   = filemd5("${path.module}/${local.bootstrap_script_path}")
  tags   = var.tags
}

resource "aws_s3_bucket_object" "node_exporter_service" {
  bucket = var.emr_s3_staging_bucket
  key    = "${var.emr_s3_staging_key}/${local.node_exporter_path}"
  source = "${path.module}/${local.node_exporter_path}"
  etag   = filemd5("${path.module}/${local.node_exporter_path}")
  tags   = var.tags
}

resource "aws_s3_bucket_object" "hdfs_jmx_config" {
  count  = length(local.hdfs_jmx_configs)
  bucket = var.emr_s3_staging_bucket
  key    = "${var.emr_s3_staging_key}/${local.hdfs_jmx_directory}/${local.hdfs_jmx_configs[count.index]}"
  source = "${path.module}/${local.hdfs_jmx_directory}/${local.hdfs_jmx_configs[count.index]}"
  etag   = filemd5("${path.module}/${local.hdfs_jmx_directory}/${local.hdfs_jmx_configs[count.index]}")
  tags   = var.tags
}
