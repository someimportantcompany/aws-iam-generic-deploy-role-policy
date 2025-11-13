# aws-iam-generic-roles » generic-integration-test-role

This is an IAM policy & role for integration tests. The idea is within non-prod AWS accounts, you can have a single
role that all integration tests across all applications/services use, to access AWS services but not manage
infrastructure.

**Note:** This is not recommended if you have both prod & non-prod in the same AWS account, as this policy/role would
grant access to production resources too.

## Deployment

```sh
$ aws cloudformation deploy \
  --stack-name someimportantcompany-generic-integration-test-role-policy \
  --template-file ./generic-test-roles.yml \
  --parameter-overrides PolicyName=generic-integration-test-policy RoleName=generic-integration-test-role \
  --capabilities CAPABILITY_NAMED_IAM
```

**Parameters**

| Parameter | Description |
| ---- | ---- |
| `PolicyName` | (**Required**) The name of the integration test policy to create |
| `RoleName` | (Optional) Set the integration test role name to automatically create it |

- Note: The Role is optional in this Cloudformation stack, as you may wish to create your own role
  (e.g. to [assume the role with GitHub OIDC](https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/)
  or other means)

## Supported AWS services

- API-Gateway
- App Config
- AppSync
- Athena
- Cloudfront
- Cloudwatch (including Logs & Metrics)
- Cognito
- DocumentDB
- DynamoDB
- ElastiCache
- ECR
- EventBridge
- Glue
- Kinesis
- KMS
- Lambda
- Opensearch
- Parameter Store
- RDS
- S3
- Secrets Manager
- SES
- SNS
- SQS
- Step Functions
