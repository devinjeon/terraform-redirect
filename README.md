# Redirect
* Terraform module for simple redirection
* This does not use AWS Lambda, using only AWS API Gateway

## Limit

It creates a resource per link.

And there is maximum number of resources per API.

It may be enough for personal use :)

* Maximum number of resources per API: 300 [(link)](https://docs.aws.amazon.com/apigateway/latest/developerguide/limits.html)

## Usage

```hcl
provider "aws" {}

module "example" {
  source = "github.com/DevinJeon/terraform-redirect"

  acm_domain_name    = "*.example.com"
  custom_domain_name = "links.example.com"

  links = {
    "google"    = "https://google.com"    # -> links.example.com/google
    "facebook"  = "https://facebook.com   # -> links.example.com/facebook"
    ...
  }
}
```

### Example
https://github.com/devinjeon/hyojun.me-links

## Inputs

| Name | Description | Type | Default |
|------|-------------|:----:|:-----:|
| acm_domain_name | Before setting up a custom domain name for an API, you must have an SSL/TLS certificate ready in AWS Certificate Manager. (Ref: https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-custom-domains-prerequisites.html) | string | - |
| custom_domain_name | Set custom domain name | string | `redirect` |
| links | '*.domain.com/{key}' is redirected to '{value}' | map | - |

## Outputs

| Name | Description |
|------|-------------|
| target_domain_name | The hostname for the custom domain's regional endpoint. |

