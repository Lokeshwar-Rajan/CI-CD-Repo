data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = var.trusted_services
    }
  }
}
 
resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}
 
resource "aws_iam_role_policy_attachment" "attachments" {
  for_each   = toset(var.policy_arns)
  role = aws_iam_role.this.name
  policy_arn = each.value
}
resource "aws_iam_instance_profile" "this" {
  count = var.create_instance_profile ? 1 : 0

  name = "${var.role_name}-profile"
  role = aws_iam_role.this.name
}
