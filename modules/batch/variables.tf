variable "environment" {
  type        = string
  description = "システム環境"
}
variable "sfn_name" {
  type        = string
  description = "ステートマシン識別名"
}
variable "event_name" {
  type        = string
  description = "イベント名"
}
variable "event_description" {
  type        = string
  description = "イベント詳細"
}
variable "event_schedule" {
  type        = string
  description = "イベントスケジュール"
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
variable "container_command" {
  type        = list(string)
  description = "コンテナに渡すコマンド"
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
  description = "バッチ構成をデプロイするVPCのID"
}
variable "application_subnet_ids" {
  type        = list(string)
  description = "バッチコンテナを起動するサブネットのID"
}
variable "rds_secrets_arn" {
  type        = string
  description = "RDS Credentials Secrets ARN"
}
