#
# Variables Configuration
#

variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "eu-west-1"
}

variable "inst-type" {
  description = "k3s server instance type."
  default     = "t3a.medium"
  type        = string
}

variable "prefix" {
  description = "Prefix for deploy for aws resources`."
  default     = "r1"
  type        = string
}

variable "num-servers" {
  description = "Number of k3s server instances to deploy."
  default = "2"
  type    = string
}

# flag to set if its internal is true or false
variable "nlb-internal" {
  default = false
  type = bool
}

variable "lb-ingress-cidrs" {
  description = "External ips allowed access to k3s servers via the lb."
  default     = ["0.0.0.0/0"]
  type        = list(string)
}

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
