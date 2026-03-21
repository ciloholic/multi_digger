resource "aws_iam_role" "this" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_policy" "this" {
  name   = aws_iam_role.this.name
  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:sts::${var.account_id}:assumed-role/${var.gha_role}/GitHubActions"]
    }
  }
}

data "aws_iam_policy_document" "this" {
  # https://developer.hashicorp.com/terraform/language/backend/s3
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.tfstate_bucket_name}"]
  }

  statement {
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = ["arn:aws:s3:::${var.tfstate_bucket_name}/*"]
  }

  # statement {
  #   actions = [
  #     "dynamodb:DescribeTable",
  #     "dynamodb:PutItem",
  #     "dynamodb:GetItem",
  #     "dynamodb:DeleteItem",
  #   ]
  #   resources = ["arn:aws:dynamodb:ap-northeast-1:${var.account_id}:table/${var.tflock_table_name}"]
  # }
}
