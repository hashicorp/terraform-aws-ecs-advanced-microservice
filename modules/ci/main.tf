resource "github_repository" "templated_app_repository" {
  name = var.repo_name

  visibility = var.git_repo_visibility

  template {
    owner                = var.github_org_name
    repository           = var.template_repo_name
    include_all_branches = false
  }

  provisioner "local-exec" {
    command     = "./scripts/render-repo.sh"
    interpreter = ["bash"]
    environment = {
      WAYPOINT_PROJECT_NAME = var.repo_name
      GITHUB_TOKEN          = var.github_token
      OWNER                 = var.github_org_name
      GIT_USER              = var.git_user
      GIT_EMAIL             = var.git_email
    }
  }

  provisioner "local-exec" {
    command     = "./scripts/trigger-repo-init.sh"
    interpreter = ["bash"]
    environment = {
      WAYPOINT_PROJECT_NAME = var.repo_name
      GITHUB_TOKEN          = var.github_token
      OWNER                 = var.github_org_name
    }
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Federated"
      // TODO: Pull the ARN of the OIDC provider from the day zero infra module,
      // instead of interpolating it here
      identifiers = ["arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }

    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "token.actions.githubusercontent.com:aud"
    }

    condition {
      test     = "StringLike"
      values   = ["repo:${var.github_org_name}/${var.repo_name}:*"]
      variable = "token.actions.githubusercontent.com:sub"
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]
  }
}

resource "aws_iam_role" "github_actions_role" {
  name               = "${var.repo_name}-github-actions-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:DescribeImageScanFindings",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:GetDownloadUrlForLayer",
      "ecr:DescribeImageReplicationStatus",
      "ecr:ListTagsForResource",
      "ecr:BatchGetRepositoryScanningConfiguration",
      "ecr:PutImage",
      "ecr:BatchGetImage",
      "ecr:DescribeRepositories",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetRepositoryPolicy",
      "ecr:GetLifecyclePolicy"
    ]
    resources = [
      "arn:aws:ecr:${var.aws_region}:${var.aws_account_id}:repository/${var.repo_name}"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:GetRegistryPolicy",
      "ecr:DescribeRegistry",
      "ecr:GetAuthorizationToken",
      "ecr:GetRegistryScanningConfiguration"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "github_actions_policy_ecr" {
  name   = "${var.repo_name}-github-actions-ecr-push-policy"
  policy = data.aws_iam_policy_document.policy.json
}

resource "aws_iam_role_policy_attachment" "github_actions_role_policy_attachment" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_policy_ecr.arn
}
