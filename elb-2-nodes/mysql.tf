resource "aws_db_instance" "k3s" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7.22"
  instance_class       = var.mysql-instance-class
  name                 = "k3s"
  identifier           = "k3s"
  username             = "admin"
  password             = var.mysql-password
  parameter_group_name = "default.mysql5.7"
  vpc_security_group_ids = [ aws_security_group.k3s-mysql.id]
  skip_final_snapshot = true
}

resource "aws_security_group" "k3s-mysql" {
  name = "k3sMysql"

  ingress {
    description = "MYSQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.k3s.id]
  }
  tags = {
    Name = "k3sMysql"
  }
}