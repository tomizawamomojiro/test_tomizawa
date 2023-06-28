resource "aws_codepipeline" "cicd_codepipline" {
    name     = "${var.project_name}-pipeline"
    role_arn = aws_iam_role.codepipeline_role.arn
    artifact_store {
        location = aws_s3_bucket.artifact_store.bucket
        type     = "S3"
    }

    stage {
        name = "Source"
        action {
            name             = "Source"
            category         = "Source"
            owner            = "AWS"
            provider         = "CodeCommit"
            version          = "1"
            output_artifacts = ["source_output"]
            configuration = {
                BranchName     = "master"
                OutputArtifactFormat = "CODEBUILD_CLONE_REF"
                RepositoryName = aws_codecommit_repository.terraform.repository_name
            }
        }
    }

    stage {
        name = "Build"
        action {
            name             = "Build"
            category         = "Build"
            owner            = "AWS"
            provider         = "CodeBuild"
            input_artifacts  = ["source_output"]
            output_artifacts = ["build_output"]
            version          = "1"
            configuration = {
                ProjectName = aws_codebuild_project.cicd_codebuild.name
            }
        }
    }
    tags = {
        Name = "${var.project_name}-pipeline"
    }
}

resource "aws_iam_role" "codepipeline_role" {
    name = "tomizawa-prod-codepipeline-role"
    assume_role_policy = jsonencode({
            Version = "2012-10-17"
            Statement = [
            {
            Action = "sts:AssumeRole"
            Effect = "Allow"
                Principal = {
                    Service = "codepipeline.amazonaws.com"
                }
            }
        ]
    })
}


resource "aws_iam_policy" "codepipeline_policy" {
  name = "tomizawa-codepipeline_policy"

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

resource "aws_iam_role_policy_attachment" "codepipeline_role_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}