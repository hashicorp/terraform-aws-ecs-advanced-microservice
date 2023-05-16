resource "github_repository" "templated_app_repository" {
  name = var.repo_name

  visibility = var.git_repo_visibility

  template {
    owner                = var.github_org_name
    repository           = var.template_repo_name
    include_all_branches = true
  }

  provisioner "local-exec" {
    command     = "./scripts/render-repo.sh"
    interpreter = ["bash"]
    environment = {
      WAYPOINT_PROJECT_NAME = var.repo_name
      GITHUB_TOKEN          = var.github_token
      OWNER                 = var.github_org_name
    }
  }
}

resource "aws_iam_role" "github_actions_role" {
  name               = "${var.repo_name}-github-actions-role"
  assume_role_policy = aws_iam_policy.github_actions_policy_ecr.policy
}

resource "aws_iam_policy" "github_actions_policy_ecr" {
  name   = "${var.repo_name}-github-actions-ecr-push-policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
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
            ],
            "Resource": "arn:aws:ecr:${var.aws_region}:${var.aws_account_id}:repository/${var.repo_name}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetRegistryPolicy",
                "ecr:DescribeRegistry",
                "ecr:GetAuthorizationToken",
                "ecr:GetRegistryScanningConfiguration"
            ],
            "Resource": "*"
        },
        {
			"Effect": "Allow",
			"Principal": {
				"Federated": "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"
			},
			"Action": "sts:AssumeRoleWithWebIdentity",
			"Condition": {
				"StringEquals": {
					"token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
				},
				"StringLike": {
					"token.actions.githubusercontent.com:sub": "repo:${var.github_org_name}/${var.repo_name}:*"
				}
			}
		}
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "github_actions_role_policy_attachment" {
  policy_arn = aws_iam_policy.github_actions_policy_ecr.arn
  role       = aws_iam_role.github_actions_role

}