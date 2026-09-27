#!/bin/bash

# AWS region
export AWS_REGION="ap-southeast-1"

# Resource names
export BUCKET_NAME="aws-cli-file-pipeline-abdullah-2026"
export QUEUE_NAME="aws-cli-file-notification-queue"
export FUNCTION_NAME="aws-cli-file-notification-lambda"

# Get the SQS queue URL
export QUEUE_URL=$(aws sqs get-queue-url \
  --queue-name "$QUEUE_NAME" \
  --region "$AWS_REGION" \
  --query 'QueueUrl' \
  --output text)

# Prepare the S3 file message
MESSAGE="{\"bucket\":\"$BUCKET_NAME\",\"key\":\"sample.txt\"}"

# Send the file details to SQS
aws sqs send-message \
  --queue-url "$QUEUE_URL" \
  --message-body "$MESSAGE" \
  --region "$AWS_REGION"

# Wait briefly for Lambda to process the message
sleep 10

# Check the SQS queue for remaining messages
aws sqs get-queue-attributes \
  --queue-url "$QUEUE_URL" \
  --attribute-names ApproximateNumberOfMessages \
  --region "$AWS_REGION"

# Check Lambda CloudWatch Logs
export LOG_GROUP_NAME="/aws/lambda/$FUNCTION_NAME"

aws logs tail "$LOG_GROUP_NAME" \
  --since 10m \
  --region "$AWS_REGION"
