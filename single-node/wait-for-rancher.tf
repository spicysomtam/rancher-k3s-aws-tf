resource "null_resource" "wait_for_rancher" {
  provisioner "local-exec" {
    command = <<EOF
while [ "$response" != "ok" ]
do
    response=$(curl -m 2 -ksSH "Host:${var.rancher_dns_name}" "https://${aws_instance.k3s.public_dns}/healthz" 2>&1)
    echo Rancher health check: $response
    [ "$response" != "ok" ] && sleep 10
done
true
EOF
  }
  depends_on = [
    aws_instance.k3s
  ]
}