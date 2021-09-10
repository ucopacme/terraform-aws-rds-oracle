

-->

Terraform module to provision AWS [`RDS ORACLE`](https://aws.amazon.com/rds/) instances



## Introduction

The module will create:

* DB instance (ORACLE)
* DB Option Group (will use the default )
* DB Parameter Group (will use the default)
* DB Subnet Group
* DB Security Group
* Randome Password
* secret manager



## Usage
Create terragrunt.hcl config file and past the following configuration.


```hcl

#
# Include all settings from root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}


# dependency "sg" {
#   config_path = "../sg_test"
# }

inputs = {
  enabled                 = true
  subnet_ids              = ["subnet-0ece5975ca259796e", "subnet-084c56f1fd8699660"]
  allocated_storage       = "30"
  max_allocated_storage   = "50"
  engine                  = "oracle-ee" 
  identifier              = "rds-test-oracle"
  engine_version          = "19.0.0.0.ru-2021-07.rur-2021-07.r1"
  instance_class          = "db.t3.large"
  secret_manager_name     = "secret-manager-rds-test-kk-oracles"
  publicly_accessible     = true
  deletion_protection     = false
  apply_immediately       = true
  backup_retention_period = "14"
  vpc_security_group_ids  = [dependency.sg.outputs.sg_id]
  license_model           = "bring-your-own-license"
  tags = {
    "ucop:application" = "test"
    "ucop:createdBy"   = "Terraform"
    "ucop:enviroment"  = "Prod"
    "ucop:group"       = "CHS"
    "ucop:source"      = join("/", ["https://github.com/ucopacme/ucop-terraform-config/tree/master/terraform/its-chs-dev/us-west-2", path_relative_to_include()])
  }

}

terraform {
   source = "git::https://git@github.com/ucopacme/terraform-aws-rds-oracle.git//?ref=v0.0.1"


}
