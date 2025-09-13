# Monitoring Strategy
- Availability: EC2 `StatusCheckFailed` alarm.
- Performance: `CPUUtilization` > 80% for 5m.
- Black-box: Lambda HTTP 200 to `/` every 5 minutes.
- Notify via SNS.
