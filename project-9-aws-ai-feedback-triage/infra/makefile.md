PROJECT?=ai-feedback-triage
REGION?=us-east-1
ALERT_EMAIL?=you@example.com

init:
	terraform fmt -recursive
	terraform init -upgrade

plan:
	terraform validate
	terraform plan -var alert_email="$(ALERT_EMAIL)" -out tfplan

apply:
	terraform apply "tfplan"

deploy: init plan apply

outputs:
	@echo API_URL=$$(terraform output -raw api_gateway_url)
	@echo TABLE=$$(terraform output -raw dynamodb_table)
	@echo BUCKET=$$(terraform output -raw s3_bucket_name)
	@echo TOPIC_ARN=$$(terraform output -raw alerts_topic_arn)

test-api:
	@API_URL=$$(terraform output -raw api_gateway_url); \
	curl -sS -X POST $$API_URL/feedback \
	  -H 'Content-Type: application/json' \
	  -d '{"customer_id":"c777","channel":"api","text":"search quality is poor and results are wrong"}' | jq .

seed-csv:
	@BUCKET=$$(terraform output -raw s3_bucket_name); \
	printf "customer_id,channel,text\nc234,csv,absolutely love the new onboarding flow\nc345,csv,this release broke search; results are wrong and slow\n" > sample.csv; \
	aws --region $(REGION) s3 cp sample.csv s3://$$BUCKET/incoming/sample.csv

query-dynamodb:
	@TABLE=$$(terraform output -raw dynamodb_table); \
	aws --region $(REGION) dynamodb query \
	 --table-name $$TABLE \
	 --key-condition-expression 'pk = :p' \
	 --expression-attribute-values '{":p":{"S":"cust#c345"}}' | jq '.Count,.Items[0]'

sns-subs:
	@TOPIC_ARN=$$(terraform output -raw alerts_topic_arn); \
	aws --region $(REGION) sns list-subscriptions-by-topic --topic-arn $$TOPIC_ARN --query 'Subscriptions[].SubscriptionArn'

tail-logs:
	aws --region $(REGION) logs tail '/aws/lambda/$(PROJECT)-ingest-api' --follow

destroy:
	terraform destroy -auto-approve
