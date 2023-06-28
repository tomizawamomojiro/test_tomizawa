resource "aws_codebuild_project" "cicd_codebuild" {
    name           = "${var.project_name}-codebuild"
    description    = "CodeBuild project for ${var.project_name}"
    build_timeout  = 5
    service_role   = aws_iam_role.codebuild_role.arn
    artifacts {
        type = "CODEPIPELINE"
    }

    environment {
        compute_type                = "BUILD_GENERAL1_SMALL"
        image                       = "aws/codebuild/standard:5.0"
        type                        = "LINUX_CONTAINER"
        image_pull_credentials_type = "CODEBUILD"
    }
    source {
        type = "CODEPIPELINE"
        buildspec = "buildspec.yml"
    }
    tags = {
        Name = "${var.project_name}-codebuild"
    }
}

resource "aws_iam_role" "codebuild_role" {
    name = "${var.project_name}-codebuild-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
            Action = "sts:AssumeRole"
            Effect = "Allow"
                Principal = {
                    Service = "codebuild.amazonaws.com"
                }
            }
        ]
    })
}

resource "aws_iam_policy" "codebuild_policy" {
  name = "tomizawa-codebuild_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
                "*",
            ],
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_role_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}