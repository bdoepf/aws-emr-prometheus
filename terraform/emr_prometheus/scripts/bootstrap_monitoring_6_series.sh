#!/bin/bash -xe

NODE_EXPORTER_VERSION="${1}"
JMX_PROMETHEUS_VERSION="${2}"
NODE_EXPORTER_SERVICE_S3_PATH="${3}"
AFTER_PROVISION_ACTION_S3_PATH="${4}"
HDFS_JMX_CONFIG_S3_PATH_1="${5}"
HDFS_JMX_CONFIG_S3_PATH_2="${6}"
HDFS_JMX_CONFIG_S3_PATH_3="${7}"
HDFS_JMX_CONFIG_S3_PATH_4="${8}"

#set up node_exporter for pushing OS level metrics
sudo useradd --no-create-home --shell /bin/false node_exporter
cd /tmp
ARCHITECTURE=$(uname -m)
if [[ "${ARCHITECTURE}" == "aarch64" ]]; then
  BINARY_COMPILATION="linux-arm64"
else
  BINARY_COMPILATION="linux-amd64"
fi
echo "Using BINARY_COMPILATION=${BINARY_COMPILATION}"
wget "https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.${BINARY_COMPILATION}.tar.gz"
tar -xvzf "node_exporter-${NODE_EXPORTER_VERSION}.${BINARY_COMPILATION}.tar.gz"
cd "node_exporter-${NODE_EXPORTER_VERSION}.${BINARY_COMPILATION}"
sudo cp node_exporter /usr/local/bin/
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

cd /tmp
aws s3 cp "${NODE_EXPORTER_SERVICE_S3_PATH}" node_exporter.service
sudo cp node_exporter.service /etc/systemd/system/node_exporter.service
sudo chown node_exporter:node_exporter /etc/systemd/system/node_exporter.service
sudo systemctl daemon-reload && \
sudo systemctl start node_exporter && \
sudo systemctl status node_exporter && \
sudo systemctl enable node_exporter

#set up jmx_exporter for pushing application metrics
wget "https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${JMX_PROMETHEUS_VERSION}/jmx_prometheus_javaagent-${JMX_PROMETHEUS_VERSION}.jar"
sudo mkdir /etc/prometheus
sudo cp "jmx_prometheus_javaagent-${JMX_PROMETHEUS_VERSION}.jar" /etc/prometheus

aws s3 cp "${HDFS_JMX_CONFIG_S3_PATH_1}" .
aws s3 cp "${HDFS_JMX_CONFIG_S3_PATH_2}" .
aws s3 cp "${HDFS_JMX_CONFIG_S3_PATH_3}" .
aws s3 cp "${HDFS_JMX_CONFIG_S3_PATH_4}" .

HADOOP_CONF='/etc/hadoop/conf'
sudo mkdir -p ${HADOOP_CONF}
sudo cp hdfs_jmx_config_namenode.yaml ${HADOOP_CONF}
sudo cp hdfs_jmx_config_datanode.yaml ${HADOOP_CONF}
sudo cp yarn_jmx_config_resource_manager.yaml ${HADOOP_CONF}
sudo cp yarn_jmx_config_node_manager.yaml ${HADOOP_CONF}

# set up after_provision_action.sh script to be executed after applications are provisioned. This is needed so as to set up jmx exporter for some applications.
cd /tmp
aws s3 cp "${AFTER_PROVISION_ACTION_S3_PATH}" after_provision_action.sh
sudo chmod +x /tmp/after_provision_action.sh
sudo sed "s/null &/null \&\& \/tmp\/after_provision_action.sh ${JMX_PROMETHEUS_VERSION} >> \$STDOUT_LOG 2>> \$STDERR_LOG \&\n/" /usr/share/aws/emr/node-provisioner/bin/provision-node > /tmp/provision-node.new
sudo cp /tmp/provision-node.new /usr/share/aws/emr/node-provisioner/bin/provision-node

exit 0
