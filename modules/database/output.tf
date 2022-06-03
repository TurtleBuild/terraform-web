output "rds_secrets_arn" {
  description = "RDS Credentials Secrets ARN"
  value       = aws_secretsmanager_secret.rds_credentials.arn
}