# ------------------------------------------------------------
# AWS API Gateway
# ------------------------------------------------------------

resource "aws_api_gateway_rest_api" "links" {
  name        = "links"
  description = "Redirection"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "links" {
  rest_api_id = "${aws_api_gateway_rest_api.links.id}"
  parent_id   = "${aws_api_gateway_rest_api.links.root_resource_id}"
  path_part   = "${element(keys(var.links), count.index)}"
  count       = "${length(keys(var.links))}"
}

resource "aws_api_gateway_method" "links" {
  rest_api_id   = "${aws_api_gateway_rest_api.links.id}"
  resource_id   = "${aws_api_gateway_resource.links.*.id[count.index]}"
  http_method   = "GET"
  authorization = "NONE"
  count         = "${length(keys(var.links))}"
}

resource "aws_api_gateway_integration" "links" {
  rest_api_id = "${aws_api_gateway_rest_api.links.id}"
  resource_id = "${aws_api_gateway_resource.links.*.id[count.index]}"
  http_method = "${aws_api_gateway_method.links.*.http_method[count.index]}"
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{"statusCode": 301}
EOF
  }

  count = "${length(keys(var.links))}"
}

resource "aws_api_gateway_method_response" "links" {
  depends_on  = ["aws_api_gateway_method.links"]
  rest_api_id = "${aws_api_gateway_rest_api.links.id}"
  resource_id = "${aws_api_gateway_resource.links.*.id[count.index]}"
  http_method = "${aws_api_gateway_method.links.*.http_method[count.index]}"
  status_code = 301

  response_parameters = {
    "method.response.header.location" = true
  }

  count = "${length(keys(var.links))}"
}

resource "aws_api_gateway_integration_response" "links" {
  depends_on  = ["aws_api_gateway_integration.links"]
  rest_api_id = "${aws_api_gateway_rest_api.links.id}"
  resource_id = "${aws_api_gateway_resource.links.*.id[count.index]}"
  http_method = "${aws_api_gateway_method_response.links.*.http_method[count.index]}"
  status_code = 301

  response_templates = {
    "application/json" = ""
  }

  response_parameters = {
    "method.response.header.location" = "'${var.links[element(keys(var.links), count.index)]}'"
  }

  count = "${length(keys(var.links))}"
}

locals {
  # NOTE: There is deployment issue - https://github.com/hashicorp/terraform/issues/6613
  deploy_hash_keys = [
    "${file("${path.module}/main.tf")}",
    "${jsonencode(var.links)}",
    "${var.acm_domain_name}",
    "${var.custom_domain_name}",
  ]
  hash = "${sha256(join(";", local.deploy_hash_keys))}"
}

resource "aws_api_gateway_deployment" "links" {
  depends_on = [
    "aws_api_gateway_method_response.links",
    "aws_api_gateway_integration_response.links",
  ]

  # NOTE: There is deployment issue - https://github.com/hashicorp/terraform/issues/6613
  stage_description = "${local.hash}"

  rest_api_id = "${aws_api_gateway_rest_api.links.id}"
  stage_name  = "main"
}

# --------------------------------------------------------------------------------
# Custom domain setting
# NOTE: Before setting up a custom domain name for an API,
#       you must have an SSL/TLS certificate ready in AWS Certificate Manager.
# https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-custom-domains-prerequisites.html 
# --------------------------------------------------------------------------------

data "aws_acm_certificate" "links" {
  domain   = "${var.acm_domain_name}"
  statuses = ["ISSUED"]
}

resource "aws_api_gateway_domain_name" "links" {
  domain_name              = "${var.custom_domain_name}"
  regional_certificate_arn = "${data.aws_acm_certificate.links.arn}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "links" {
  api_id      = "${aws_api_gateway_rest_api.links.id}"
  stage_name  = "${aws_api_gateway_deployment.links.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.links.domain_name}"
}
