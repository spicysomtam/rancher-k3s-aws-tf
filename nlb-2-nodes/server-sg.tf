resource "aws_security_group" "k3s" {
  name        = "${var.prefix}-RancherServer"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.lb-ingress-cidrs
  }

  ingress {
    description = "HTTPS"
    from_port   = 443 
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.lb-ingress-cidrs
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh-ingress-cidrs
  }

  ingress {
    description = "Full vpc access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-RancherServer"
  }
}