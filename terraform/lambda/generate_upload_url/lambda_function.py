import boto3
import json
import uuid
import os

BUCKET_NAME = os.environ["UPLOAD_BUCKET"]

s3 = boto3.client(
    's3',
    region_name='ap-south-1',
    endpoint_url='https://s3.ap-south-1.amazonaws.com',
    config=boto3.session.Config(signature_version='s3v4')
)

def lambda_handler(event, context):

    headers = {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json'
    }

    params = event.get('queryStringParameters') or {}

    file_name = params.get(
        'file_name',
        f"{uuid.uuid4()}.jpg"
    )

    # Generate a temporary, secure URL the browser can PUT a file to directly
    presigned_url = s3.generate_presigned_url(
        'put_object',
        Params={
            'Bucket': BUCKET_NAME,
            'Key': file_name
        },
        ExpiresIn=300
    )

    return {
        'statusCode': 200,
        'headers': headers,
        'body': json.dumps({
            'upload_url': presigned_url,
            'file_name': file_name
        })
    }
