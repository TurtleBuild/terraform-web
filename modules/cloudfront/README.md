<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_distribution.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aliases"></a> [aliases](#input\_aliases) | エイリアス | `list(string)` | n/a | yes |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | Certificate ARN（us-east-1） | `string` | n/a | yes |
| <a name="input_distribution_name"></a> [distribution\_name](#input\_distribution\_name) | Distribution 識別名 | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | システム環境 | `string` | n/a | yes |
| <a name="input_lb_dns_name"></a> [lb\_dns\_name](#input\_lb\_dns\_name) | ロードバランサーDNS名 | `string` | n/a | yes |
| <a name="input_lb_id"></a> [lb\_id](#input\_lb\_id) | ロードバランサーID | `string` | n/a | yes |
| <a name="input_origin_keepalive_timeout"></a> [origin\_keepalive\_timeout](#input\_origin\_keepalive\_timeout) | CloudFront-オリジン間のTCP接続を持続させる有効時間（1〜60s） | `number` | `5` | no |
| <a name="input_origin_read_timeout"></a> [origin\_read\_timeout](#input\_origin\_read\_timeout) | CloudFrontがオリジンからのレスポンスを待つ時間（4〜60s） | `number` | `60` | no |
| <a name="input_web_acl_id"></a> [web\_acl\_id](#input\_web\_acl\_id) | Web ACL ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | ドメイン名 |
| <a name="output_hosted_zone_id"></a> [hosted\_zone\_id](#output\_hosted\_zone\_id) | ホストゾーンID |
<!-- END_TF_DOCS -->