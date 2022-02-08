{
  "jobDefinitionName": "youtube-dl-job-fargate-definition",
  "image": "${ecr_name}:latest",
  "command": ["bash","main.sh"],
  "fargatePlatformConfiguration": {
    "platformVersion": "LATEST"
  },
  "resourceRequirements": [
    {"type": "VCPU", "value": "1"},
    {"type": "MEMORY", "value": "2048"}
  ],
  "executionRoleArn": "${ecs_task_ex_role}",
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
  "networkConfiguration": { 
   "assignPublicIp": "ENABLED"
  }
}