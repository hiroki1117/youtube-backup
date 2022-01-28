resource "aws_api_gateway_rest_api" "rest_api" {
  name        = "youtubebackup_api"
  description = "rest api"
  endpoint_configuration {
    types = ["REGIONAL"]
  }

  body = templatefile("./apidefinition.json", {
      submit-job-lambda_arn = aws_lambda_function.submitjob_lambda.invoke_arn
      video-info-lambda_arn = aws_lambda_function.video_info_lambda.invoke_arn
      delete-video-lambda_arn = aws_lambda_function.delete_video_lambda.invoke_arn
      video-list-lambda_arn = aws_lambda_function.video_list_lambda.invoke_arn
  })
}

resource "aws_api_gateway_deployment" "deployment" {
  stage_name  = var.api_gateway_stagename
  rest_api_id = aws_api_gateway_rest_api.rest_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.rest_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_api_gateway_rest_api.rest_api]
}

# API Gatewayとカスタムドメインの対応付け
resource "aws_api_gateway_base_path_mapping" "domain_mapping" {
  api_id      = aws_api_gateway_rest_api.rest_api.id
  stage_name  = var.api_gateway_stagename
  domain_name = data.aws_api_gateway_domain_name.custome_domain.id
}

# Route53にカスタムドメインのエイリアスレコードを登録する
resource "aws_route53_record" "api_gateway_alias" {
  name    = data.aws_api_gateway_domain_name.custome_domain.id
  type    = "A"
  zone_id = data.aws_route53_zone.hostzone.zone_id

  alias {
    evaluate_target_health = true
    name                   = data.aws_api_gateway_domain_name.custome_domain.regional_domain_name
    zone_id                = data.aws_api_gateway_domain_name.custome_domain.regional_zone_id
  }
}

# マネコンからAPI Gatewayカスタムドメインの作成をしておく
data "aws_api_gateway_domain_name" "custome_domain" {
  domain_name = var.custome_domain_name
}

# ドメインの取得はマネコンから行う
data "aws_route53_zone" "hostzone" {
  name = var.hostzone
}

# API Gatewayがlambdaを呼び出す権限
locals {
    api_lambda_list = [
        aws_lambda_function.submitjob_lambda.function_name,
        aws_lambda_function.video_info_lambda.function_name,
        aws_lambda_function.delete_video_lambda.function_name,
        aws_lambda_function.video_list_lambda.function_name
    ]
}

resource "aws_lambda_permission" "apigw_lambda_permission" {
  count = length(local.api_lambda_list)

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = local.api_lambda_list[count.index]
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*/*"
}