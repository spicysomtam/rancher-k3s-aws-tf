#
# Variables Configuration
#

variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "eu-west-1"
}

variable "vpc-subnets" {
  description = "vpc number of subnets/az's."
  default     = "3"
  type        = string
}

variable "inst-type" {
  description = "k3s server instance type."
  default     = "t3a.medium"
  type        = string
}

# Allowing access from everything is probably not secure; so please override this to your requirement.
variable "rancher-ingress-cidrs" {
  description = "External ips allowed access to rancher."
  default     = ["0.0.0.0/0"]
  type        = list(string)
}

# Allowing access from everything is probably not secure; so please override this to your requirement.
variable "ssh-ingress-cidrs" {
  description = "External ips allowed access to k3s servers via ssh."
  default     = ["0.0.0.0/0"]
  type        = list(string)
}

variable "key-pair" {
  default = "my-key-pair"
  type    = string
}

variable "mysql-password" {
  default = "ajzk8(Lpmz"
}

variable "mysql-instance-class" {
  default = "db.t2.micro"
}

variable "rancher-helm-repo" {
  default = "latest"
}

variable "rancher-dns-name" {
  default = "rancher.mydomain.com"
}