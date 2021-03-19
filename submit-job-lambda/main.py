import boto3
import json
import dataclasses
import datetime
import urllib.request
from urllib.parse import urlparse
from urllib.parse import parse_qs


def lambda_handler(event, context):
    url = event['queryStringParameters']['url']

    # 動画のタイトルなどの情報を取得
    youtube_client = YoutubeClient()
    video_data = youtube_client.video_info(url)

    # DynamoDBに保存
    dynamo_client = DynamoClient()
    dynamo_client.insert(video_data)

    # AWS Batchで動画保存処理
    client = BatchClient()
    queue = "youtubedl-batch-queue4"
    jobDefinition = "youtube-dl-job-definition:14"
    jobname = "youtubedljob-from-lambda"
    containerOverrides={
        'environment': [
            {
                'name': 'URL',
                'value': url
            },
            {
                'name': 'FILENAME',
                'value': video_data.backup_filename
            },
            {
                'name': 'S3PATH',
                'value': video_data.s3path
            }
        ]
    }
    
    client.submit_job(
        job_name=jobname,
        job_queue=queue,
        job_definition=jobDefinition,
        container_overrides=containerOverrides
        )
     
    response = {
        "statusCode": 200,
        "body": str(video_data),
        "headers": {
            "Content-Type": "application/json"
        }
    }
    return response



class BatchClient:

    def __init__(self):
        self.client = boto3.client("batch")

    def submit_job(self, job_name: str, job_queue: str, job_definition: str, container_overrides: dict):
        self.client.submit_job(
            jobName=job_name,
            jobQueue=job_queue,
            jobDefinition=job_definition,
            containerOverrides=container_overrides
        )


class DynamoClient():

    def __init__(self):
        self.dynamo_client = boto3.resource("dynamodb")

    def insert(self, youtubedata):
        table = self.dynamo_client.Table('YoutubeBackup')
        response = table.put_item(
            Item = {
                'video_id': youtubedata.id,
                'title': youtubedata.title,
                'backupdate': youtubedata.backupdate,
                's3fullpath': youtubedata.s3path + youtubedata.backup_filename
            }
        )


class YoutubeClient():
  
    def __init__(self):
        ssm = boto3.client('ssm', region_name='ap-northeast-1')
        ssm_response = ssm.get_parameters(
            Names = [('/youtube-backup/youtube-api-key')],
            WithDecryption=True
            )
        self.YOUTUBE_API_KEY = ssm_response['Parameters'][0]['Value']
    
    def video_info(self, video_url):
        video_id = self.__parse_url(video_url)
        url = f'https://www.googleapis.com/youtube/v3/videos?id={video_id}&key={self.YOUTUBE_API_KEY}&part=snippet'
        
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req) as res:
            video_json = json.load(res)
            print(video_json)

        day = datetime.date.today()
        return YoutubeData(
            id=video_id,
            title=video_json['items'][0]['snippet']['title'],
            s3path=f's3://youtubedl-bucket/{day.year}/{day.month}/{day.day}/',
            backupdate=str(day),
            backup_filename=video_json['items'][0]['snippet']['title'] + '-' + video_id + '.mp4'
        )
    
    def __parse_url(self, url):
        return parse_qs(urlparse(url).query)['v'][0]


@dataclasses.dataclass
class YoutubeData():
    id: str
    title: str
    s3path: str
    backup_filename: str
    backupdate: str
