import boto3
import json
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('docpipeline-results')

def lambda_handler(event, context):
    # file_id comes in as a query string parameter: ?file_id=xxxx
    params = event.get('queryStringParameters') or {}
    file_id = params.get('file_id')

    headers = {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json'
    }

    if not file_id:
        # No file_id given — return all recent items instead (simple list view)
        response = table.scan(Limit=20)
        return {
            'statusCode': 200,
            'headers': headers,
            'body': json.dumps(response['Items'], default=str)
        }

    response = table.get_item(Key={'file_id': file_id})
    item = response.get('Item')

    if not item:
        return {
            'statusCode': 404,
            'headers': headers,
            'body': json.dumps({'error': 'File not found'})
        }

    return {
        'statusCode': 200,
        'headers': headers,
        'body': json.dumps(item, default=str)
    }
