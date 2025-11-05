#!/usr/bin/env bash
# Deploy these generic roles & policies to an AWS account

throw_err() {
  if [ "$1" -ne "0" ]; then
    printf "[ERROR]: $2\n" 1>&2
    exit "$1"
  fi
}

aws --version >/dev/null
throw_err "$?" "Missing CLI: aws"
terraform --version >/dev/null
throw_err "$?" "Missing CLI: terraform"

ARG_AWS_PROFILE=""
ARG_AWS_REGION=""
ARG_PREFIX="generic"
ARG_DESTROY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    "--profile") ARG_AWS_PROFILE="$2"; shift ;;
    "--region") ARG_AWS_REGION="$2"; shift ;;
    "--prefix") ARG_PREFIX="$2"; shift ;;
    "--destroy") ARG_DESTROY=true; shift ;;
  esac
  shift
done

if [[ -n "$ARG_AWS_PROFILE" ]]; then
  export AWS_PROFILE="$ARG_AWS_PROFILE"
fi
if [[ -n "$ARG_AWS_REGION" ]]; then
  export AWS_REGION="$ARG_AWS_REGION"
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
throw_err "$?" "Failed to run: aws sts get-caller-identity"

cd "$( cd -- "$(dirname "$0")/" >/dev/null 2>&1 ; pwd -P )"

if [ "$ARG_DESTROY" = "true" ]; then
  aws cloudformation delete-stack --stack-name $ARG_PREFIX-integration-test-role | cat
  throw_err "$?" "Failed: aws cloudformation delete-stack ($ARG_PREFIX-integration-test-role)"
  echo "[Deleted] $ARG_PREFIX-integration-test-role"

  aws cloudformation delete-stack --stack-name $ARG_PREFIX-execution-test-policies | cat
  throw_err "$?" "Failed: aws cloudformation delete-stack ($ARG_PREFIX-execution-test-policies)"
  echo "[Deleted] $ARG_PREFIX-execution-test-policies"

  aws cloudformation delete-stack --stack-name $ARG_PREFIX-deploy-test-role | cat
  throw_err "$?" "Failed: aws cloudformation delete-stack ($ARG_PREFIX-deploy-test-role)"
  echo "[Deleted] $ARG_PREFIX-deploy-test-role"

  aws cloudformation delete-stack --stack-name $ARG_PREFIX-deploy-policies | cat
  throw_err "$?" "Failed: aws cloudformation delete-stack ($ARG_PREFIX-deploy-policies)"
  echo "[Deleted] $ARG_PREFIX-deploy-policies"
else
  aws cloudformation deploy \
    --stack-name $ARG_PREFIX-deploy-policies \
    --template-file ../generic-deploy-policy/generic-deploy-policies.yml \
    --parameter-overrides PolicyPrefix=$ARG_PREFIX-deploy \
    --capabilities CAPABILITY_NAMED_IAM
  throw_err "$?" "Failed: aws cloudformation deploy ($ARG_PREFIX-deploy-policies)"

  aws cloudformation deploy \
    --stack-name $ARG_PREFIX-deploy-test-role \
    --template-file ../generic-deploy-policy/integration-tests/test-role.yml \
    --parameter-overrides RoleName=$ARG_PREFIX-deploy-test-role PolicyPrefix=$ARG_PREFIX-deploy \
      DeployNamePrefix=test- DeployTagKey=Application DeployTagValue=test \
    --capabilities CAPABILITY_NAMED_IAM
  throw_err "$?" "Failed: aws cloudformation deploy ($ARG_PREFIX-deploy-test-role)"

  aws cloudformation deploy \
    --stack-name $ARG_PREFIX-execution-test-policies \
    --template-file ../generic-execution-roles/generic-execution-roles.yml \
    --parameter-overrides RolePrefix=$ARG_PREFIX \
    --capabilities CAPABILITY_NAMED_IAM
  throw_err "$?" "Failed: aws cloudformation deploy ($ARG_PREFIX-execution-test-policies)"

  aws cloudformation deploy \
    --stack-name $ARG_PREFIX-integration-test-role \
    --template-file ../generic-integration-test-role/generic-test-roles.yml \
    --parameter-overrides PolicyName=$ARG_PREFIX-integration-test-policy RoleName=$ARG_PREFIX-integration-test-role \
    --capabilities CAPABILITY_NAMED_IAM
  throw_err "$?" "Failed: aws cloudformation deploy ($ARG_PREFIX-integration-test-role)"
fi
