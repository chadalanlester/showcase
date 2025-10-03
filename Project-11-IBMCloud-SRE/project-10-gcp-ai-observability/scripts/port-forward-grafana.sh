# showcase/project-10-gcp-ai-observability/scripts/port-forward-grafana.sh
#!/usr/bin/env bash
set -euo pipefail
NS=monitoring
echo "Grafana admin password (if using Terraform default):"
kubectl -n "$NS" get secret grafana-admin-credentials -o jsonpath='{.data.admin-password}' | base64 -d; echo
echo "Port-forwarding Grafana to localhost:3000"
kubectl -n "$NS" port-forward svc/kube-prom-stack-grafana 3000:80
```

````bash
