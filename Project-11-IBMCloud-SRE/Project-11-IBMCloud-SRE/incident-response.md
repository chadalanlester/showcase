# Incident Response
- On StatusCheckFailed: Reboot happens automatically. If >10m, stop/start or redeploy.
- On HTTP fail with OK status checks: inspect nginx; consider SSM RunCommand.
- On CPU high: inspect workload; document and iterate.
