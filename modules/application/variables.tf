variable "availability_zones" {
  type        = list(string)
  description = "アベイラビリティゾーン"
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}
variable "environment" {
  type        = string
  description = "システム環境"
}
variable "hosted_zone_id" {
  type        = string
  description = "ホストゾーンID"
}
variable "domain_name" {
  type        = string
  description = "ドメイン名"
}
variable "lb_certificate_arn" {
  type        = string
  description = "Certificate ARN（ap-northeast-1）"
}
variable "lb_deregistration_delay" {
  type        = number
  description = "ターゲットを登録解除する前に ALBが待機する時間（0～3600s）"
  default     = 120
}
variable "lb_health_check_matcher" {
  type        = string
  description = "ターゲットからの正常なレスポンスを確認するために使用するコード"
  default     = "200-299"
}
variable "lb_health_check_healthy_threshold" {
  type        = number
  description = "非正常なインスタンスが正常であると見なすまでに必要なヘルスチェックの連続成功回数（2～10）"
  default     = 5
}
variable "lb_health_check_unhealthy_threshold" {
  type        = number
  description = "非正常なインスタンスが非正常であると見なすまでに必要なヘルスチェックの連続失敗回数（2～10）"
  default     = 2
}
variable "lb_health_check_interval" {
  type        = number
  description = "個々のターゲットのヘルスチェックの概算間隔（5~300s）"
  default     = 30
}
variable "lb_health_check_timeout" {
  type        = number
  description = "ヘルスチェックを失敗と見なす、ターゲットからレスポンスがない時間（2～120s）"
  default     = 5
}
variable "lb_health_check_path" {
  type        = string
  description = "ヘルスチェックの送信先"
  default     = "/"
}
variable "task_cpu" {
  type        = number
  description = "タスクCPUユニット数"
  default     = 256
}
variable "task_memory" {
  type        = number
  description = "タスクに適用されるメモリ量"
  default     = 512
}
variable "container_name" {
  type        = string
  description = "コンテナ名"
}
variable "container_image_uri" {
  type        = string
  description = "コンテナイメージURI"
}
variable "container_port" {
  type        = number
  description = "コンテナポート"
}
variable "container_cpu" {
  type        = number
  description = "コンテナCPUユニット数"
  default     = 256
}
variable "container_memory" {
  type        = number
  description = "コンテナに適用されるメモリ量"
  default     = 512
}
variable "vpc_id" {
  type        = string
  description = "アプリケーションをデプロイするVPCのID"
}
variable "public_subnet_ids" {
  type        = list(string)
  description = "ロードバランサーを配置するサブネットのID"
}
variable "application_subnet_ids" {
  type        = list(string)
  description = "アプリケーションコンテナを起動するサブネットのID"
}
variable "cf_domain_name" {
  type        = string
  description = "CloudFrontドメイン名"
}
variable "cf_hosted_zone_id" {
  type        = string
  description = "CloudFrontホストゾーンID"
}
variable "rds_secrets_arn" {
  type        = string
  description = "RDS Credentials Secrets ARN"
}