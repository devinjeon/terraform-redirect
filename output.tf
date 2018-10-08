output "target_domain_name" {
  value = "${aws_api_gateway_domain_name.links.regional_domain_name}"
  description = "The hostname for the custom domain's regional endpoint."
}
