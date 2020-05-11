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
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.inst-type
  count = var.num-servers
  iam_instance_profile = aws_iam_instance_profile.k3s-server.name
  key_name = var.key-pair
  availability_zone = data.aws_availability_zones.available.names[count.index]
  security_groups = [aws_security_group.k3s.name]
  user_data = templatefile("server-userdata.tmpl", { 
    pwd = var.mysql-password, 
    host = aws_db_instance.k3s.address, 
    helm-repo = var.rancher-helm-repo, 
    dns-name = var.rancher-dns-name,
    inst-id = count.index
  })
  depends_on = [ aws_db_instance.k3s, aws_security_group.k3s-mysql ]

  tags = {
    Name = "rancherK3s${count.index}"
  }
}
