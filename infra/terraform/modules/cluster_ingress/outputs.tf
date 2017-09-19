output "elb_id" {
  value = "${aws_elb.cluster_ingress.id}"
}

output "elb_dns_name" {
  value = "${aws_elb.cluster_ingress.dns_name}"
}

output "elb_zone_id" {
  value = "${aws_elb.cluster_ingress.zone_id}"
}

output "elb_sg_id" {
  value = "${aws_security_group.cluster_ingress_elb.id}"
}
