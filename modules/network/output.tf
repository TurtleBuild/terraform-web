output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}
output "public_subnet_ids" {
  description = "Public Subnet IDs"
  value       = [for value in aws_subnet.public : value.id]
}
output "application_subnet_ids" {
  description = "Application Subnet IDs"
  value       = [for value in aws_subnet.private_app : value.id]
}
output "database_subnet_ids" {
  description = "Database Subnet IDs"
  value       = [for value in aws_subnet.private_db : value.id]
}
output "private_route_table_ids" {
  description = "Private Route Table IDs"
  value       = [for value in aws_route_table.private : value.id]
}