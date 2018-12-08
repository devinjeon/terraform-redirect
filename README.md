# terraform-redirect

* Terraform module for simple redirection
* This does not use AWS Lambda, using only AWS API Gateway

## Usage

```hcl
provider "aws" {}

module "example" {
  source = "github.com/DevinJeon/terraform-redirect"

  acm_domain_name    = "*.example.com"
  custom_domain_name = "links.example.com"

  links = {
    "google"   = "https://google.com"    # -> links.example.com/google
    "facebook" = "https://facebook.com   # -> links.example.com/facebook"
    ...
  }
}
```

### Example

https://github.com/devinjeon/hyojun.me-links

## Limit

It creates a resource per custom link, and there is maximum number of resources per API.

* Maximum number of resources per API: 300 [(link)](https://docs.aws.amazon.com/apigateway/latest/developerguide/limits.html)

But, it may be enough for personal use :)

## Known issue

If the order of the keys in the `links` variable is changed, it is not guaranteed that the `aws_api_gateway_resource` resources will be regenerated after all resources being destroyed. If you try to create the same name as a resource that has not yet been destroyed, you will have problems. So you have to destroy all `aws_api_gateway_resource` with `terraform destroy` command.(I know that this is not a good way, but i have not found a way yet.)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| acm_domain_name | Before setting up a custom domain name for an API, you must have an SSL/TLS certificate ready in AWS Certificate Manager. (Ref: https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-custom-domains-prerequisites.html) | string | - | yes |
| custom_domain_name | Set custom domain name | string | `redirect` | no |
| links | '*.domain.com/{key}' is redirected to '{value}' | map | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| target_domain_name | The hostname for the custom domain's regional endpoint. |

