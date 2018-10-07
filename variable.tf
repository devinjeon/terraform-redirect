variable "links" {
  type        = "map"
  description = "'*.domain.com/{key}' is redirected to '{value}'"
}

variable "acm_domain_name" {
  type        = "string"
  description = "Before setting up a custom domain name for an API, you must have an SSL/TLS certificate ready in AWS Certificate Manager. (Ref: https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-custom-domains-prerequisites.html)"
}

variable "custom_domain_name" {
  default = "redirect"
  description = "Set custom domain name"
}
