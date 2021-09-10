# Output the Endpoint(w/ port) of the RDS instance
output "rds_endpoint" {
  description = "RDS EndPoint"
  value       = join("", aws_db_instance.this.*.endpoint)
}

# Output the ID of the RDS instance
output "rds_instance_name" {
  value = join("", aws_db_instance.this.*.id)
}

# Output only Address of RDS instance
output "rds_address" {
  value = join("", aws_db_instance.this.*.address)
}

output "secret_manager_id" {
  description = "[secret id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret#id)"
  value       = join("", aws_secretsmanager_secret.this.*.id)
}

output "secret_manager_name" {
  description = "[secret id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret#id)"
  value       = join("", aws_secretsmanager_secret.this.*.name)
}