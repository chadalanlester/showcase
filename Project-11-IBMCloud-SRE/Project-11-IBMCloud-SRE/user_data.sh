#!/bin/bash

# Install Docker
apt-get update -y
apt-get install -y docker.io

# Enable Docker
systemctl enable docker
systemctl start docker

# Create custom HTML page
mkdir -p /opt/nginx/html
cat <<EOF > /opt/nginx/html/index.html
<!DOCTYPE html>
<html>
  <head>
    <title>Acme SRE Challenge</title>
  </head>
  <body>
    <h1>Success! This NGINX server was deployed via Terraform + Cloud-Init + Docker</h1>
    <p>Chad Lester - July 2025</p>
  </body>
</html>
EOF

# Create stub_status.conf
mkdir -p /opt/nginx/conf.d
cat <<EOF > /opt/nginx/conf.d/stub_status.conf
server {
  listen 80;

  location / {
    root /usr/share/nginx/html;
    index index.html;
  }

  location /stub_status {
    stub_status;
    allow all;
  }
}
EOF

# Run NGINX container with mounted HTML and config
docker run -d --name nginx -p 80:80 \
  -v /opt/nginx/html:/usr/share/nginx/html \
  -v /opt/nginx/conf.d:/etc/nginx/conf.d \
  nginx:latest

# Run Node Exporter
docker run -d --name node-exporter -p 9100:9100 \
  --restart unless-stopped \
  prom/node-exporter

# Run NGINX Exporter
docker run -d --name nginx-exporter -p 9113:9113 \
  --link nginx \
  nginx/nginx-prometheus-exporter:latest \
  -nginx.scrape-uri http://nginx/stub_status
