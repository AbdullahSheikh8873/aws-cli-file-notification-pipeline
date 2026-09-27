import json
import logging
import os

import boto3


logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client("s3")
sns = boto3.client("sns")

SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]


def lambda_handler(event, context):
    for record in event["Records"]:
        try:
            # Read message from SQS
            message = json.loads(record["body"])

            bucket = message["bucket"]
            key = message["key"]

            logger.info(
                "Processing file: bucket=%s, key=%s",
                bucket,
                key
            )

            # Get file metadata from S3
            metadata = s3.head_object(
                Bucket=bucket,
                Key=key
            )

            file_name = key
            file_size = metadata["ContentLength"]
            content_type = metadata.get("ContentType", "unknown")
            last_modified = metadata["LastModified"].isoformat()
            etag = metadata["ETag"]
            storage_class = metadata.get("StorageClass", "STANDARD")

            # Prepare notification
            subject = f"File Uploaded: {file_name}"

            message_body = f"""File Notification

File Name: {file_name}
Bucket: {bucket}
Size: {file_size} bytes
Content Type: {content_type}
Last Modified: {last_modified}
ETag: {etag}
Storage Class: {storage_class}
"""

            # Publish notification to SNS
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Subject=subject,
                Message=message_body
            )

            logger.info(
                "Notification published successfully for file: %s",
                file_name
            )

        except Exception:
            logger.exception("Error processing SQS record")
            raise

    return {
        "statusCode": 200,
        "body": json.dumps("File notification processed successfully")
    }
