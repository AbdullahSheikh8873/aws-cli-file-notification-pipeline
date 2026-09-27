#!/bin/bash

# AWS region
export AWS_REGION="ap-southeast-1"

# Resource names
export BUCKET_NAME="aws-cli-file-pipeline-abdullah-2026"
export QUEUE_NAME="aws-cli-file-notification-queue"
export TOPIC_NAME="aws-cli-file-notification-topic"
export FUNCTION_NAME="aws-cli-file-notification-lambda"

# IAM names
export ROLE_NAME="aws-cli-file-notification-lambda-role"
export POLICY_NAME="aws-cli-file-notification-lambda-policy"

# CloudWatch Logs group
export LOG_GROUP_NAME="/aws/lambda/$FUNCTION_NAME"

# Get SQS queue URL
export QUEUE_URL=$(aws sqs get-queue-url \
  --queue-name "$QUEUE_NAME" \
  --region "$AWS_REGION" \
  --query 'QueueUrl' \
  --output text)

# Get SQS queue ARN
export QUEUE_ARN=$(aws sqs get-queue-attributes \
  --queue-url "$QUEUE_URL" \
  --attribute-names QueueArn \
  --region "$AWS_REGION" \
  --query 'Attributes.QueueArn' \
  --output text)

# Get SNS topic ARN
export TOPIC_ARN=$(aws sns list-topics \
  --region "$AWS_REGION" \
  --query "Topics[?contains(TopicArn, ':$TOPIC_NAME')].TopicArn | [0]" \
  --output text)

# Get Lambda event source mappings
export EVENT_SOURCE_UUID=$(aws lambda list-event-source-mappings \
  --function-name "$FUNCTION_NAME" \
  --event-source-arn "$QUEUE_ARN" \
  --region "$AWS_REGION" \
  --query 'EventSourceMappings[0].UUID' \
  --output text)

# Delete the SQS to Lambda event source mapping
aws lambda delete-event-source-mapping \
  --uuid "$EVENT_SOURCE_UUID" \
  --region "$AWS_REGION"

# Delete the Lambda function
aws lambda delete-function \
  --function-name "$FUNCTION_NAME" \
  --region "$AWS_REGION"

# Delete the IAM inline policy
aws iam delete-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-name "$POLICY_NAME"

# Delete the IAM role
aws iam delete-role \
  --role-name "$ROLE_NAME"

# Delete the CloudWatch Logs group
aws logs delete-log-group \
  --log-group-name "$LOG_GROUP_NAME" \
  --region "$AWS_REGION"

# Delete the SNS topic
aws sns delete-topic \
  --topic-arn "$TOPIC_ARN" \
  --region "$AWS_REGION"

# Delete the SQS queue
aws sqs delete-queue \
  --queue-url "$QUEUE_URL" \
  --region "$AWS_REGION"

# Delete the S3 object
aws s3 rm "s3://$BUCKET_NAME/sample.txt"

# Delete the S3 bucket
aws s3 rb "s3://$BUCKET_NAME"
