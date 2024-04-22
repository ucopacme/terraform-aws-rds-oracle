

-->

Terraform module to provision AWS [`RDS ORACLE`](https://aws.amazon.com/rds/) instances



## Introduction

The module will create:

* DB instance (ORACLE)
* DB Option Group (will use the default)
* DB Parameter Group (will use the default)
* DB Subnet Group
* DB Security Group
* Randome Password
* secret manager



## Usage
Create terragrunt.hcl config file and past the following configuration.


```hcl

#

 resource "aws_db_parameter_group" "this" {
  name   = "dev-oracle-ee-19"
  family = "oracle-ee-19"
  # parameter {
  #   name  = "character_set_client"
  #   value = "utf8"
  # }
  # parameter {
  #   name  = "character_set_connection"
  #   value = "utf8"
  # }
  # parameter {
  #   name  = "character_set_database"
  #   value = "utf8"
  # }
  # parameter {
  #   name  = "character_set_filesystem"
  #   value = "utf8"
  # }
  # parameter {
  #   name  = "character_set_results"
  #   value = "utf8"
  # }
  # parameter {
  #   name  = "character_set_server"
  #   value = "utf8"
  # }

  # parameter {
  #   name  = "general_log"
  #   value = "1"
  # }

  # parameter {
  #   name  = "slow_query_log"
  #   value = "1"
  # }

  tags = local.tags
}

module "sg" {
  enabled                = true
  source                 = "git::https://git@github.com/ucopacme/terraform-aws-security-group.git//"
  name                   = join("-", [local.application, local.environment, "rds", "sg"])
  vpc_id                 = local.vpc_id
  revoke_rules_on_delete = false
  ingress = [
    {
      type        = "ingress"
      from_port   = 1521
      to_port     = 1521
      protocol    = "tcp"
      cidr_blocks = ["10.48.64.0/19"]
      self        = null
      description = "Allow MySQL from SDSC /19"
    },
    {
      type        = "ingress"
      from_port   = 1521
      to_port     = 1521
      protocol    = "tcp"
      cidr_blocks = ["10.49.208.20/32"]
      self        = null
      description = "Allow MySQL from Dev EC2"
    },
  ]
  egress = [
    {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "all"
      cidr_blocks = ["0.0.0.0/0"]
      self        = null
      description = "Allow egress to anywhere"
    }
  ]
  tags = merge(tomap({ "Name" = join("-", [local.application, local.environment, "rds", "sg"]) }), local.tags)
}

module "ora" {
  source                       = "git::https://git@github.com/ucopacme/terraform-aws-rds-oracle.git//?ref=v0.0.3"
  subnet_ids                   = [local.data_subnet_ids[0], local.data_subnet_ids[1]]
  allocated_storage            = "200"
  max_allocated_storage        = "300"
  engine                       = "oracle-ee" ### (oracle-ee, oracle-se, oracle-se1, oracle-se2)
  identifier                   = "dev-ora-01"
  manage_master_user_password  = true
  engine_version               = "19.0.0.0.ru-2024-01.rur-2024-01.r1"
  instance_class               = "db.m5.large"
  storage_type                 = "gp2"
  publicly_accessible          = false
  parameter_group_name         = aws_db_parameter_group.this.name
  deletion_protection          = true
  apply_immediately            = true
  backup_retention_period      = 14
  performance_insights_enabled = false
  #enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  vpc_security_group_ids = [module.sg.id]
  kms_key_id             = local.kms_key_arn
  tags                   = local.tags
}
