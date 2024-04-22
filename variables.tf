variable "copy_tags_to_snapshot" {
  description = "On delete, copy all Instance tags to the final snapshot"
  type        = bool
  default     = true
}
variable "password" {
  description = "RDS Password"
  type        = string
  default     = ""
}

variable "secret_id" {
  description = "secret id"
  type        = string
  default     = ""
}
variable "username" {
  type = string
  description = "Username for the master DB user."
  default = "admin"
}

variable "manage_master_user_password" {
  description = "Set to true to allow RDS to manage the master user password in Secrets Manager."
  type        = bool
  default     = false
}

variable "kms_key_id" {
  default     = null
  description = "(Optional) ARN of existing KMS encryption key to use for storage encryption"
  type        = string
}

variable "create_cmk" {
  default     = false
  description = "Create a customer-managed KMS key (CMK) to use for storage encryption"
  type        = bool
}
variable "cmk_multi_region" {
  default     = false
  description = "Create CMK as a multi-region key (no effect if create_cmk is not true)"
  type        = bool
}
variable "cmk_allowed_aws_account_ids" {
  type        = list(string)
  description = "List of other AWS account IDs that will be allowed access to the CMK (no effect if create_cmk is not true)"
  default     = []
}

variable "parameter_group_name" {
  default = "default.oracle-se2-19"
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate"
  type        = list(string)
  default     = []
}
variable "name" {
  description = "database name"
  type = string
  default = "ORACLEDB"
}
variable "enabled" {
  default     = true
  description = "Set to `false` to prevent the module from creating any resources"
  type        = bool
}
variable "skip_final_snapshot" {
  default     = true
  description = "Set to `false` to skip_final_snapshot"
  type        = bool
}
variable "storage_encrypted" {
  default     = true
  description = "Set to `false` to not encrypt the storage"
  type        = bool
}
variable "storage_type" {
  default     = "gp3"
  description = "gp2, gp3 (default), or io1."
  type        = string
}
variable "storage_throughput" {
  default     = 125
  description = "(Optional) The storage throughput value for the DB instance"
  type        = number
}
variable "iops" {
  default     = 3000
  description = "(Optional) The amount of provisioned IOPS"
  type        = number
}
variable "publicly_accessible" {
  default     = false
  description = "Set to `false` to prevent Database accessibility"
  type        = bool
}
variable "deletion_protection" {
  default     = true
  description = "Set to `false` to prevent database from deletation"
  type        = bool
}

variable "apply_immediately" {
  default     = true
  description = "Set to `false` to prevent immediate changes"
  type        = bool
}
variable "allocated_storage" {
  default     = ""
  description = "Allocate storage size"
  type        = string
}

variable "backup_retention_period" {
  default     = "14"
  description = "enable auto backup and retention"
  type        = string
}
variable "db_subnet_group_name" {
  default     = ""
  description = "Specify db subnet group"
  type        = string
}
variable "engine" {
  default     = "oracle-ee"
  description = "Specify engin name"
  type        = string
}
variable "identifier" {
  default     = ""
  description = "Specify DB name"
  type        = string
}

variable "engine_version" {
  default     = "19.0.0.0.ru-2021-07.rur-2021-07.r1"
  description = "Specify DB version"
  type        = string
}
variable "instance_class" {
  default     = ""
  description = "Specify instance type"
  type        = string
}

variable "tags" {
  default     = {}
  description = "A map of tags to add to all resources"
  type        = map(string)
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnets"
  default     = []
}

variable "secret_manager_name" {
  type = string
  description = " secret manager name"
  default = ""
}

variable "max_allocated_storage" {
  type = string
  description = "Max allocate storage"
  default = null
}

variable "license_model" {
  description = "One of license-included, bring-your-own-license, general-public-license"
  default = "bring-your-own-license"
}

variable "port" {
  description = "The port on which to accept connections"
  type = string
  default = "1521"
}

variable "multi_az" {
  default = false
}

variable "backup_window" {
  description = "When to perform DB backups"
  type        = string
  default     = "02:00-03:00"
}
variable "maintenance_window" {
  description = "When to perform DB maintenance"
  type = string
  default = "sun:05:00-sun:06:00"
}
variable "allow_major_version_upgrade" {
  default = false
}
variable "final_snapshot_identifier_prefix" {
  description = "The prefix name to use when creating a final snapshot on cluster destroy, appends a random 8 digits to name to ensure it's unique too."
  type        = string
  default     = "final"
}
variable "auto_minor_version_upgrade" {
  default = true
}
variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights is enabled or not."
  type        = bool
  default     = false
}
variable "create_monitoring_role" {
  description = "Whether to create the IAM role for RDS enhanced monitoring"
  type        = bool
  default     = false
}

variable "monitoring_interval" {
  description = "The interval (seconds) between points when Enhanced Monitoring metrics are collected"
  type        = number
  default     = 0
}

