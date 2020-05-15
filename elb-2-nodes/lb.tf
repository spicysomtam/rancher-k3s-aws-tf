resource "aws_elb" "lb" {
  name              = "${var.prefix}-rancher"
  subnets           = data.aws_subnet_ids.default.ids
  internal          = var.nlb-internal

  listener {
    instance_port     = 80
    instance_protocol = "tcp"
    lb_port           = 80
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = 443
    instance_protocol = "tcp"
    lb_port           = 443
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:443"
    interval            = 30
  }

  instances                   = aws_instance.k3s.*.id
  security_groups             = [aws_security_group.k3s.id]
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "${var.prefix}-rancher"
  }
}