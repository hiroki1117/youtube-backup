import boto3
import json

def lambda_handler(event, context):
    
    client = BatchClient()
    queue = "youtubedl-batch-queue4"
    jobDefinition = "sample-youtube-dl:6"
    jobname = "youtubedljob-from-lambda"
    
    client.submit_job(jobname, queue, jobDefinition, {})
    
    response = {
        "statusCode": 200,
        "body": "Hello from Lambda!!!!",
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
      jobDefinition=job_definition
    #   containerOverrides=container_overrides
    )
