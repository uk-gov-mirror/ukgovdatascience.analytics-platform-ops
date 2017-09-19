variable "env" {}

variable "vpc_id" {}

variable "cluster_name" {}

variable "kops_bucket_arn" {}

variable "inbound_ssh_source_sg_id" {}

variable "inbound_http_cidr_blocks" {
  default = [
    "0.0.0.0/0"
  ]
}

variable "app_ingress_source_sg_id" {}

variable "inbound_app_ingress_http_port" {
  default = 30080
}

variable "inbound_app_ingress_https_port" {
  default = 30443
}
