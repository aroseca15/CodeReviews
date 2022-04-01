resource "aws_db_subnet_group" "main" {
  name = "${local.prefix}-main"
  subnet_ids = [
    data.aws_subnet.private-1.id,
    data.aws_subnet.private-2.id
  ]

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-main" })
  )
}

resource "aws_security_group" "rds" {
  description = "Allow access to the RDS database instance."
  name        = "${local.prefix}-rds-inbound-access"
  vpc_id      = data.aws_vpc.main.id


  ingress {
    protocol  = "tcp"
    from_port = 5432
    to_port   = 5432

    security_groups = [
      aws_security_group.bastion.id,
      aws_security_group.ecs_service.id,
    ]

  }

  tags = local.common_tags
}

# data "aws_db_snapshot" "lastest-db-snaphot"{
#   db_snapshot_identifier = 
#   most_recent = true
#   snapshot_type =

# }

resource "aws_kms_key" "kms-key" {
  description             = "KMS Key 1"
  deletion_window_in_days = 10
}

resource "aws_db_instance" "main" {
  allocated_storage       = 50
  max_allocated_storage   = 500
  engine                  = "postgres"
  engine_version          = "13.4"
  instance_class          = "db.t3.large"
  storage_encrypted       = true
  kms_key_id              = aws_kms_key.kms-key.arn
  backup_retention_period = 7
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.main.name
  skip_final_snapshot     = true


  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-main" })
  )
}

# resource "aws_db_snapshot" "snapshot" {
#   db_instance_identifier = aws_db_instance.main.id
#   db_snapshot_identifier = "db_backup_shot"

#   tags = merge(
#     local.common_tags,
#     tomap({ "Name" = "${local.prefix}-main" })
#   )
# }

# resource "aws_rds_cluster" "main" {
#   cluster_identifier   = "aurora-cluster-${local.prefix}-db1"
#   database_name        = "telepsycrxdb"
#   engine               = "aurora-postgresql"
#   engine_mode          = "serverless"
#   engine_version       = "10.14"
#   enable_http_endpoint = true
#   db_subnet_group_name = aws_db_subnet_group.main.name
#   master_username      = var.db_username
#   master_password      = var.db_password
#   storage_encrypted    = true
#   kms_key_id           = aws_kms_key.kms-key.arn
#   # allocated_storage       = 2
#   # max_allocated_storage   = 384
#   backup_retention_period = 7
#   preferred_backup_window = "01:00-03:00"
#   backtrack_window        = 0
#   # restore                 = true
#   # restore_type            = "copy-on-write"
#   deletion_protection    = false
#   skip_final_snapshot    = true
#   vpc_security_group_ids = [aws_security_group.rds.id]

#   scaling_configuration {
#     auto_pause               = true
#     min_capacity             = 2
#     max_capacity             = 384
#     seconds_until_auto_pause = 300
#     timeout_action           = "ForceApplyCapacityChange"
#   }

#   tags = merge(
#     local.common_tags,
#     tomap({ "Name" = "${local.prefix}-main" })
#   )
# }
