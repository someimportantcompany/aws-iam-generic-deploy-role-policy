run "lambda_create_function" {
  variables {
    actions = [
      "lambda:CreateFunction"
    ]
    resources = [
      "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:test-function"
    ]
    context = [
      {
        key   = "aws:PrincipalTag/DeployNamePrefix"
        value = "test"
      }
    ]
  }

  assert {
    condition     = data.aws_iam_principal_policy_simulation.test.all_allowed
    error_message = "Cannot create Lambda function"
  }
}
