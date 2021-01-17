import boto3
import json

def lambda_handler(event, context):
    url = event['queryStringParameters']['url']
    
    client = BatchClient()
    queue = "youtubedl-batch-queue4"
    jobDefinition = "youtube-dl-job-definition:4"
    jobname = "youtubedljob-from-lambda"
    containerOverrides={
        'environment': [
            {
                'name': 'URL',
                'value': url
            },
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
        "body": url,
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
