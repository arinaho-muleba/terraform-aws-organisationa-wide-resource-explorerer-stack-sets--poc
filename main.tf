data "aws_regions" "available" {}

locals { #if regions are not provided this will deploy to all enabled regions.
  enabled_regions = var.regions != null ? toset(var.regions) : toset([
    for r in data.aws_regions.available.names : r
    if r != "us-gov-east-1" && r != "us-gov-west-1" && r != "cn-north-1" && r != "cn-northwest-1"
  ])
}

resource "aws_cloudformation_stack_set" "resource_explorer" {

  name             = var.stackset_name
  description      = "Deploys Resource Explorer index and view using CloudFormation"
  permission_model = "SERVICE_MANAGED"

  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = false
  }

  # call_as = "DELEGATED_ADMIN" 

  template_body = file("${path.module}/cf-templates/combined-indexes-cf.yaml")

  parameters = {
    AggregatorIndexRegion = var.aggregator_region
  }

  capabilities = ["CAPABILITY_NAMED_IAM"]

  operation_preferences {
    region_concurrency_type = "PARALLEL"
    failure_tolerance_count = 1
  }
}

resource "aws_cloudformation_stack_set_instance" "resource_explorer_ou" {
  for_each       = local.enabled_regions
  stack_set_name = aws_cloudformation_stack_set.resource_explorer.name
  deployment_targets {
    organizational_unit_ids = [var.organization_ou_id]
  }
  region = each.value
}
