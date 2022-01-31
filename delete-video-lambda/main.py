import os
import boto3
import json
from urllib.parse import urlparse

def lambda_handler(event, context):
    video_id = event['queryStringParameters']['video_id']

    #削除ロジック
    result = process(video_id)
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


def process(video_id):
    dynamo_client = DynamoClient()
    s3_client = S3Client()

    # ビデオ情報
    video_data = dynamo_client.get_videodata(video_id)

    if video_data is None:
        return {
            'result': 'error',
            'description': 'Dynamoに情報がない',
            'video_data': None
        }


    if not s3_client.checks3exists(video_data['s3fullpath']):
        return {
            'result': 'error',
            'description': '(バックアップ中)Dynamoに登録されているがS3に存在しません。',
            'video_data': video_data
        }

    s3result = s3_client.delete_object(video_data['s3fullpath'])
    if not s3result:
        return {
            'result': 'error',
            'description': 'S3の削除に失敗',
            'video_data': video_data
        }
    
    dynamoresult = dynamo_client.delete_videodata(video_id)

    if not dynamoresult:
        return {
            'result': 'error',
            'description': 'DynamoItemの削除に失敗',
            'video_data': video_data
        }
    
    return {
        'result': 'succ',
        'description': '',
        'video_data': video_data
    }



class DynamoClient():

    def __init__(self):
        self.dynamo_client = boto3.resource("dynamodb")
        self.table = self.dynamo_client.Table(os.environ["DYNAMO_TABLE_NAME"])

    def get_videodata(self, video_id):
        res = self.table.get_item(Key={'video_id': video_id})
        return res['Item'] if 'Item' in res else None
    
    def delete_videodata(self, video_id):
        res = self.table.delete_item(
            Key={
                'video_id': video_id
            }
        )
        status = res['ResponseMetadata']['HTTPStatusCode']
        return status == 200

class S3Client():

    def __init__(self):
        self.s3_client = boto3.client('s3')
    
    def delete_object(self, s3fullpath):
        bucket, key = self.__parse_s3fullpath(s3fullpath)
        res = self.s3_client.delete_object(
            Bucket=bucket,
            Key=key
        )
        status = res['ResponseMetadata']['HTTPStatusCode']

        return status == 204

    # 指定のkeyが存在するか確認
    def checks3exists(self, s3fullpath):
        bucket, key = self.__parse_s3fullpath(s3fullpath)
        try:
            self.s3_client.head_object(Bucket=bucket, Key=key)
            return True
        except:
            return False

    def __parse_s3fullpath(self, s3fullpath):
        tmp = urlparse(s3fullpath)
        return (tmp.netloc, tmp.path[1:])
