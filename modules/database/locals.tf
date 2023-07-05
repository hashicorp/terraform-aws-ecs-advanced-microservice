# Copyright (c) HashiCorp, Inc.

locals {
  db_role_name = "${var.waypoint_project}-role"
  name = lower(var.waypoint_project)
}