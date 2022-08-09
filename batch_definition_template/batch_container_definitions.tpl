
{
  "jobDefinitionName": "youtube-dl-job-definition",
  "image": "${ecr_name}:latest",
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
  "memory": 1024,
  "vcpus": 2,
  "command" : ["bash","main.sh"],
  "type": "container",
  "environment": [],
  "mountPoints": [],
  "secrets": [],
  "ulimits": [],
  "volumes": [],
  "parameters": [],
  "tags": {}
}
