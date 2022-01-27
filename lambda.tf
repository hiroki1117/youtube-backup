#AWSBatchへジョブをサブミットするLambda
resource "aws_lambda_function" "submitjob_lambda" {
  filename      = data.archive_file.submitjob_batch.output_path
  function_name = "submitjob-lambda"
  role          = module.iam_assumable_role_for_submitjob_lambda.iam_role_arn
  handler       = "main.lambda_handler"
  source_code_hash = data.archive_file.submitjob_batch.output_base64sha256

  runtime = "python3.8"

  environment {
    variables = {
      JOB_DEFINITION_NAME = var.youtube_dl_job_definition_name
      JOB_REVISION = aws_batch_job_definition.youtube_dl_job_definition.revision
      JOB_QUEUE_NAME = var.youtube_dl_job_queue_name
      DYNAMO_TABLE_NAME = aws_dynamodb_table.youtube-backup-table.name
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
  filename      = data.archive_file.delete_video.output_path
  function_name = "delete-video-lambda"
  role          = module.iam_assumable_role_for_deletevideo_lambda.iam_role_arn
  handler       = "main.lambda_handler"
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
  filename      = data.archive_file.video_upload.output_path
  function_name = "video-upload-complete-lambda"
  role          = module.iam_assumable_role_for_video_upload_lambda.iam_role_arn
  handler       = "main.lambda_handler"
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
  filename      = data.archive_file.scrapbox_backup.output_path
  function_name = "scrapbox-backup-lambda"
  role          = module.iam_assumable_role_for_scrapbox_backup_lambda.iam_role_arn
  handler       = "main.lambda_handler"
  source_code_hash = data.archive_file.scrapbox_backup.output_base64sha256
  timeout = 500

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