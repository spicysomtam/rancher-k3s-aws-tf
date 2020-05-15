resource "aws_lb_target_group" "https" {
  name     = "${var.prefix}-rancher-tcp-443"
  port     = 443
  protocol = "TCP"
  target_type = "instance"
  vpc_id = data.aws_vpc.default.id

  # oddily we have to specify stickiness and then disable it to allow protocol = "TCP"!
  stickiness {
      type = "lb_cookie"
      enabled = false
  }
}

resource "aws_lb_target_group_attachment" "k3s_https" {
  target_group_arn = aws_lb_target_group.https.arn
  target_id        = aws_instance.k3s[count.index].id
  count = var.num_servers
  port             = 443
}