# Project 11 – IBM Cloud SRE Showcase
Stack: Code Engine (free), IBM Cloud Container Registry, COS (lite), Secrets Manager (trial), Sysdig (lite).
Quickstart:
1) `ibmcloud login -r us-south -g "Default" --apikey "$IBMCLOUD_API_KEY"`
2) `docker buildx build --platform linux/amd64 -t us.icr.io/sre-showcase/transaction-api:dev ./app --push`
3) `ibmcloud ce project select -n proj11-sre-ce`
4) `ibmcloud ce application update --name transaction-api --image us.icr.io/sre-showcase/transaction-api:dev --registry-secret icr-secret`
5) `curl -fsS "$(ibmcloud ce application get -n transaction-api --output json | jq -r '.status.url')/healthz"`
