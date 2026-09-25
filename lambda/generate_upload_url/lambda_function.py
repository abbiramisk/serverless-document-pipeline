import boto3
import json
import uuid

s3 = boto3.client('s3', config=boto3.session.Config(signature_version='s3v4'))
BUCKET_NAME = 'docpipeline-uploads-2026'

def lambda_handler(event, context):
    headers = {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json'
    }

    params = event.get('queryStringParameters') or {}
    file_name = params.get('file_name', f"{uuid.uuid4()}.jpg")

    # Generate a temporary, secure URL the browser can PUT a file to directly
    presigned_url = s3.generate_presigned_url(
        'put_object',
        Params={'Bucket': BUCKET_NAME, 'Key': file_name},
        ExpiresIn=300  # URL valid for 5 minutes
    )

    return {
        'statusCode': 200,
        'headers': headers,
        'body': json.dumps({'upload_url': presigned_url, 'file_name': file_name})
    }

