# Runbook: transaction-api
## Diagnose
1) `ibmcloud ce application get -n transaction-api`
2) `ibmcloud ce application events -n transaction-api`
3) `ibmcloud ce application logs -a transaction-api --tail 200`
## Roll forward
1) Push commit to main and let Actions deploy.
## Roll back
1) `ibmcloud ce application revisions -a transaction-api`
2) `ibmcloud ce application set-revision -a transaction-api --revision <REV> --traffic 100`
## Scale to zero temporarily
`ibmcloud ce application update -n transaction-api --min-scale 0`
