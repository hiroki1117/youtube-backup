#AWSBatchへジョブをサブミットするLambda
resource "aws_lambda_function" "submitjob_lambda" {
  filename      = data.archive_file.submitjob_batch.output_path
  function_name = "submitjob-lambda"
  role          = module.iam_assumable_role_for_submitjob_lambda.this_iam_role_arn
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
