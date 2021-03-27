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
    is_inserted = dynamo_client.insert(video_data)

    # AWS Batchで動画保存処理
    if is_inserted:
        batch_client = BatchClient()    
        batch_client.submit_job(url, video_data)
     
    response = {
        "statusCode": 200,
        "body": json.dumps({
            'video_id': video_data.id,
            'title': video_data.title,
            'already_backup': not is_inserted
        }),
        "headers": {
            "Content-Type": "application/json"
        }
    }
    return response



class BatchClient:

    def __init__(self):
        self.client = boto3.client("batch")
        self.job_queue = "youtubedl-batch-queue4"
        self.job_definition = "youtube-dl-job-definition:23"
        self.jobname = "youtubedljob-from-lambda"

    def submit_job(self, url, video_data):
        container_overrides={
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
        
        self.client.submit_job(
            jobName=self.jobname,
            jobQueue=self.job_queue,
            jobDefinition=self.job_definition,
            containerOverrides=container_overrides
        )


class DynamoClient():

    def __init__(self):
        self.dynamo_client = boto3.resource("dynamodb")
        self.table = self.dynamo_client.Table('YoutubeBackup')

    def insert(self, videodata):
        # 既に保存されている場合はFalseを返してinsertしない
        if self.__check_already_exists(videodata.id):
            return False

        response = self.table.put_item(
            Item = {
                'video_id': videodata.id,
                'video_url': videodata.url,
                'platform': videodata.platform,
                'title': videodata.title,
                'backupdate': videodata.backupdate,
                's3fullpath': videodata.s3path + videodata.backup_filename
            }
        )

        return True
    
    def __check_already_exists(self, video_id):
        res = self.table.get_item(Key={'video_id': video_id})
        return True if 'Item' in res else False


class YoutubeClient():
  
    def __init__(self):
        ssm = boto3.client('ssm', region_name='ap-northeast-1')
        ssm_response = ssm.get_parameters(
            Names = [('/youtube-backup/youtube-api-key')],
            WithDecryption=True
            )
        self.YOUTUBE_API_KEY = ssm_response['Parameters'][0]['Value']
        self.PLATFORM = 'youtube'
    
    def video_info(self, video_url):
        video_id = self.__parse_url(video_url)
        url = f'https://www.googleapis.com/youtube/v3/videos?id={video_id}&key={self.YOUTUBE_API_KEY}&part=snippet'
        
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req) as res:
            video_json = json.load(res)
            print(video_json)

        day = datetime.date.today()
        return VideoData(
            id=video_id,
            url=url,
            platform=self.PLATFORM,
            title=video_json['items'][0]['snippet']['title'],
            s3path=f's3://youtubedl-bucket/{self.PLATFORM}/{day.year}/{day.month}/{day.day}/',
            backupdate=str(day),
            backup_filename=video_id + '.mp4'
        )
    
    def __parse_url(self, url):
        return parse_qs(urlparse(url).query)['v'][0]


@dataclasses.dataclass
class VideoData():
    id: str
    url: str
    title: str
    platform: str
    s3path: str
    backup_filename: str
    backupdate: str
