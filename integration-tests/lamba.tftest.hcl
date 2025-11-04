run "lambda_create_function" {
  module {
    source = "./simulation"
  }

  variables {
    role_arn      = "arn:aws:iam::${var.aws_account_id}:role/${var.role_name}"
    action_names  = ["lambda:CreateFunction"]
    resource_arns = ["arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:test-function"]
    context       = { namePrefix = "test" }
  }

  assert {
    condition     = output.allowed
    error_message = "Cannot create Lambda function"
  }
}
