#!/bin/bash -xe

#install Grafana
cd /tmp
wget -nv https://dl.grafana.com/oss/release/grafana-7.1.1-1.x86_64.rpm
sudo yum -y install grafana-7.1.1-1.x86_64.rpm

sudo mkdir -p /etc/grafana/provisioning/datasources
sudo cp /tmp/grafana_prometheus_datasource.yaml /etc/grafana/provisioning/datasources/prometheus.yaml

sudo mkdir -p /etc/grafana/provisioning/dashboards
sudo cp /tmp/grafana_dashboard.yaml /etc/grafana/provisioning/dashboards/default.yaml

sudo mkdir -p /var/lib/grafana/dashboards

sudo cp /tmp/dashboards/* /var/lib/grafana/dashboards/
sudo chown -R grafana:grafana /var/lib/grafana

#configure Grafana as a service
sudo systemctl daemon-reload
sudo systemctl start grafana-server
sudo systemctl status grafana-server
sudo systemctl enable grafana-server