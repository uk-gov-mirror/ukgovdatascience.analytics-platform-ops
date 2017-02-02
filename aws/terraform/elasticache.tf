# resource "aws_elasticache_subnet_group" "storage" {
#     name = "elasticache-subnet-group"
#     subnet_ids = ["${aws_subnet.storage.*.id}"]
# }

# resource "aws_security_group" "elasticache_sessions" {
#   name = "sessions-elasticache.analytics.kops.integration.dsd.io"
#   description = "Allow inbound from k8s nodes"
#   vpc_id = "${var.vpc_id}"

#   ingress {
#       from_port = 11211
#       to_port = 11211
#       protocol = "tcp"
#       security_groups = ["${var.node_security_group_id}"]
#   }
# }

# resource "aws_elasticache_cluster" "sessions" {
#     cluster_id = "sessions-store"
#     engine = "memcached"
#     node_type = "cache.t2.micro"
#     port = 11211
#     num_cache_nodes = 3
#     parameter_group_name = "default.memcached1.4"
#     maintenance_window = "sun:01:00-sun:07:00"
#     subnet_group_name = "${aws_elasticache_subnet_group.storage.name}"
#     az_mode = "cross-az"
#     availability_zones = "${var.zones}"
#     security_group_ids = ["${aws_security_group.elasticache_sessions.id}"]
# }

# output "elasticache_dns_name" {
#     value = "${aws_elasticache_cluster.sessions.cluster_address}"
# }
