run "lambda_create_function_pass" {
  variables {
    actions = [
      "lambda:CreateFunction"
    ]
    resources = [
      "arn:aws:lambda:${var.region}:${var.account_id}:function:test-function"
    ]
    context = [
      {
        key   = "aws:PrincipalTag/DeployNamePrefix"
        value = "test"
      }
    ]
  }

  assert {
    condition     = data.aws_iam_principal_policy_simulation.test.all_allowed == true
    error_message = "Cannot create the Lambda function"
  }
}

run "lambda_create_function_fail" {
  variables {
    actions = [
      "lambda:CreateFunction"
    ]
    resources = [
      "arn:aws:lambda:${var.region}:${var.account_id}:function:test-function"
    ]
  }

  assert {
    condition     = data.aws_iam_principal_policy_simulation.test.all_allowed == false
    error_message = "Should not have created the Lambda function"
  }
}

run "lambda_invoke_function_fail" {
  variables {
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
      "arn:aws:lambda:${var.region}:${var.account_id}:function:test-function"
    ]
  }

  assert {
    condition     = data.aws_iam_principal_policy_simulation.test.all_allowed == false
    error_message = "Should not have invoked the Lambda function"
  }
}
