variable "environment" {
  type        = string
  description = "システム環境"
}
variable "distribution_name" {
  type        = string
  description = "Distribution 識別名"
}
variable "aliases" {
  type        = list(string)
  description = "エイリアス"
}
variable "certificate_arn" {
  type        = string
  description = "Certificate ARN（us-east-1）"
}
variable "origin_read_timeout" {
  type        = number
  description = "CloudFrontがオリジンからのレスポンスを待つ時間（4〜60s）"
  default     = 60
}
variable "origin_keepalive_timeout" {
  type        = number
  description = "CloudFront-オリジン間のTCP接続を持続させる有効時間（1〜60s）"
  default     = 5
}
variable "web_acl_id" {
  type        = string
  description = "Web ACL ID"
}
variable "lb_id" {
  type        = string
  description = "ロードバランサーID"
}
variable "lb_dns_name" {
  type        = string
  description = "ロードバランサーDNS名"
}
