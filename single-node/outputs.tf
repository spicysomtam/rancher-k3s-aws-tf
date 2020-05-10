output "rancher_url" {
  value = "https://${var.rancher-dns-name}"
}

output "k3s_server_public_ip" {
  value = aws_instance.k3s.public_ip
}

output "k3s_ssh_key" {
  value = var.key-pair
}