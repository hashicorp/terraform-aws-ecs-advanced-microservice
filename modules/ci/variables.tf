# Copyright (c) HashiCorp, Inc.

variable "waypoint_project" {
  type        = string
  description = <<EOF
Name of the Waypoint project. This will be hte name of the GitHub repo which is
created.
EOF
}

variable "github_org_name" {
  type        = string
  description = <<EOF
The GitHub owner of the template GitHub repository and the owner of the
repository to be created. This token needs permissions to create, update and
delete repos. The template GitHub repo is also expected to be in this org.
EOF
}

variable "template_repo_name" {
  type        = string
  description = <<EOF
The name of the GitHub repository which will be used as a template for the repo
which is created for the app. It is expected to be in the same GitHub org as the
repository to be created.
EOF
}

variable "github_token" {
  type        = string
  sensitive   = true
  description = "The token used to copy a GitHub repo template for the new Waypoint project's repo."
}

variable "git_user" {
  type        = string
  description = "The user for the git commit which renders the repo template."
}

variable "git_email" {
  type        = string
  description = "The email address for the git commit which renders the repo template."
}

variable "git_repo_visibility" {
  type        = string
  description = "The visibility of the new GitHub repo. Must be 'private', 'internal', or 'public'."
}

variable "aws_region" {
  type        = string
  description = "The AWS region of the ECR to where the project's images will be pushed by GitHub Actions."
}

variable "aws_account_id" {
  type        = string
  sensitive   = true
  description = "The ID of the AWS account used for the AWS auth method in Vault."
}

variable "waypoint_address" {
  type        = string
  description = "The address of the Waypoint server. This will be stored in the new repo's secrets."
  sensitive   = true
}

variable "waypoint_token" {
  type        = string
  description = <<EOF
A Waypoint token with access to your server. This will be stored in the new
repo's secrets."
EOF
  sensitive   = true
}
