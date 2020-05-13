output "rancher_url" {
  value = "https://${var.rancher-dns-name}"
}

output "server_public_ip" {
  value = aws_instance.k3s.public_ip
}

output "server_public_dns" {
  value = aws_instance.k3s.public_dns
}

output "server_ssh_key" {
  value = var.key-pair
}