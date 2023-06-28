resource "aws_codecommit_repository" "terraform"{
    repository_name = "terraform-${var.project_name}-iac"
    default_branch  = "master"
}