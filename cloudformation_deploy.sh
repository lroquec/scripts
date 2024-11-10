#!/usr/bin/env bash

echo "deploying template..."

aws cloudformation deploy --template-file template.yaml --stack-name my-flask-pipeline-stack --no-execute-changeset --capabilities CAPABILITY_NAMED_IAM