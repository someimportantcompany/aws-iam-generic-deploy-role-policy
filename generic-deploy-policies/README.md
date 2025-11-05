# aws-iam-generic-roles » generic-deploy-policy

A collection of IAM policies for you to build your own deployment roles, available as a single Cloudformation template
for ease-of-use.

## How does this work?

This Cloudformation template is a collection of deployment policies for you to attach to a role for deploying
applications/services. It relies on **a handful of tags** to be added to your role, which act as guard rails ensuring
that one deploy role cannot interact with resources outside of its scope.

There are two important ways these deployment policies work:

1. Resources with names in ARNs:
  - Foo
  - Bar
  - Baz

2. Resources with IDs in ARNs:
  - Foo
  - Bar
  - Baz

## Supported AWS Services

| Service | Supported | Notes |
| ---- | ---- | ---- |
| `lambda` | Yes | |

## Deployment

```sh
$ aws cloudformation deploy \
  --stack-name someimportantcompany-generic-deploy-policies \
  --template-file ./generic-deploy-policies.yml \
  --capabilities CAPABILITY_NAMED_IAM
```

Next, create a new role & add the following tags:

```yml
- Key: DeployNamePrefix
  Value: test- # This will be used as "test-*" in policy statements
  # E.g. example-application- → example-application-*

- Key: DeployTagKey
  Value: Application
- Key: DeployTagValue
  Value: example-application
```
