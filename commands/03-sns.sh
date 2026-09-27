#!/bin/bash

# AWS region
export AWS_REGION="ap-southeast-1"

# SNS topic name
export TOPIC_NAME="aws-cli-file-notification-topic"

# Create the SNS topic
export TOPIC_ARN=$(aws sns create-topic \
  --name "$TOPIC_NAME" \
  --region "$AWS_REGION" \
  --query 'TopicArn' \
  --output text)

# Add your email subscription
# Replace YOUR_EMAIL@example.com with your own email address.
aws sns subscribe \
  --topic-arn "$TOPIC_ARN" \
  --protocol email \
  --notification-endpoint "YOUR_EMAIL@example.com" \
  --region "$AWS_REGION"

# List subscriptions to verify the subscription
aws sns list-subscriptions-by-topic \
  --topic-arn "$TOPIC_ARN" \
  --region "$AWS_REGION"
