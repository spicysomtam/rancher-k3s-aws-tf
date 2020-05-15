output "rancher_url" {
  value = "https://${var.rancher_dns_name}"
}

output "server_public_ip" {
  value = aws_instance.k3s.public_ip
}

output "server_public_dns" {
  value = aws_instance.k3s.public_dns
}

output "server_ssh_key" {
  value = var.key_pair
}

output "mysql_username" {
  value = var.mysql_username
}

output "mysql_password" {
  value = random_password.mysql_password.result
}

output "deployment_prefix" {
  value = var.prefix
}