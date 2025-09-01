#!/bin/bash
# cloud-init for monitoring instance

# Install Docker
apt-get update -y
apt-get install -y docker.io

# Start Docker and enable on boot
systemctl start docker
systemctl enable docker

# Create Prometheus config
mkdir -p /opt/prometheus

cat <<EOF > /opt/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'nginx_exporter'
    static_configs:
      - targets: ['${nginx_private_ip}:9113']
EOF

# Run Node Exporter
docker run -d \
  --name node-exporter \
  -p 9100:9100 \
  quay.io/prometheus/node-exporter:latest

# Run Prometheus with custom config
docker run -d \
  --name prometheus \
  -p 9090:9090 \
  -v /opt/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus:latest

