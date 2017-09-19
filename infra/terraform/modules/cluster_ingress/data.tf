data "aws_acm_certificate" "cluster_ingress" {
  domain   = "${var.cluster_fqdn}"
  statuses = ["ISSUED"]
}
