#!/bin/bash

# AWS region
export AWS_REGION="ap-southeast-1"

# S3 bucket name
export BUCKET_NAME="aws-cli-file-pipeline-abdullah-2026"

# Create the S3 bucket
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$AWS_REGION" \
  --create-bucket-configuration LocationConstraint="$AWS_REGION"

# Create the sample file
echo "AWS CLI Event-Driven File Notification Pipeline" > sample.txt

# Upload the sample file to S3
aws s3 cp sample.txt "s3://$BUCKET_NAME/sample.txt"

# Verify the uploaded object
aws s3api head-object \
  --bucket "$BUCKET_NAME" \
  --key "sample.txt"
