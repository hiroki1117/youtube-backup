resource "aws_api_gateway_rest_api" "rest_api" {
  name        = "youtubebackup_api"
  description = "rest api"
  endpoint_configuration {
    types = ["REGIONAL"]
  }

  body = templatefile("./apidefinition.json", {
    sample_lambda_arn = aws_lambda_function.video_info_lambda.invoke_arn
  })
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.video_info_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*/*"
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