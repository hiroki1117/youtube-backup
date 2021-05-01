#AWSBatchへジョブをサブミットするLambda
resource "aws_lambda_function" "submitjob_lambda" {
  filename      = data.archive_file.submitjob_batch.output_path
  function_name = "submitjob-lambda"
  role          = module.iam_assumable_role_for_submitjob_lambda.iam_role_arn
  handler       = "main.lambda_handler"
  source_code_hash = data.archive_file.submitjob_batch.output_base64sha256

  runtime = "python3.8"

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