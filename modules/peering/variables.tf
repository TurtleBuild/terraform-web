variable "accepter_vpc_id" {
  type        = string
  description = "アクセプタVPC ID"
}
variable "accepter_vpc_name" {
  type        = string
  description = "アクセプタVPC 識別名"
}
variable "accepter_vpc_cidr" {
  type        = string
  description = "アクセプタVPC CIDR"
}
variable "accepter_subnet_ids" {
  type        = list(string)
  description = "アクセプタサブネットIDs"
}
variable "accepter_subnet_cidrs" {
  type        = list(string)
  description = "アクセプタサブネットCIDRs"
}
variable "accepter_route_table_ids" {
  type        = list(string)
  description = "アクセプタルートテーブルIDs"
}
variable "requester_vpc_id" {
  type        = string
  description = "リクエスタVPC ID"
}
variable "requester_vpc_name" {
  type        = string
  description = "リクエスタVPC 識別名"
}
variable "requester_vpc_cidr" {
  type        = string
  description = "リクエスタVPC CIDR"
}
variable "requester_subnet_ids" {
  type        = list(string)
  description = "リクエスタサブネットIDs"
}
variable "requester_subnet_cidrs" {
  type        = list(string)
  description = "リクエスタサブネットCIDRs"
}
variable "requester_route_table_ids" {
  type        = list(string)
  description = "リクエスタルートテーブルIDs"
}