#!/bin/bash

# AWS region
export AWS_REGION="ap-southeast-1"

# Resource names
export QUEUE_NAME="aws-cli-file-notification-queue"
export FUNCTION_NAME="aws-cli-file-notification-lambda"

# Get the SQS queue URL
export QUEUE_URL=$(aws sqs get-queue-url \
  --queue-name "$QUEUE_NAME" \
  --region "$AWS_REGION" \
  --query 'QueueUrl' \
  --output text)

# Get the SQS queue ARN
export QUEUE_ARN=$(aws sqs get-queue-attributes \
  --queue-url "$QUEUE_URL" \
  --attribute-names QueueArn \
  --region "$AWS_REGION" \
  --query 'Attributes.QueueArn' \
  --output text)

# Connect SQS to Lambda
aws lambda create-event-source-mapping \
  --function-name "$FUNCTION_NAME" \
  --event-source-arn "$QUEUE_ARN" \
  --batch-size 1 \
  --enabled \
  --region "$AWS_REGION"

# Verify the event source mapping
aws lambda list-event-source-mappings \
  --function-name "$FUNCTION_NAME" \
  --event-source-arn "$QUEUE_ARN" \
  --region "$AWS_REGION"
