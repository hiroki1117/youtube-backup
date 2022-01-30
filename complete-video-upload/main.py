import os
import boto3
import json

def lambda_handler(event, context):
    object_key = event['Records'][0]['s3']['object']['key']
    video_id = os.path.basename(object_key).split('.')[0]
    update_video_upload_status(video_id_special_process(video_id))
    print(video_id)
    print(video_id_special_process(video_id))

def update_video_upload_status(video_id):
    dynamo_client = boto3.resource("dynamodb")
    table = dynamo_client.Table(os.environ["DYNAMO_TABLE_NAME"])

    # ここでS3のパスも更新するようにしたらmp4以外にも対応できるかも
    response = table.update_item(
        Key={
            'video_id': video_id
        },
        UpdateExpression="set upload_status = :status",
        ExpressionAttributeValues={
            ':status': 'complete'
        },
        ReturnValues="UPDATED_NEW"
    )
    print(response)
    return response

# IDが-から始まる場合は特別な処理をしているのでその変換
def video_id_special_process(video_id):
    if video_id.startswith("ABCXYZ-"):
        return video_id[6:]
    return video_id
