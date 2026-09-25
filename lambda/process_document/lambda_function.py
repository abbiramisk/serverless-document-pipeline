import boto3
import uuid
import json
from datetime import datetime

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('docpipeline-results')

def lambda_handler(event, context):
    # Get bucket and file name from the S3 event that triggered this
    record = event['Records'][0]
    bucket = record['s3']['bucket']['name']
    key = record['s3']['object']['key']

    file_id = str(uuid.uuid4())

    try:
        # Get file metadata directly from S3 (size, content type, etc.)
        head = s3.head_object(Bucket=bucket, Key=key)
        file_size = head['ContentLength']
        content_type = head.get('ContentType', 'unknown')

        # Placeholder for the OCR/analysis step — this is the integration
        # point where Textract or Rekognition would plug in once enabled
        extracted_text = "mock: OCR integration point (Textract pending account plan upgrade)"

        table.put_item(Item={
            'file_id': file_id,
            'file_name': key,
            'file_size_bytes': file_size,
            'content_type': content_type,
            'upload_time': datetime.utcnow().isoformat(),
            'extracted_text': extracted_text,
            'status': 'completed'
        })

        return {'statusCode': 200, 'body': json.dumps('Processed successfully')}

    except Exception as e:
        table.put_item(Item={
            'file_id': file_id,
            'file_name': key,
            'upload_time': datetime.utcnow().isoformat(),
            'status': 'failed',
            'error_message': str(e)
        })
        raise e
