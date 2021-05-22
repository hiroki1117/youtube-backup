import re
import json
import boto3
import urllib.request

def lambda_handler(event, context):
    
    ssm = boto3.client('ssm', region_name='ap-northeast-1')
    ssm_response = ssm.get_parameters(
        Names = [('/youtube-backup/endpoint-url'), ('/youtube-backup/scrapbox-credentials'), ('/youtube-backup/scrapbox-projects')],
        WithDecryption=True
    )
    YOUTUBE_BACKUP_ENDPOINT = ssm_response['Parameters'][0]['Value']
    SCRAPBOX_CREDENTIALS = ssm_response['Parameters'][1]['Value']
    # hoge,fuga,...形式
    SCRAPBOX_PROJECTS = ssm_response['Parameters'][2]['Value']

    LIMIT = 10
    base_endpoint = "https://scrapbox.io/api/pages/"
    header = {
        "Cookie": "connect.sid="+SCRAPBOX_CREDENTIALS
    }

    for project in SCRAPBOX_PROJECTS.split(","):
        pagetitles = get_pagetitle(base_endpoint + projects, header)
        [for i in pagetitles]


# ページのタイトルの配列を返却
# https://scrapbox.io/api/pages/プロジェクト
def get_pagetitle(url, header):
    req = urllib.request.Request(url, headers=header)
    with urllib.request.urlopen(req) as res:
        pages_json = json.load(res)
    
    return map(lambda x: x['title'], pages_json['pages'])

# ページの内容を一行毎の配列として返却
# https://scrapbox.io/api/pages/プロジェクト/ページタイトル
def get_page_content(url, header):
    req = urllib.request.Request(url, headers=header)
    with urllib.request.urlopen(req) as res:
        pages_json = json.load(res)

    return map(lambda x: x['text'], pages_json['lines'])

# 一行からyoutubeの動画idを抽出する
def extract_youtubevideoid(text):
	result = re.search(r"https://www\.youtube\.com/watch\?v=.{11}", text)
	if result is not None:
		return result.group()

	result = re.search(r"https://youtu\.be/.{11}", text)
	if result is not None:
		return result.group()
	return None

# youtube backupリクエスト
def youtube_backup_request(url, video_id):
    youtube_url = "https://www.youtube.com/watch?v=" + video_id
    req = urllib.request.Request(url + youtube_url)
    with urllib.request.urlopen(req) as res:
        o = json.load(res)
        print(o)

