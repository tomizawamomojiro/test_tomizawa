resource "aws_ecr_repository" "cicd_ecr" {
    name                 = "${var.project_name}"
    image_tag_mutability = "MUTABLE" 
    image_scanning_configuration {
        scan_on_push = true
    }
}