resource "aws_lb_target_group" "http" {
  name     = "${var.prefix}-rancher-tcp-80"
  port     = 80
  protocol = "TCP"
  target_type = "instance"
  vpc_id = data.aws_vpc.default.id

  # oddily we have to specify stickiness and then disable it to allow protocol = "TCP"!
  stickiness {
      type = "lb_cookie"
      enabled = false
  }
}

resource "aws_lb_target_group_attachment" "k3s-http" {
  target_group_arn = aws_lb_target_group.http.arn
  target_id        = aws_instance.k3s[count.index].id
  count = var.num-servers
  port             = 80
}