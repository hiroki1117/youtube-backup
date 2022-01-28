#AWSBatchへジョブをサブミットするLambda
resource "aws_lambda_function" "submitjob_lambda" {
  filename         = data.archive_file.submitjob_batch.output_path
  function_name    = "submitjob-lambda"
  role             = module.iam_assumable_role_for_submitjob_lambda.iam_role_arn
  handler          = "main.lambda_handler"
  source_code_hash = data.archive_file.submitjob_batch.output_base64sha256

  runtime = "python3.8"

  environment {
    variables = {
      JOB_DEFINITION_NAME = var.youtube_dl_job_definition_name
      JOB_REVISION        = aws_batch_job_definition.youtube_dl_job_definition.revision
      JOB_QUEUE_NAME      = var.youtube_dl_job_queue_name
      DYNAMO_TABLE_NAME   = aws_dynamodb_table.youtube-backup-table.name
    }
  }

}

data "archive_file" "submitjob_batch" {
  type        = "zip"
  source_dir  = "./submit-job-lambda"
  output_path = "submit-job-lambda.zip"
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
    }
  }

}

data "archive_file" "delete_video" {
  type        = "zip"
  source_dir  = "./delete-video-lambda"
  output_path = "delete-video-lambda.zip"
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
  source_dir  = "./complete-video-upload"
  output_path = "complete-video-upload.zip"
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
  timeout          = 500

  runtime = "python3.8"
}

data "archive_file" "scrapbox_backup" {
  type        = "zip"
  source_dir  = "./scrapbox-backup-lambda"
  output_path = "scrapbox-backup-lambda.zip"
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
  source_dir  = "./video-info-lambda"
  output_path = "video-info-lambda.zip"
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
  source_dir  = "./video-list-lambda"
  output_path = "video-list-lambda.zip"
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
  source_dir  = "./presigned-s3url-lambda"
  output_path = "presigned-s3url-lambda.zip"
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
        Effect = "Allow"
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