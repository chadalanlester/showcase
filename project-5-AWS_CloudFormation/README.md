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
