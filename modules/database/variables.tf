variable "availability_zones" {
  type        = list(string)
  description = "アベイラビリティゾーン"
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}
variable "environment" {
  type        = string
  description = "システム環境"
}
variable "rds_name" {
  type        = string
  description = "RDS 識別名"
}
variable "engine" {
  type        = string
  description = "利用するRDSエンジン"
  default     = "mysql"
}
variable "backup_retention_period" {
  type        = number
  description = "バックアップを保持する日数（リードレプリカを使用する場合は 0よりも大きい値を設定する：0〜35）"
  default     = 0
}
variable "preferred_backup_window" {
  type        = string
  description = "日次の自動バックアップウィンドウ（例：10:00-10:30）"
  default     = null
}
variable "skip_final_snapshot" {
  type        = bool
  description = "クラスター削除時にスナップショットを取得するかどうか"
  default     = true
}
variable "apply_immediately" {
  type        = bool
  description = "インスタンスへの設定変更の即時反映設定。trueにすると即時で行われ、falseにすると次回のメンテナスウィンドウで行われる。"
  default     = true
}
variable "master_username" {
  type        = string
  description = "マスターユーザー名"
  default     = "admin"
}
variable "default_schema" {
  type        = string
  description = "デフォルトのスキーマ名"
  default     = "springdb"
}
variable "vpc_id" {
  type        = string
  description = "RDSクラスタを配置するVPCのID"
}
variable "subnet_ids" {
  type        = list(string)
  description = "RDSインスタンスを配置するサブネットのID"
}
variable "application_subnet_cidrs" {
  type        = list(string)
  description = "DBへのアクセスを許可するアプリケーションが属するサブネットのID"
}
variable "bastion_vpc_cidr" {
  type        = string
  description = "DBへのアクセスを許可する踏み台インスタンスが属するサブネットのID"
}
variable "instance_class" {
  type        = string
  description = "DBインスタンスクラス"
  default     = "db.t4g.medium"
}
variable "number_of_instances" {
  type        = number
  description = "DBインスタンス数"
  default     = 1
}
variable "monitoring_interval" {
  type        = number
  description = "拡張モニタリングの間隔（1、5、10、15、30、60、0はOFF）"
  default     = 0
}