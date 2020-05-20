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
  instance_type = var.ec2_inst_type
  iam_instance_profile = aws_iam_instance_profile.k3s_server.name
  key_name = var.key_pair
  vpc_security_group_ids = [aws_security_group.k3s.id]

  user_data = templatefile("server-userdata.tmpl", { 
    pwd = random_password.mysql_password.result, 
    host = aws_db_instance.k3s.address, 
    helm-repo = var.rancher_helm_repo, 
    dns-name = var.rancher_dns_name
  })
  depends_on = [ aws_db_instance.k3s, aws_security_group.k3s_mysql ]

  tags = {
    Name = "${var.prefix}-Rancher0"
  }
}
