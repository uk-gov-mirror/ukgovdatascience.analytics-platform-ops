resource "aws_db_subnet_group" "control_panel_db" {
  name       = "${terraform.workspace}_control_panel_db"
  subnet_ids = var.db_subnet_ids

  tags = var.tags
}

resource "aws_security_group" "control_panel_db" {
  name   = "${terraform.workspace}_control_panel_db"
  vpc_id = var.vpc_id

  ingress {
    from_port       = "5432"
    to_port         = "5432"
    protocol        = "tcp"
    security_groups = var.ingress_security_group_ids
  }

  tags = var.tags
}

resource "aws_db_instance" "control_panel_db" {
  identifier                 = "${terraform.workspace}-control-panel-db"
  storage_type               = var.storage_type
  allocated_storage          = var.allocated_storage
  engine                     = "postgres"
  engine_version             = "9.6"
  auto_minor_version_upgrade = true
  instance_class             = "db.t2.micro"
  name                       = "controlpanel"
  username                   = var.db_username
  password                   = var.db_password
  db_subnet_group_name       = aws_db_subnet_group.control_panel_db.name
  vpc_security_group_ids     = aws_security_group.control_panel_db.*.id
  backup_retention_period    = 35
  backup_window              = "22:00-23:59"
  skip_final_snapshot        = true
  maintenance_window         = "Sat:01:00-Sat:03:00"

  tags = var.tags
}

