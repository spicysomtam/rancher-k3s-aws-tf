resource "null_resource" "wait_for_rancher" {
  provisioner "local-exec" {
    command = <<EOF
while [ "$response" != "ok" ]
do
    response=$(curl -m 2 -ksSH "Host:${var.rancher_dns_name}" "https://${aws_lb.lb.dns_name}/healthz" 2>&1)
    echo Rancher health check: $response
    [ "$response" != "ok" ] && sleep 10
done
true
EOF
  }
  depends_on = [
    aws_lb_target_group_attachment.k3s_https,
    aws_lb_target_group_attachment.k3s_http
  ]
}