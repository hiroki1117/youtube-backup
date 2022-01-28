import os
import boto3
import json

def lambda_handler(event, context):
    video_id = event['queryStringParameters']['video_id']

    # 動画情報の取得
    table = boto3.resource("dynamodb").Table(os.environ["DYNAMO_TABLE_NAME"])
    video_data = table.get_item(Key={'video_id': video_id})
    result = {
            'result': 'succ',
            'description': '',
            'video_data': video_data
        } if video_data is not None else {
            'result': 'error',
            'description': 'Dynamoに情報がない',
            'video_data': None
        }

    response = {
        "statusCode": 200,
        "body": json.dumps(result),
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Headers": 'Content-Type',
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": 'OPTIONS,POST,GET'
        }
    }
    return response