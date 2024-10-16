#AWSBatchへジョブをサブミットするLambda
resource "aws_lambda_function" "submitjob_lambda" {
  filename         = data.archive_file.submitjob_batch.output_path
  function_name    = "submitjob-lambda"
  role             = module.iam_assumable_role_for_submitjob_lambda.iam_role_arn
  handler          = "main.lambda_handler"
  source_code_hash = data.archive_file.submitjob_batch.output_base64sha256

  runtime = "python3.8"

  layers = ["arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-python38-tweepy:1"]

  environment {
    variables = {
      # JOB_DEFINITION_NAME = var.youtube_dl_job_definition_name
      # JOB_REVISION        = aws_batch_job_definition.youtube_dl_job_definition.revision
      # JOB_QUEUE_NAME      = var.youtube_dl_job_queue_name
      JOB_DEFINITION_NAME = var.youtube_dl_job_fargate_definition_name
      JOB_REVISION        = aws_batch_job_definition.youtube_dl_job_fargate_definition.revision
      JOB_QUEUE_NAME      = var.youtube_dl_job_fargate_queue_name
      DYNAMO_TABLE_NAME   = aws_dynamodb_table.youtube-backup-table.name
      BACKUP_BACKET       = aws_s3_bucket.youtubedl_bucket.bucket

      #ytdlpを実験的に導入
      YTDLP_JOB_DEFINITION_NAME = aws_batch_job_definition.ytdlp_job_fargate_definition.name
      YTDLP_JOB_REVISION        = aws_batch_job_definition.ytdlp_job_fargate_definition.revision
    }
  }
}

data "archive_file" "submitjob_batch" {
  type        = "zip"
  source_dir  = "./lambda/submit-job-lambda"
  output_path = "./lambdazip/submit-job-lambda.zip"
}

#Lambdaのロール
module "iam_assumable_role_for_submitjob_lambda" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  trusted_role_services = [
    "lambda.amazonaws.com"
  ]

  create_role = true

  role_name         = "SubmitJobLambdaRole"
  role_requires_mfa = false

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AWSBatchFullAccess",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  ]
}


#動画を削除するlambda
resource "aws_lambda_function" "delete_video_lambda" {
  filename         = data.archive_file.delete_video.output_path
  function_name    = "delete-video-lambda"
  role             = module.iam_assumable_role_for_deletevideo_lambda.iam_role_arn
  handler          = "main.lambda_handler"
  source_code_hash = data.archive_file.delete_video.output_base64sha256

  runtime = "python3.8"

  environment {
    variables = {
      DYNAMO_TABLE_NAME = aws_dynamodb_table.youtube-backup-table.name
      BATCH_JOB_TIMEOUT = aws_batch_job_definition.youtube_dl_job_definition.timeout[0].attempt_duration_seconds
    }
  }
}

data "archive_file" "delete_video" {
  type        = "zip"
  source_dir  = "./lambda/delete-video-lambda"
  output_path = "./lambdazip/delete-video-lambda.zip"
}

#Lambdaのロール
module "iam_assumable_role_for_deletevideo_lambda" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  trusted_role_services = [
    "lambda.amazonaws.com"
  ]

  create_role = true

  role_name         = "DeleteVideoLambdaRole"
  role_requires_mfa = false

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ]
}

#動画アップロード完了処理をするLambda
resource "aws_lambda_function" "video_upload_lambda" {
  filename         = data.archive_file.video_upload.output_path
  function_name    = "video-upload-complete-lambda"
  role             = module.iam_assumable_role_for_video_upload_lambda.iam_role_arn
  handler          = "main.lambda_handler"
  source_code_hash = data.archive_file.video_upload.output_base64sha256

  runtime = "python3.8"

  environment {
    variables = {
      DYNAMO_TABLE_NAME = aws_dynamodb_table.youtube-backup-table.name
    }
  }

}

data "archive_file" "video_upload" {
  type        = "zip"
  source_dir  = "./lambda/complete-video-upload"
  output_path = "./lambdazip/complete-video-upload.zip"
}

#Lambdaのロール
module "iam_assumable_role_for_video_upload_lambda" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  trusted_role_services = [
    "lambda.amazonaws.com"
  ]

  create_role = true

  role_name         = "VideoUploadCompleteLambdaRole"
  role_requires_mfa = false

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  ]
}


#Scrapboxバックアップ処理をするLambda
resource "aws_lambda_function" "scrapbox_backup_lambda" {
  filename         = data.archive_file.scrapbox_backup.output_path
  function_name    = "scrapbox-backup-lambda"
  role             = module.iam_assumable_role_for_scrapbox_backup_lambda.iam_role_arn
  handler          = "main.lambda_handler"
  source_code_hash = data.archive_file.scrapbox_backup.output_base64sha256
  timeout          = 900

  runtime = "python3.8"
  environment {
    variables = {
      SUBMIT_JOB_ENDPOINT = "https://${data.aws_api_gateway_domain_name.custome_domain.id}/video"
    }
  }
}

data "archive_file" "scrapbox_backup" {
  type        = "zip"
  source_dir  = "./lambda/scrapbox-backup-lambda"
  output_path = "./lambdazip/scrapbox-backup-lambda.zip"
}

#Lambdaのロール
module "iam_assumable_role_for_scrapbox_backup_lambda" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  trusted_role_services = [
    "lambda.amazonaws.com"
  ]

  create_role = true

  role_name         = "ScrapboxBackupLambdaRole"
  role_requires_mfa = false

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  ]
}

