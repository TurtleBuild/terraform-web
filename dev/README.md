<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.14.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.2.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_application"></a> [application](#module\_application) | ../modules/application/ | n/a |
| <a name="module_bastion"></a> [bastion](#module\_bastion) | ../modules/bastion/ | n/a |
| <a name="module_bastion_network"></a> [bastion\_network](#module\_bastion\_network) | ../modules/network/ | n/a |
| <a name="module_batch"></a> [batch](#module\_batch) | ../modules/batch/ | n/a |
| <a name="module_cloudfront"></a> [cloudfront](#module\_cloudfront) | ../modules/cloudfront/ | n/a |
| <a name="module_database"></a> [database](#module\_database) | ../modules/database/ | n/a |
| <a name="module_network"></a> [network](#module\_network) | ../modules/network/ | n/a |
| <a name="module_peering"></a> [peering](#module\_peering) | ../modules/peering/ | n/a |
| <a name="module_waf"></a> [waf](#module\_waf) | ../modules/waf/ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_access_key"></a> [aws\_access\_key](#input\_aws\_access\_key) | AWSアクセスキー（terraform.tfvars で設定） | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWSリージョン | `string` | `"ap-northeast-1"` | no |
| <a name="input_aws_secret_key"></a> [aws\_secret\_key](#input\_aws\_secret\_key) | AWSシークレットキー（terraform.tfvars で設定） | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | システム環境 | `string` | `"dev"` | no |
| <a name="input_tf_role_arn"></a> [tf\_role\_arn](#input\_tf\_role\_arn) | terraformを実行するロールARN（terraform.tfvars で設定） | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->