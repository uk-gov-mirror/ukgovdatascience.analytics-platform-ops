resource "aws_elb" "cluster_ingress" {
  name            = "ingress-${var.env}"
  security_groups = ["${aws_security_group.cluster_ingress_elb.id}"]
  subnets         = ["${var.subnet_ids}"]

  idle_timeout    = 3600
  cross_zone_load_balancing = true

  tags {
    Environment = "${var.env}"
    Name = "ingress.${var.cluster_fqdn}"
  }

  listener {
    instance_port     = "${var.instance_http_port}"
    instance_protocol = "tcp"
    lb_port           = 80
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = "${var.instance_https_port}"
    instance_protocol = "tcp"
    lb_port           = 443
    lb_protocol       = "ssl"
    ssl_certificate_id = "${data.aws_acm_certificate.cluster_ingress.arn}"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 6
    target = "TCP:${var.instance_http_port}"
    interval = 10
    timeout = 5
  }
}

resource "aws_proxy_protocol_policy" "cluster_ingress" {
  load_balancer  = "${aws_elb.cluster_ingress.name}"
  instance_ports = [
    "${var.instance_http_port}",
    "${var.instance_https_port}"
  ]
}

resource "aws_autoscaling_attachment" "cluster_ingress_nodes" {
  elb                    = "${aws_elb.cluster_ingress.id}"
  autoscaling_group_name = "${var.ingress_asg_id}"
}
