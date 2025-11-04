terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

variable "account_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "role_name" {
  type = string
}

variable "actions" {
  type    = list(string)
  default = []
}

variable "resources" {
  type    = list(string)
  default = []
}

variable "context" {
  type = list(object({
    key   = string
    type  = optional(string)
    value = string
  }))
  default = []
}

data "aws_iam_principal_policy_simulation" "test" {
  policy_source_arn = "arn:aws:iam::${var.account_id}:role/${var.role_name}"
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
