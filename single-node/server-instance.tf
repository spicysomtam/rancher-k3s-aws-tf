data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "k3s" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.inst-type
  iam_instance_profile = aws_iam_instance_profile.k3s-server.name
  key_name = var.key-pair
  security_groups = [aws_security_group.k3s.name]

  user_data = templatefile("server-userdata.tmpl", { 
    pwd = var.mysql-password, 
    host = aws_db_instance.k3s.address, 
    helm-repo = var.rancher-helm-repo, 
    dns-name = var.rancher-dns-name
  })
  depends_on = [ aws_db_instance.k3s, aws_security_group.k3s-mysql ]

  tags = {
    Name = "${var.prefix}-RancherS0"
  }
}