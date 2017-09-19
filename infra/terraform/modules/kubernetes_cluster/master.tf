resource "aws_autoscaling_group" "master" {
  depends_on           = [ "null_resource.create_cluster" ]
  count                = "${data.template_file.master_resource_count.rendered}"
  name                 = "master-${data.aws_region.current.name}${element(split(",", data.template_file.az_letters.rendered), count.index)}.masters.${var.cluster_fqdn}"
  vpc_zone_identifier  = ["${element(var.vpc_private_subnet_ids, count.index)}"]
  launch_configuration = "${element(aws_launch_configuration.master.*.id, count.index)}"
  load_balancers       = [
    "${aws_elb.master.name}"
  ]
  max_size         = 1
  min_size         = 1
  desired_capacity = 1

  tag = {
    key                 = "KubernetesCluster"
    value               = "${var.cluster_fqdn}"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "master-${data.aws_region.current.name}${element(split(",", data.template_file.az_letters.rendered), count.index)}.masters.${var.cluster_fqdn}"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/master"
    value               = "1"
    propagate_at_launch = true
  }
}

resource "aws_elb" "master" {
  name            = "master-${var.cluster_name}"
  subnets         = ["${var.vpc_public_subnet_ids}"]
  security_groups = [
    "${aws_security_group.master_elb.id}",
    "${var.sg_allow_http_s}",
    "${var.sg_masters_extra}"
  ]
  listener {
    instance_port     = 443
    instance_protocol = "tcp"
    lb_port           = 443
    lb_protocol       = "tcp"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:443"
    interval            = 30
  }
  tags {
    Name              = "${var.cluster_name}_master"
    KubernetesCluster = "${var.cluster_fqdn}"
  }
}

resource "aws_route53_record" "master_elb" {
  name = "api.${var.cluster_fqdn}"
  type = "A"

  alias = {
    name                   = "${aws_elb.master.dns_name}"
    zone_id                = "${aws_elb.master.zone_id}"
    evaluate_target_health = false
  }

  zone_id = "/hostedzone/${var.route53_zone_id}"
}

resource "aws_security_group" "master" {
  name        = "masters.${var.cluster_fqdn}"
  vpc_id      = "${var.vpc_id}"
  description = "${var.cluster_name} master"
  tags = {
    Name              = "masters.${var.cluster_fqdn}"
    KubernetesCluster = "${var.cluster_fqdn}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "master_elb_to_master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.master.id}"
  source_security_group_id = "${aws_security_group.master_elb.id}"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
}

resource "aws_security_group" "master_elb" {
  name        = "${var.cluster_name}-master-elb"
  vpc_id      = "${var.vpc_id}"
  description = "${var.cluster_name} master ELB"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "${var.cluster_name}_master_elb"
  }
}

data "template_file" "master_user_data" {
  count    = "${data.template_file.master_resource_count.rendered}"
  template = "${file("${path.module}/data/nodeup/${var.kubernetes_version}.tpl")}"
  vars {
    cluster_fqdn           = "${var.cluster_fqdn}"
    kops_s3_bucket_id      = "${var.kops_s3_bucket_id}"
    instance_group_name    = "master-${data.aws_region.current.name}${element(split(",", data.template_file.az_letters.rendered), count.index)}"
    kubernetes_master_tag  = "- _kubernetes_master"
  }
}

resource "aws_launch_configuration" "master" {
  count                = "${data.template_file.master_resource_count.rendered}"
  name_prefix          = "master-${data.aws_region.current.name}${element(split(",", data.template_file.az_letters.rendered), count.index)}.masters.${var.cluster_fqdn}-"
  image_id             = "${data.aws_ami.kops_ami.id}"
  instance_type        = "${var.master_instance_type}"
  key_name             = "${var.instance_key_name}"
  iam_instance_profile = "${var.master_iam_instance_profile}"
  user_data            = "${file("${path.module}/data/user_data.sh")}${element(data.template_file.master_user_data.*.rendered, count.index)}"

  security_groups      = [
    "${aws_security_group.master.id}",
    "${var.sg_allow_ssh}"
  ]

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 64
    delete_on_termination = true
  }

  ephemeral_block_device = {
    device_name  = "/dev/sdc"
    virtual_name = "ephemeral0"
  }

  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_ebs_volume" "etcd-events" {
  count             = "${data.template_file.master_resource_count.rendered}"
  availability_zone = "${element(sort(var.availability_zones), count.index)}"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster    = "${var.cluster_fqdn}"
    Name                 = "${element(split(",", data.template_file.az_letters.rendered), count.index)}.etcd-events.${var.cluster_fqdn}"
    "k8s.io/etcd/events" = "${element(split(",", data.template_file.az_letters.rendered), count.index)}/${data.template_file.etcd_azs.rendered}"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_ebs_volume" "etcd-main" {
  count             = "${data.template_file.master_resource_count.rendered}"
  availability_zone = "${element(sort(var.availability_zones), count.index)}"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster    = "${var.cluster_fqdn}"
    Name                 = "${element(split(",", data.template_file.az_letters.rendered), count.index)}.etcd-main.${var.cluster_fqdn}"
    "k8s.io/etcd/main"   = "${element(split(",", data.template_file.az_letters.rendered), count.index)}/${data.template_file.etcd_azs.rendered}"
    "k8s.io/role/master" = "1"
  }
}
