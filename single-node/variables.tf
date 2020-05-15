#
# Variables Configuration
#

variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "eu-west-1"
}

variable "ec2_inst_type" {
  description = "k3s server instance type."
  default     = "t3a.medium"
}

variable "prefix" {
  description = "Prefix for deploy for aws resources`."
}

# Allowing access from everything is probably not secure; so please override this to your requirement.
variable "rancher_ingress_cidrs" {
  description = "External ips allowed access to rancher."
  default     = ["0.0.0.0/0"]
  type        = list(string)
}

# Allowing access from everything is probably not secure; so please override this to your requirement.
variable "ssh_ingress_cidrs" {
  description = "External ips allowed access to k3s servers via ssh."
  default     = ["0.0.0.0/0"]
  type        = list(string)
}

variable "key_pair" {
  default = "my-keypair"
}

variable "mysql_inst_type" {
  default = "db.t2.micro"
}

variable "mysql_username" {
  default = "admin"
}

variable "rancher_helm_repo" {
  default = "latest"
}

variable "rancher_dns_name" {
  default = "rancher.mydomain.com"
}
