#!/bin/bash -xe

if [ $# -eq 0 ];then
    echo "No argument supplied. Require JMX_PROMETHEUS_VERSION as first parameter"
    exit 1
fi

JMX_PROMETHEUS_VERSION="${1}"

function setup_jmx_exporter_resource_manager() {
  # Add prometheus JMX exporter for ResourceManager (configure in yarn-env.sh)
  cat << EOF | sudo tee -a /etc/hadoop/conf/yarn-env.sh

if [[ \$YARN_RESOURCEMANAGER_OPTS != *"jmx_prometheus_javaagent"* ]]; then
    export YARN_RESOURCEMANAGER_OPTS="\${YARN_RESOURCEMANAGER_OPTS} -javaagent:/etc/prometheus/jmx_prometheus_javaagent-${JMX_PROMETHEUS_VERSION}.jar=7005:/etc/hadoop/conf/yarn_jmx_config_resource_manager.yaml -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=50111"
fi
EOF
  sudo systemctl restart hadoop-yarn-resourcemanager.service
}

function setup_jmx_exporter_node_manager() {
  # Add prometheus JMX exporter for NodeManager (configure in yarn-env.sh)
  cat << EOF | sudo tee -a /etc/hadoop/conf/yarn-env.sh

if [[ \${YARN_NODEMANAGER_OPTS} != *"jmx_prometheus_javaagent"* ]]; then
    export YARN_NODEMANAGER_OPTS="\${YARN_NODEMANAGER_OPTS} -javaagent:/etc/prometheus/jmx_prometheus_javaagent-${JMX_PROMETHEUS_VERSION}.jar=7005:/etc/hadoop/conf/yarn_jmx_config_node_manager.yaml -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=50111"
fi
EOF
  sudo systemctl restart hadoop-yarn-nodemanager.service
}

function setup_jmx_exporter_name_node() {
  # Add prometheus JMX exporter for NameNode (configure in hadoop-env.sh)
  cat << EOF | sudo tee -a /etc/hadoop/conf/hadoop-env.sh

if [[ \$HADOOP_NAMENODE_OPTS != *"jmx_prometheus_javaagent"* ]]; then
    export HADOOP_NAMENODE_OPTS="\${HADOOP_NAMENODE_OPTS} -javaagent:/etc/prometheus/jmx_prometheus_javaagent-${JMX_PROMETHEUS_VERSION}.jar=7001:/etc/hadoop/conf/hdfs_jmx_config_namenode.yaml -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=50103"
fi
EOF
  sudo systemctl restart hadoop-hdfs-namenode.service
}

function setup_jmx_exporter_data_node() {
  # Add prometheus JMX exporter for DataNode (configure in hadoop-env.sh)
  cat << EOF | sudo tee -a /etc/hadoop/conf/hadoop-env.sh

if [[ \$HADOOP_DATANODE_OPTS != *"jmx_prometheus_javaagent"* ]]; then
    export HADOOP_DATANODE_OPTS="\${HADOOP_DATANODE_OPTS} -javaagent:/etc/prometheus/jmx_prometheus_javaagent-${JMX_PROMETHEUS_VERSION}.jar=7001:/etc/hadoop/conf/hdfs_jmx_config_datanode.yaml -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=50103"
fi
EOF
  sudo systemctl restart hadoop-hdfs-datanode.service
}

function main() {
  # Find applications installed
  APPLICATIONS_INSTALLED=$(CLUSTER_ID=$(cat /mnt/var/lib/info/extraInstanceData.json | jq -r ".jobFlowId"); REGION=$(cat /mnt/var/lib/info/extraInstanceData.json | jq -r ".region"); aws emr describe-cluster --cluster-id $CLUSTER_ID --region $REGION | jq -r ".Cluster.Applications[].Name")

  # Is empty if not master
  IS_MASTER=$(cat /mnt/var/lib/info/instance.json | jq -r ".isMaster" | grep "true" || true);

  # Is empty if no hadoop is installed
  IS_HADOOP_INSTALLED=$(echo "${APPLICATIONS_INSTALLED}" | grep "Hadoop" || true);

  if [ ! -z $IS_HADOOP_INSTALLED ]; then
    if [ ! -z $IS_MASTER ]; then
      setup_jmx_exporter_resource_manager;
      setup_jmx_exporter_name_node;
    else
      setup_jmx_exporter_node_manager;
      setup_jmx_exporter_data_node;
    fi;
  fi;
}

main
