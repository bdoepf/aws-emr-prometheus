#!/bin/bash -xe

#install Prometheus
sudo useradd --no-create-home --shell /bin/false prometheus
sudo mkdir -p /etc/prometheus/conf
sudo chown -R prometheus:prometheus /etc/prometheus
cd /tmp
wget -nv https://github.com/prometheus/prometheus/releases/download/v2.20.0/prometheus-2.20.0.linux-amd64.tar.gz
tar xvf prometheus-2.20.0.linux-amd64.tar.gz
cd prometheus-2.20.0.linux-amd64
sudo cp prometheus /usr/local/bin/
sudo cp promtool /usr/local/bin/
sudo cp tsdb /usr/local/bin/
sudo cp -r consoles /etc/prometheus
sudo cp -r console_libraries /etc/prometheus
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
sudo chown prometheus:prometheus /usr/local/bin/tsdb
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries

#configure Prometheus as a service
cd /tmp
EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed 's/[a-z]$//'`"
sudo sed "s/us-west-2/${EC2_REGION}/g" prometheus.yml | sudo tee /etc/prometheus/conf/prometheus.yml
sudo cp rules.yml /etc/prometheus/conf/rules.yml
sudo chown prometheus:prometheus /etc/prometheus/conf/prometheus.yml
sudo chown prometheus:prometheus /etc/prometheus/conf/rules.yml

sudo cp prometheus.service /etc/systemd/system/prometheus.service
sudo chown prometheus:prometheus /etc/systemd/system/prometheus.service
sudo mkdir -p /var/lib/prometheus
sudo chown -R prometheus:prometheus /var/lib/prometheus
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl status prometheus
sudo systemctl enable prometheus