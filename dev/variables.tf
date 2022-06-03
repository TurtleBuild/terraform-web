variable "aws_access_key" {
  type        = string
  description = "AWSアクセスキー（terraform.tfvars で設定）"
}
variable "aws_secret_key" {
  type        = string
  description = "AWSシークレットキー（terraform.tfvars で設定）"
}
variable "aws_region" {
  type        = string
  description = "AWSリージョン"
  default     = "ap-northeast-1"
}
variable "environment" {
  type        = string
  description = "システム環境"
  default     = "dev"
}
variable "tf_role_arn" {
  type        = string
  description = "terraformを実行するロールARN（terraform.tfvars で設定）"
}
