variable "bastion_name" {
  type        = string
  description = "踏み台インスタンス識別名"
}
variable "subnet_ids" {
  type        = list(string)
  description = "踏み台インスタンスを配置するサブネットのID"
}
variable "bastion_user" {
  type        = string
  description = "踏み台にアクセスするユーザー"
  default     = "ec2-user"
}