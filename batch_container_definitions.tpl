
{
  "jobDefinitionName": "youtube-dl-job-definition",
  "image": "103933412310.dkr.ecr.ap-northeast-1.amazonaws.com/youtube-downloader:v4",
  "executionRoleArn": "arn:aws:iam::103933412310:role/ecsTaskExecutionRole",
  "jobRoleArn": "${job_role_arn}",
  "logConfiguration": {
    "logDriver": "awslogs",
    "options": {
      "awslogs-region": "ap-northeast-1",
      "awslogs-stream-prefix": "youtube-dl-job",
      "awslogs-group": "${log_group}"
    },
    "secretOptions": []
  },
  "memory": 512,
  "vcpus": 1,
  "command" : ["bash","main.sh"],
  "type": "container",
  "environment": [],
  "mountPoints": [],
  "resourceRequirements": [],
  "secrets": [],
  "ulimits": [],
  "volumes": [],
  "parameters": [],
  "tags": {}
}
