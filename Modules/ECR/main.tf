resource "aws_ecr_repository" "foo" {
  name                 = "my-repo"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
  encryption_configuration {
    encryption_type = "KMS"
  }
  tags = {
    Name        = "my-repo"
  }
}
data "aws_caller_identity" "current" {}
resource "aws_ecr_replication_configuration" "example" {
  replication_configuration {
    rule {
      destination {
        region      = "eu-west-1" 
        registry_id = data.aws_caller_identity.current.account_id
      }
    }
}
}