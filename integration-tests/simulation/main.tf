terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

variable "role_arn" {
  type = string

  validation {
    condition     = can(regex("^arn:aws(-[a-z]+)?:iam::\\d{12}:role\\/[A-Za-z0-9+=,.@_\\-\\/]+$", var.role_arn))
    error_message = "The role_arn must be a valid IAM Role ARN (e.g. arn:aws:iam::123456789012:role/MyRoleName)"
  }
}

variable "context" {
  type = object({
    namePrefix = string
    # tagKey     = optional(string)
    # tagValue   = optional(string)
  })
}

variable "action_names" {
  type = list(string)
}

variable "resource_arns" {
  type = list(string)
}

data "aws_iam_principal_policy_simulation" "test" {
  policy_source_arn = var.role_arn
  action_names      = var.action_names
  resource_arns     = var.resource_arns

  context {
    key    = "aws:PrincipalTag/DeployNamePrefix"
    type   = "string"
    values = [var.context.namePrefix]
  }
}

output "allowed" {
  value = data.aws_iam_principal_policy_simulation.test.all_allowed
}

output "results" {
  value = data.aws_iam_principal_policy_simulation.test.results
}
