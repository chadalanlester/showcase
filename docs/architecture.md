# Architecture
- Code Engine app (autoscale 0..5), image in ICR namespace `sre-showcase`.
- COS buckets: `proj11-sre-bucket`, `proj11-tfstate`.
- Secrets Manager for future app secrets.
- Sysdig Monitoring (lite) for metrics.
