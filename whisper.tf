#Batch
# resource "aws_batch_compute_environment" "gpu_batch" {
#   compute_environment_name = "gpu-batch2"

#   compute_resources {
#     type                = "EC2"
#     # type                = "SPOT"
#     # spot_iam_fleet_role = module.iam_assumable_role_for_ec2_spot_fleet.iam_role_arn
#     # bid_percentage      = var.spot_bid_percentage
#     subnets             = module.vpc.public_subnets
#     security_group_ids  = [aws_security_group.sg.id]
#     instance_role       = aws_iam_instance_profile.ecs_instance_profile.arn
#     instance_type       = ["g4dn.xlarge"]
#     min_vcpus           = 0
#     max_vcpus           = 4
#     ec2_configuration {
#         image_id_override = "ami-0895fdd05d1b979d3"
#         image_type = "ECS_AL2"
#     }
#     # launch_template {
#     #   launch_template_id = aws_launch_template.ecs_gpu_instance_template.id
#     # }

#     tags = {
#       Product = "youtube-dl"
#     }
#   }

#   service_role = module.iam_assumable_role_for_aws_batch_service.iam_role_arn
#   state        = "ENABLED"
#   type         = "MANAGED"
#   depends_on = [
#     module.iam_assumable_role_for_ec2_spot_fleet,
#     module.iam_assumable_role_for_aws_batch_service,
#     module.iam_assumable_role_for_ecs_instance_role
#   ]

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_launch_template" "ecs_gpu_instance_template" {
#   name = "ECSGPUForEBSTemplate"

#   image_id = "ami-0895fdd05d1b979d3"

#   block_device_mappings {
#     device_name = "/dev/xvda"
#     ebs {
#       volume_size = 50
#     }
#   }
# }

#ジョブキューの用意
# resource "aws_batch_job_queue" "gpu_batch_queue" {
#   name                 = "gpu-batch-queue"
#   state                = "ENABLED"
#   priority             = 1
#   compute_environments = [aws_batch_compute_environment.gpu_batch.arn]
#   lifecycle {
#     create_before_destroy = true
#   }
# }

#ジョブのロググループ
# resource "aws_cloudwatch_log_group" "gpu_job_log_group" {
#   name              = "/aws/batch/gpu-batch"
#   retention_in_days = 7
# }

#ジョブ定義
# resource "aws_batch_job_definition" "whisper_job_definition" {
#   name = "whisper-job-definition"
#   type = "container"
#   timeout {
#     attempt_duration_seconds = 10800
#   }
#   container_properties = templatefile("./batch_definition_template/whisper_batch_container_definitions.tpl",
#     {
#       job_role_arn     = module.iam_assumable_role_for_youtubedl_batchjob.iam_role_arn,
#       log_group        = aws_cloudwatch_log_group.gpu_job_log_group.name,
#       ecs_task_ex_role = data.aws_iam_role.ecsTaskExecutionRole.arn
#     }
#   )
# }