#video_idから動画情報を取得するlambda
resource "aws_lambda_function" "video_info_lambda" {
  filename         = data.archive_file.video_info.output_path
  function_name    = "video-info-lambda"
  role             = module.iam_assumable_role_for_video_upload_lambda.iam_role_arn
  handler          = "main.lambda_handler"
  source_code_hash = data.archive_file.video_info.output_base64sha256

  runtime = "python3.8"

  environment {
    variables = {
      DYNAMO_TABLE_NAME = aws_dynamodb_table.youtube-backup-table.name
    }
  }
}

data "archive_file" "video_info" {
  type        = "zip"
  source_dir  = "./lambda/video-info-lambda"
  output_path = "./lambdazip/video-info-lambda.zip"
}


#動画の一覧情報を取得するlambda
resource "aws_lambda_function" "video_list_lambda" {
  filename         = data.archive_file.video_list.output_path
  function_name    = "video-list-lambda"
  role             = module.iam_assumable_role_for_video_upload_lambda.iam_role_arn
  handler          = "main.lambda_handler"
  source_code_hash = data.archive_file.video_list.output_base64sha256

  runtime = "python3.8"

  environment {
    variables = {
      DYNAMO_TABLE_NAME = aws_dynamodb_table.youtube-backup-table.name
    }
  }
}

data "archive_file" "video_list" {
  type        = "zip"
  source_dir  = "./lambda/video-list-lambda"
  output_path = "./lambdazip/video-list-lambda.zip"
}

# S3urlにpresignedするlambda
resource "aws_lambda_function" "presigned_s3url_lambda" {
  filename         = data.archive_file.presigned_s3url.output_path
  function_name    = "presigned-s3url-lambda"
  role             = module.iam_assumable_role_for_presigned_s3url_lambda.iam_role_arn
  handler          = "main.lambda_handler"
  source_code_hash = data.archive_file.presigned_s3url.output_base64sha256

  runtime = "python3.8"

  environment {
    variables = {
      DYNAMO_TABLE_NAME = aws_dynamodb_table.youtube-backup-table.name
    }
  }
}

data "archive_file" "presigned_s3url" {
  type        = "zip"
  source_dir  = "./lambda/presigned-s3url-lambda"
  output_path = "./lambdazip/presigned-s3url-lambda.zip"
}

resource "aws_iam_policy" "youtubebackupbacket_readonly_policy" {
  name = "youtubebackupbacket_readonly_policy_for_presigned"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.youtubedl_bucket.arn}/*"
      }
    ]
  })
}

#Lambdaのロール
module "iam_assumable_role_for_presigned_s3url_lambda" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  trusted_role_services = [
    "lambda.amazonaws.com"
  ]

  create_role = true

  role_name         = "PresignedS3URLForYoutubeBackupLambdaRole"
  role_requires_mfa = false

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    aws_iam_policy.youtubebackupbacket_readonly_policy.arn
  ]
}


#動画情報をアップデートするlambda
resource "aws_lambda_function" "update_video_lambda" {
  filename         = data.archive_file.update_video.output_path
  function_name    = "update-video-lambda"
  role             = module.iam_assumable_role_for_deletevideo_lambda.iam_role_arn
  handler          = "main.lambda_handler"
  source_code_hash = data.archive_file.update_video.output_base64sha256

  runtime = "python3.8"

  environment {
    variables = {
      DYNAMO_TABLE_NAME = aws_dynamodb_table.youtube-backup-table.name
    }
  }
}

data "archive_file" "update_video" {
  type        = "zip"
  source_dir  = "./lambda/update-video-lambda"
  output_path = "./lambdazip/update-video-lambda.zip"
}

#Lambdaのロール
module "iam_assumable_role_for_updatevideo_lambda" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  trusted_role_services = [
    "lambda.amazonaws.com"
  ]

  create_role = true

  role_name         = "UpdateVideoLambdaRole"
  role_requires_mfa = false

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  ]
}

#動画DLに失敗したレコードを一括でretryするlambda
resource "aws_lambda_function" "retry_submit_job_lambda" {
  filename         = data.archive_file.retry_submit_job.output_path
  function_name    = "retry-submit-job-lambda"
  role             = module.iam_assumable_role_for_submitjob_lambda.iam_role_arn
  handler          = "main.lambda_handler"
  source_code_hash = data.archive_file.retry_submit_job.output_base64sha256
  timeout          = 900

  runtime = "python3.8"

  environment {
    variables = {
      DYNAMO_TABLE_NAME         = aws_dynamodb_table.youtube-backup-table.name
      JOB_DEFINITION_NAME       = var.youtube_dl_job_fargate_definition_name
      JOB_REVISION              = aws_batch_job_definition.youtube_dl_job_fargate_definition.revision
      JOB_QUEUE_NAME            = var.youtube_dl_job_fargate_queue_name
      YTDLP_JOB_DEFINITION_NAME = aws_batch_job_definition.ytdlp_job_fargate_definition.name
      YTDLP_JOB_REVISION        = aws_batch_job_definition.ytdlp_job_fargate_definition.revision
    }
  }
}

data "archive_file" "retry_submit_job" {
  type        = "zip"
  source_dir  = "./lambda/retry-submit-job-lambda"
  output_path = "./lambdazip/retry-submit-job-lambda.zip"
}
