#!/bin/bash

# AWS region
export AWS_REGION="ap-southeast-1"

# SQS queue name
export QUEUE_NAME="aws-cli-file-notification-queue"

# Create the SQS queue
aws sqs create-queue \
  --queue-name "$QUEUE_NAME" \
  --region "$AWS_REGION"

# Get the queue URL
export QUEUE_URL=$(aws sqs get-queue-url \
  --queue-name "$QUEUE_NAME" \
  --region "$AWS_REGION" \
  --query 'QueueUrl' \
  --output text)

# Prepare the S3 file message
MESSAGE='{"bucket":"aws-cli-file-pipeline-abdullah-2026","key":"sample.txt"}'

# Send the file details message to SQS
aws sqs send-message \
  --queue-url "$QUEUE_URL" \
  --message-body "$MESSAGE" \
  --region "$AWS_REGION"

# Verify the queue URL
echo "Queue URL: $QUEUE_URL"
