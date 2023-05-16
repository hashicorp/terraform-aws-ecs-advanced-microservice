variable "repo_name" {
  type = string
}

variable "github_org_name" {
  type = string
}

variable "template_repo_name" {
  type = string
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