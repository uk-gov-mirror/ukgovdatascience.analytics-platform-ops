resource "aws_route53_record" "wildcard_subdomains" {
  zone_id = "${var.dns_zone_id}"
  name    = "*.${element(var.wildcard_subdomains, count.index)}"
  type    = "A"

  count   = "${length(var.wildcard_subdomains)}"

  alias {
    name                   = "${aws_elb.cluster_ingress.dns_name}"
    zone_id                = "${aws_elb.cluster_ingress.zone_id}"
    evaluate_target_health = false
  }
}
