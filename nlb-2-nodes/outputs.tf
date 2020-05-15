output "rancher_url" {
  value = "https://${var.rancher-dns-name}"
}

output "servers_public_ips" {
  value = [aws_instance.k3s.*.public_ip]
}

output "server_ssh_key" {
  value = var.key-pair
}

output "lb_dns_name" {
  value = aws_lb.lb.dns_name       
}
