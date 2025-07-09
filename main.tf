data "aws_organizations_organization" "org" {}

data "aws_regions" "available" {}

locals {
  enabled_regions = var.regions != null ? toset(var.regions) : toset([
    for r in data.aws_regions.available.names : r
    if r != "us-gov-east-1" && r != "us-gov-west-1" && r != "cn-north-1" && r != "cn-northwest-1"
  ])

  root_ou_id   = data.aws_organizations_organization.org.roots[0].id
  target_ou_id = length(var.organization_ou_id) > 0 ? var.organization_ou_id : local.root_ou_id
}

resource "aws_cloudformation_stack_set" "resource_explorer" {
  name             = var.stackset_name
  description      = "Deploys Resource Explorer index and view using CloudFormation"
  permission_model = "SERVICE_MANAGED"

  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = false
  }

  template_body = file("${path.module}/cf-templates/combined-indexes-cf.yaml")

  parameters = {
    AggregatorIndexRegion = var.aggregator_region
  }

  operation_preferences {
    region_concurrency_type = "PARALLEL"
    failure_tolerance_count = 1
  }
}

resource "aws_cloudformation_stack_set_instance" "resource_explorer" {
  for_each       = local.enabled_regions
  stack_set_name = aws_cloudformation_stack_set.resource_explorer.name
  region         = each.value

  deployment_targets {
    dynamic "accounts" {
      for_each = var.single_account_mode ? [true] : []
      content {
        accounts = [var.management_account_id]
      }
    }

    dynamic "organizational_unit_ids" {
      for_each = var.single_account_mode ? [] : [true]
      content {
        organizational_unit_ids = [local.target_ou_id]
      }
    }
  }
}
