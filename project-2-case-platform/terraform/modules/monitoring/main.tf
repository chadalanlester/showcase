resource "aws_instance" "monitoring" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.security_group_id]

  tags = {
    Name = "acme-monitoring"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt update
              apt install -y wget tar unzip curl gnupg2 software-properties-common apt-transport-https

              # Install Prometheus
              useradd --no-create-home --shell /bin/false prometheus
              mkdir /etc/prometheus /var/lib/prometheus
              cd /opt
              wget https://github.com/prometheus/prometheus/releases/download/v2.52.0/prometheus-2.52.0.linux-amd64.tar.gz
              tar -xvf prometheus-2.52.0.linux-amd64.tar.gz
              cp prometheus-2.52.0.linux-amd64/prometheus /usr/local/bin/
              cp prometheus-2.52.0.linux-amd64/promtool /usr/local/bin/
              cp -r prometheus-2.52.0.linux-amd64/consoles /etc/prometheus
              cp -r prometheus-2.52.0.linux-amd64/console_libraries /etc/prometheus

              cat <<EOF2 > /etc/prometheus/prometheus.yml
              global:
                scrape_interval: 15s
              scrape_configs:
                - job_name: 'node'
                  static_configs:
                    - targets: ["${var.nginx_private_ip}:9100"]
              EOF2

              chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

              cat <<EOF2 > /etc/systemd/system/prometheus.service
              [Unit]
              Description=Prometheus
              Wants=network-online.target
              After=network-online.target

              [Service]
              User=prometheus
              ExecStart=/usr/local/bin/prometheus \\
                --config.file=/etc/prometheus/prometheus.yml \\
                --storage.tsdb.path=/var/lib/prometheus \\
                --web.console.templates=/etc/prometheus/consoles \\
                --web.console.libraries=/etc/prometheus/console_libraries

              [Install]
              WantedBy=multi-user.target
              EOF2

              systemctl daemon-reload
              systemctl start prometheus
              systemctl enable prometheus
              EOF
}
