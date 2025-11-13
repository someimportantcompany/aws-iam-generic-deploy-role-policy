#!/bin/bash

REPO="$( cd -- "$(dirname "$0")/" >/dev/null 2>&1 ; pwd -P )"
cd $REPO

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

if [ ! -f ./.env.default ]; then
  printf "[ERROR]: Missing ./.env.default\n" 1>&2
  exit 1
fi

echo "Found: .env.default"
source ./.env.default

if [ -f ./.env.user ]; then
  echo "Found: .env.user"
  source ./.env.user
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
throw_err "$?" "Failed to run: aws sts get-caller-identity"
printf "\n"

terraform init
throw_err "$?" "Failed to run: terraform init"
printf "\n"

terraform test
throw_err "$?" "Failed to run: terraform test"
