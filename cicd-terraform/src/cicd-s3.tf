resource "aws_s3_bucket" "artifact_store" {
  bucket = "${var.project_name}-artifact-store"
}