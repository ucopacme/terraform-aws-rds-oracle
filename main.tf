data "aws_caller_identity" "this" {}

# create RDS ORACLE  db instance
resource "aws_db_instance" "this" {
  count                           = var.enabled ? 1 : 0
  allocated_storage               = var.allocated_storage
  allow_major_version_upgrade     = var.allow_major_version_upgrade
  auto_minor_version_upgrade      = var.auto_minor_version_upgrade
  max_allocated_storage           = var.max_allocated_storage
  maintenance_window              = var.maintenance_window
  monitoring_interval             = var.monitoring_interval
  backup_retention_period         = var.backup_retention_period
  backup_window                   = var.backup_window
  deletion_protection             = var.deletion_protection
  db_subnet_group_name            = aws_db_subnet_group.this.*.id[0]
  engine                          = var.engine
  engine_version                  = var.engine_version
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  identifier                      = var.identifier
  instance_class                  = var.instance_class
  manage_master_user_password     = var.manage_master_user_password ? true : null
  username                        = var.manage_master_user_password ? var.username : jsondecode(aws_secretsmanager_secret_version.this[0].secret_string)["username"]
  password                        = var.manage_master_user_password ? null : jsondecode(aws_secretsmanager_secret_version.this[0].secret_string)["password"]
  parameter_group_name            = var.parameter_group_name
  option_group_name               = var.option_group_name
  skip_final_snapshot             = var.skip_final_snapshot
  copy_tags_to_snapshot           = var.copy_tags_to_snapshot
  storage_encrypted               = var.storage_encrypted
  storage_type                    = var.storage_type
  storage_throughput              = var.storage_type != "gp3" ? null : var.storage_throughput
  iops                            = var.storage_type == "gp2" ? null : var.iops
  vpc_security_group_ids          = var.vpc_security_group_ids
  publicly_accessible             = var.publicly_accessible
  apply_immediately               = var.apply_immediately
  kms_key_id                      = var.create_cmk ? aws_kms_key.this.*.arn[0] : var.kms_key_id
  license_model                   = var.license_model
  port                            = var.port
  performance_insights_enabled    = var.performance_insights_enabled
  tags                            = var.tags
  multi_az                        = var.multi_az
  final_snapshot_identifier       = var.final_snapshot_identifier_prefix

  depends_on = [
    aws_db_subnet_group.this,
    aws_secretsmanager_secret.this,
    aws_secretsmanager_secret_version.this

  ]
}


# create db subnet group
resource "aws_db_subnet_group" "this" {
  count       = var.enabled ? 1 : 0
  name        = "${var.identifier}-subnet-group"
  description = "Created by terraform"
  subnet_ids  = var.subnet_ids
  tags        = var.tags
}


#  create a random generated password which we will use in secrets.
resource "random_password" "password" {
  length           = 12
  special          = true
  min_special      = 2
  override_special = "_%"
}


# create secret and secret versions for database master account

resource "aws_secretsmanager_secret" "this" {
  count                   = var.manage_master_user_password ? 0 : 1
  name                    = var.secret_manager_name
  recovery_window_in_days = 7
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "this" {
  count         = var.manage_master_user_password ? 0 : 1
  secret_id     = aws_secretsmanager_secret.this[0].id
  secret_string = <<EOF
   {
    "username": "${var.username}",
    "password": "${random_password.password.result}"
   }
EOF
  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "aws_kms_key" "this" {
  count                    = var.create_cmk ? 1 : 0
  description              = "CMK for RDS instance ${var.identifier}"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  multi_region             = var.cmk_multi_region
  policy                   = data.aws_iam_policy_document.this.json
  tags                     = var.tags
}

resource "aws_kms_alias" "this" {
  count         = var.create_cmk ? 1 : 0
  name          = "alias/ucop/rds/${var.identifier}"
  target_key_id = aws_kms_key.this.*.key_id[0]
}

data "aws_iam_policy_document" "this" {
  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"]
    }
  }

  statement {
    sid       = "Allow use of the key"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    principals {
      type        = "AWS"
      identifiers = [for account_id in concat([data.aws_caller_identity.this.account_id], var.cmk_allowed_aws_account_ids) : "arn:aws:iam::${account_id}:root"]
    }
  }

  statement {
    sid       = "Allow attachment of persistent resources"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant",
    ]

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }

    principals {
      type        = "AWS"
      identifiers = [for account_id in concat([data.aws_caller_identity.this.account_id], var.cmk_allowed_aws_account_ids) : "arn:aws:iam::${account_id}:root"]
    }
  }
}
