variable "environment" {
  type        = string
  description = "システム環境"
}
variable "vpc_name" {
  type        = string
  description = "VPC 識別名"
}
variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
}
variable "public_subnets" {
  type        = list(map(string))
  description = "Public サブネット"
}
variable "application_subnets" {
  type        = list(map(string))
  description = "Private サブネット（NAT Gateway へのルーティングあり）"
}
variable "database_subnets" {
  type        = list(map(string))
  description = "Private サブネット（NAT Gateway へのルーティングなし）"
}
