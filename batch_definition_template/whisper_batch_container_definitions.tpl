
{
  "jobDefinitionName": "whisper-job-definition",
  "image": "hiroki1117/whisper:3",
  "executionRoleArn": "${ecs_task_ex_role}",
  "jobRoleArn": "${job_role_arn}",
  "logConfiguration": {
    "logDriver": "awslogs",
    "options": {
      "awslogs-region": "ap-northeast-1",
      "awslogs-stream-prefix": "whisper-dl-job",
      "awslogs-group": "${log_group}"
    },
    "secretOptions": []
  },
  "resourceRequirements": [
    {"type": "VCPU", "value": "4"},
    {"type": "GPU", "value": "1"},
    {"type": "MEMORY", "value": "16384"}
  ],
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
