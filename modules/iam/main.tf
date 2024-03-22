data "aws_iam_policy_document" "terraform_data_policy" {
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }
}

resource "aws_iam_user" "terraform_user" {
  name = "test-user"
}

resource "aws_iam_policy" "terraform_policy" {
  name        = "test_policy"
  description = "A test policy"
  policy      = data.aws_iam_policy_document.terraform_data_policy.json
}

resource "aws_iam_policy_attachment" "terraform_policy_attach" {
  name       = "policy_attachment"
  users      = [aws_iam_user.terraform_user.name]
  policy_arn = aws_iam_policy.terraform_policy.arn
}