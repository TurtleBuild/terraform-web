output "lb_id" {
  description = "ロードバランサーID"
  value       = aws_lb.main.id
}
output "lb_dns_name" {
  description = "ロードバランサーDNS名"
  value       = aws_lb.main.dns_name
}