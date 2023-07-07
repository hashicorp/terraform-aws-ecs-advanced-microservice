# Copyright (c) HashiCorp, Inc.

resource "github_repository" "templated_app_repository" {
  name = var.waypoint_project

  visibility = var.git_repo_visibility

  template {
    owner                = var.github_org_name
    repository           = var.template_repo_name
    include_all_branches = false # Script only templates the main branch
  }

  provisioner "local-exec" {
    command     = "./scripts/render-repo.sh"
    interpreter = ["bash"]
    environment = {
      WAYPOINT_PROJECT_NAME = var.waypoint_project
      # the lower-cased version of the project name is needed for AWS ECR login
      WAYPOINT_PROJECT_NAME_LOWER = lower(var.waypoint_project)
      GITHUB_TOKEN                = var.github_token
      OWNER                       = var.github_org_name
      TEMPLATE_REPO_NAME          = var.template_repo_name
      GIT_USER                    = var.git_user
      GIT_EMAIL                   = var.git_email
      AWS_REGION                  = var.aws_region
      ROLE_NAME                   = local.github_role_name
      AWS_ACCOUNT_ID              = var.aws_account_id
    }
  }

  # NOTE(izaak): This step will be replaced in the future with a waypoint terraform
  # provider resource
  provisioner "local-exec" {
    command     = "./scripts/project-datasource.sh"
    interpreter = ["bash"]
    environment = {
      WAYPOINT_SERVER_TOKEN = var.waypoint_token
      WAYPOINT_PROJECT_NAME = var.waypoint_project
      OWNER                 = var.github_org_name
      GITHUB_TOKEN          = var.github_token
      GIT_USER              = var.git_user
    }
  }

  provisioner "local-exec" {
    command     = "./scripts/trigger-repo-init.sh"
    interpreter = ["bash"]
    environment = {
      WAYPOINT_PROJECT_NAME = var.waypoint_project
      GITHUB_TOKEN          = var.github_token
      OWNER                 = var.github_org_name
    }
  }
}

resource "github_actions_secret" "waypoint_secrets" {
  for_each = {
    WAYPOINT_SERVER_ADDR  = var.waypoint_address
    WAYPOINT_SERVER_TOKEN = var.waypoint_token
  }
  repository      = github_repository.templated_app_repository.name
  secret_name     = each.key
  plaintext_value = each.value
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Federated"
      // TODO: Pull the ARN of the OIDC provider from the day zero infra module, instead of interpolating it here
      identifiers = ["arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }

    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "token.actions.githubusercontent.com:aud"
    }

    condition {
      test     = "StringLike"
      values   = ["repo:${var.github_org_name}/${var.waypoint_project}:*"]
      variable = "token.actions.githubusercontent.com:sub"
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]
  }
}

resource "aws_iam_role" "github_actions_role" {
  name               = local.github_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage"
    ]
    ## TODO: Use an input var with the ARN of the ECR, rather than constructing it here
    resources = [
      "arn:aws:ecr:${var.aws_region}:${var.aws_account_id}:repository/${lower(var.waypoint_project)}"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "github_actions_policy_ecr" {
  name   = "${var.waypoint_project}-github-actions-ecr-push-policy"
  policy = data.aws_iam_policy_document.policy.json
}

resource "aws_iam_role_policy_attachment" "github_actions_role_policy_attachment" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_policy_ecr.arn
}
