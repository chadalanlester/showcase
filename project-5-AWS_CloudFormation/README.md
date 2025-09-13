# project-5-AWS_CloudFormation
Free-tier SRE/DevSecOps showcase using CloudFormation, Lambda, EC2, CloudWatch, EventBridge, and SNS.

## Deploy
REGION=us-east-1
STACK_NAME=project-5-AWS_CloudFormation
aws cloudformation deploy \
  --template-file cfn/main.yaml \
  --stack-name $STACK_NAME \
  --parameter-overrides file://cfn/parameters.example.json \
  --capabilities CAPABILITY_NAMED_IAM \
  --region $REGION

## Teardown
aws cloudformation delete-stack --stack-name project-5-AWS_CloudFormation --region us-east-1

## Verification evidence

- Stack: `project-5-AWS-CloudFormation` in `us-east-1`
- Instance: `i-05612049e6e8b84db`, Public IP: `35.173.36.148`
- SNS Topic: `arn:aws:sns:us-east-1:565092613177:project-5-AWS_CloudFormation-alerts`

### Health
```bash
curl -I http://35.173.36.148/
```

### Lambda on-demand check
```bash
aws lambda invoke --function-name project-5-AWS-CloudFormation_healthcheck --region us-east-1 /dev/stdout | jq .
```

### Alarms present
```bash
aws cloudformation list-stack-resources --stack-name project-5-AWS-CloudFormation --region us-east-1 \
  --query "StackResourceSummaries[?ResourceType=='AWS::CloudWatch::Alarm'].[LogicalResourceId,PhysicalResourceId]" --output table
```

### SNS test
```bash
aws sns publish --region us-east-1 --topic-arn arn:aws:sns:us-east-1:565092613177:project-5-AWS_CloudFormation-alerts --subject "SNS test" --message "OK"
```
