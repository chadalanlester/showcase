# HealthCheck Lambda
Checks EC2 status checks and optional HTTP 200 on the instance. On failure, publishes SNS and reboots. Python 3.11, stdlib only. Config via env vars from CloudFormation.
