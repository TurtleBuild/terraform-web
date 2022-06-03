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
| [aws_cloudwatch_log_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_policy.ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.get_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_task_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_task_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.get_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route53_record.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ecs_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_caller_identity.self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ec2_managed_prefix_list.cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_managed_prefix_list) | data source |
| [aws_iam_policy_document.ecs_tasks_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.now](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_subnet_ids"></a> [application\_subnet\_ids](#input\_application\_subnet\_ids) | アプリケーションコンテナを起動するサブネットのID | `list(string)` | n/a | yes |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | アベイラビリティゾーン | `list(string)` | <pre>[<br>  "ap-northeast-1a",<br>  "ap-northeast-1c"<br>]</pre> | no |
| <a name="input_cf_domain_name"></a> [cf\_domain\_name](#input\_cf\_domain\_name) | CloudFrontドメイン名 | `string` | n/a | yes |
| <a name="input_cf_hosted_zone_id"></a> [cf\_hosted\_zone\_id](#input\_cf\_hosted\_zone\_id) | CloudFrontホストゾーンID | `string` | n/a | yes |
| <a name="input_container_cpu"></a> [container\_cpu](#input\_container\_cpu) | コンテナCPUユニット数 | `number` | `256` | no |
| <a name="input_container_image_uri"></a> [container\_image\_uri](#input\_container\_image\_uri) | コンテナイメージURI | `string` | n/a | yes |
| <a name="input_container_memory"></a> [container\_memory](#input\_container\_memory) | コンテナに適用されるメモリ量 | `number` | `512` | no |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | コンテナ名 | `string` | n/a | yes |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | コンテナポート | `number` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | ドメイン名 | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | システム環境 | `string` | n/a | yes |
| <a name="input_hosted_zone_id"></a> [hosted\_zone\_id](#input\_hosted\_zone\_id) | ホストゾーンID | `string` | n/a | yes |
| <a name="input_lb_certificate_arn"></a> [lb\_certificate\_arn](#input\_lb\_certificate\_arn) | Certificate ARN（ap-northeast-1） | `string` | n/a | yes |
| <a name="input_lb_deregistration_delay"></a> [lb\_deregistration\_delay](#input\_lb\_deregistration\_delay) | ターゲットを登録解除する前に ALBが待機する時間（0～3600s） | `number` | `120` | no |
| <a name="input_lb_health_check_healthy_threshold"></a> [lb\_health\_check\_healthy\_threshold](#input\_lb\_health\_check\_healthy\_threshold) | 非正常なインスタンスが正常であると見なすまでに必要なヘルスチェックの連続成功回数（2～10） | `number` | `5` | no |
| <a name="input_lb_health_check_interval"></a> [lb\_health\_check\_interval](#input\_lb\_health\_check\_interval) | 個々のターゲットのヘルスチェックの概算間隔（5~300s） | `number` | `30` | no |
| <a name="input_lb_health_check_matcher"></a> [lb\_health\_check\_matcher](#input\_lb\_health\_check\_matcher) | ターゲットからの正常なレスポンスを確認するために使用するコード | `string` | `"200-299"` | no |
| <a name="input_lb_health_check_path"></a> [lb\_health\_check\_path](#input\_lb\_health\_check\_path) | ヘルスチェックの送信先 | `string` | `"/"` | no |
| <a name="input_lb_health_check_timeout"></a> [lb\_health\_check\_timeout](#input\_lb\_health\_check\_timeout) | ヘルスチェックを失敗と見なす、ターゲットからレスポンスがない時間（2～120s） | `number` | `5` | no |
| <a name="input_lb_health_check_unhealthy_threshold"></a> [lb\_health\_check\_unhealthy\_threshold](#input\_lb\_health\_check\_unhealthy\_threshold) | 非正常なインスタンスが非正常であると見なすまでに必要なヘルスチェックの連続失敗回数（2～10） | `number` | `2` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | ロードバランサーを配置するサブネットのID | `list(string)` | n/a | yes |
| <a name="input_rds_secrets_arn"></a> [rds\_secrets\_arn](#input\_rds\_secrets\_arn) | RDS Credentials Secrets ARN | `string` | n/a | yes |
| <a name="input_task_cpu"></a> [task\_cpu](#input\_task\_cpu) | タスクCPUユニット数 | `number` | `256` | no |
| <a name="input_task_memory"></a> [task\_memory](#input\_task\_memory) | タスクに適用されるメモリ量 | `number` | `512` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | アプリケーションをデプロイするVPCのID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lb_dns_name"></a> [lb\_dns\_name](#output\_lb\_dns\_name) | ロードバランサーDNS名 |
| <a name="output_lb_id"></a> [lb\_id](#output\_lb\_id) | ロードバランサーID |
<!-- END_TF_DOCS -->