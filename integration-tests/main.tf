terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

variable "aws_account_id" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "role_name" {
  type = string
}

variable "actions" {
  type = list(string)
}

variable "resources" {
  type = list(string)
}

variable "context" {
  type = list(object({
    key   = string
    type  = optional(string)
    value = string
  }))
}

data "aws_iam_principal_policy_simulation" "test" {
  policy_source_arn = "arn:aws:iam::${var.aws_account_id}:role/${var.role_name}"
  action_names      = var.actions
  resource_arns     = var.resources

  dynamic "context" {
    for_each = var.context

    content {
      key    = context.value.key
      type   = coalesce(context.value.type, "string")
      values = [context.value.value]
    }
  }
}

output "allowed" {
  value = data.aws_iam_principal_policy_simulation.test.all_allowed
}

output "results" {
  value = data.aws_iam_principal_policy_simulation.test.results
}
