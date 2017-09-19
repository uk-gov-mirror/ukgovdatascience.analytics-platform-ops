variable "env" {}

variable "vpc_id" {}

variable "cluster_fqdn" {}

variable "ingress_asg_id" {}

variable "dns_zone_id" {}

variable "subnet_ids" {
  type = "list"
}

variable "instance_http_port" {
  default = 30080
}

variable "instance_https_port" {
  default = 30443
}

variable "wildcard_subdomains" {
  default = [
    "apps",
    "services",
    "tools"
  ]
}
