output "license_server_id" {
  value = try(aws_instance.license_server[0].id, null)
}

output "license_server_ip_addr" {
  value = try(aws_instance.license_server[0].public_ip, null)
}

output "license_server_password" {
  value = try(rsadecrypt(try(aws_instance.license_server[0].password_data, null), file(pathexpand("~/.ssh/id_rsa"))), null)
}

output "webapp_server_id" {
  value = try(aws_instance.webapp_server[0].id, null)
}

output "webapp_server_ip_addr" {
  value = try(aws_eip.webapp_ser_eip.public_ip, null)
}

output "webapp_server_password" {
  value = try(rsadecrypt(try(aws_instance.webapp_server[0].password_data, null), file(pathexpand("~/.ssh/id_rsa"))), null)
}

output "transformation_server_id" {
  value = try(aws_instance.transformation_server[0].id, null)
}

output "transformation_server_ip_addr" {
  value = try(aws_instance.transformation_server[0].public_ip, null)
}

output "transformation_server_password" {
  value = try(rsadecrypt(try(aws_instance.transformation_server[0].password_data, null), file(pathexpand("~/.ssh/id_rsa"))), null)
}

output "reporting_server_id" {
  value = try(aws_instance.reporting_server[0].id, null)
}

output "reporting_server_ip_addr" {
  value = try(aws_instance.reporting_server[0].public_ip, null)
}

output "reporting_server_password" {
  value = try(rsadecrypt(try(aws_instance.reporting_server[0].password_data, null), file(pathexpand("~/.ssh/id_rsa"))), null)
}

output "integration_server_id" {
  value = try(aws_instance.integration_server[0].id, null)
}

output "integration_server_ip_addr" {
  value = try(aws_instance.integration_server[0].public_ip, null)
}

output "integration_server_password" {
  value = try(rsadecrypt(try(aws_instance.integration_server[0].password_data, null), file(pathexpand("~/.ssh/id_rsa"))), null)
}

output "db_ip_addr" {
  value = aws_db_instance.mssql_db.address
}

output "db_user" {
  value = aws_db_instance.mssql_db.username
}

output "db_password" {
  value = random_string.dbpwd.result
}

