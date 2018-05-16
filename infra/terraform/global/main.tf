terraform {
  backend "s3" {
    bucket = "terraform.analytics.justice.gov.uk"
    key    = "base/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = "${var.region}"
}

data "aws_caller_identity" "current" {}

module "aws_account_logging" {
    source = "../modules/aws_account_logging"

    es_domain = "${var.es_domain}"
    es_port = "${var.es_port}"
    es_scheme = "${var.es_scheme}"
    es_username = "${var.es_username}"
    es_password = "${var.es_password}"

    cloudtrail_s3_bucket_arn = "${aws_s3_bucket.global_cloudtrail.arn}"
    cloudtrail_s3_bucket_id = "${aws_s3_bucket.global_cloudtrail.id}"

    account_id = "${data.aws_caller_identity.current.account_id}"
}

module "log_pruning" {
    source = "../modules/log_pruning"

    curator_conf = <<EOF
- name: main
  endpoint: ${var.es_scheme}://${var.es_username}:${var.es_password}@${var.es_domain}:${var.es_port}
  indices:
    - prefix: s3logs-
      days: 30
    - prefix: cloudtrail-
      days: 30
    - prefix: logstash-dev-
      days: 2
    - prefix: logstash-apps-dev-
      days: 2
    - prefix: logstash-alpha-
      days: 30
    - prefix: logstash-apps-alpha-
      days: 30
EOF
}

// Backup etcd volumes attached to kubernetes masters -->

# Create Snapshot policy document
data "template_file" "lambda_create_snapshot_policy" {
  template = "${file("assets/create_etcd_ebs_snapshot/lambda_create_snapshot_policy.json")}"
}

# Lambda requires that we zip the distribution in order to deploy it
data "archive_file" "kubernetes_etcd_ebs_snapshot_code" {
  source_file = "assets/create_etcd_ebs_snapshot/create_etcd_ebs_snapshot"
  output_path = "assets/create_etcd_ebs_snapshot/create_etcd_ebs_snapshot.zip"
  type        = "zip"
}

module "kubernetes_etcd_ebs_snapshot" {
  source               = "../modules/lambda_mgmt"
  lambda_function_name = "create_etcd_ebs_snapshot"
  zipfile              = "assets/create_etcd_ebs_snapshot/create_etcd_ebs_snapshot.zip"
  handler              = "create_etcd_ebs_snapshot"
  source_code_hash     = "${data.archive_file.kubernetes_etcd_ebs_snapshot_code.output_base64sha256}"
  tag_key              = "k8s.io/role/master"
  tag_value            = "1"
  lamda_policy         = "${data.template_file.lambda_create_snapshot_policy.rendered}"
}
// -->
