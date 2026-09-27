#!/bin/bash

# AWS region
export AWS_REGION="ap-southeast-1"

# Lambda function and IAM role names
export FUNCTION_NAME="aws-cli-file-notification-lambda"
export ROLE_NAME="aws-cli-file-notification-lambda-role"

# SNS topic name
export TOPIC_NAME="aws-cli-file-notification-topic"

# Create Lambda deployment package
cd lambda
zip -j ../lambda-function.zip lambda_function.py
cd ..

# Get the IAM role ARN
export ROLE_ARN=$(aws iam get-role \
  --role-name "$ROLE_NAME" \
  --query 'Role.Arn' \
  --output text)

# Get the SNS topic ARN
export TOPIC_ARN=$(aws sns list-topics \
  --region "$AWS_REGION" \
  --query "Topics[?contains(TopicArn, ':$TOPIC_NAME')].TopicArn | [0]" \
  --output text)

# Create the Lambda function
aws lambda create-function \
  --function-name "$FUNCTION_NAME" \
  --runtime python3.13 \
  --role "$ROLE_ARN" \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://lambda-function.zip \
  --timeout 30 \
  --memory-size 128 \
  --environment "Variables={SNS_TOPIC_ARN=$TOPIC_ARN}" \
  --region "$AWS_REGION"

# Remove the local deployment package after deployment
rm -f lambda-function.zip
