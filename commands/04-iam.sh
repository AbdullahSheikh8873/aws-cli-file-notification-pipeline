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

# Get AWS account ID dynamically
export ACCOUNT_ID=$(aws sts get-caller-identity \
  --query 'Account' \
  --output text)

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

# Build the least-privilege IAM permissions policy
cat > /tmp/lambda-permissions-policy.json <<EOF2
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3ReadObject",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::$BUCKET_NAME/sample.txt"
    },
    {
      "Sid": "SQSReceiveDelete",
      "Effect": "Allow",
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      "Resource": "$QUEUE_ARN"
    },
    {
      "Sid": "SNSPublish",
      "Effect": "Allow",
      "Action": [
        "sns:Publish"
      ],
      "Resource": "$TOPIC_ARN"
    },
    {
      "Sid": "CloudWatchLogs",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:$AWS_REGION:$ACCOUNT_ID:log-group:$LOG_GROUP_NAME:*"
    }
  ]
}
EOF2

# Create the CloudWatch Logs group
aws logs create-log-group \
  --log-group-name "$LOG_GROUP_NAME" \
  --region "$AWS_REGION"

# Create the IAM role using the Lambda trust policy
aws iam create-role \
  --role-name "$ROLE_NAME" \
  --assume-role-policy-document file://iam/lambda-trust-policy.json

# Attach the least-privilege Lambda permissions policy
aws iam put-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-name "$POLICY_NAME" \
  --policy-document file:///tmp/lambda-permissions-policy.json

# Verify the IAM role
aws iam get-role \
  --role-name "$ROLE_NAME"

# Verify the inline permissions policy
aws iam get-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-name "$POLICY_NAME"
