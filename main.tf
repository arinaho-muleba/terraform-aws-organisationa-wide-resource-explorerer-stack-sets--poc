data "aws_organizations_organization" "org" {}

data "aws_regions" "available" {}

locals {
  # Determine enabled regions from input or from available commercial regions
  enabled_regions = var.regions != [] ? toset(var.regions) : toset([
    for r in data.aws_regions.available.names : r
    if r != "us-gov-east-1" && r != "us-gov-west-1" && r != "cn-north-1" && r != "cn-northwest-1"
  ])

  # Default to root OU if no specific OU is passed
  root_ou_id   = data.aws_organizations_organization.org.roots[0].id
  target_ou_id = length(var.organization_ou_id) > 0 ? var.organization_ou_id : local.root_ou_id

  # for_each requires a map, so we key the region names to themselves
  region_map = { for r in local.enabled_regions : r => r }
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
    ManagementAccountId   = var.management_account_id
    OrganizationArn       = data.aws_organizations_organization.org.arn
  }


  operation_preferences {
    region_concurrency_type = "PARALLEL"
    failure_tolerance_count = 1
  }

}

# ----------------------------
# Management account stack deployment | Single account
# ----------------------------
# resource "aws_cloudformation_stack_set_instance" "single_account" {
#   for_each       = local.region_map
#   stack_set_name = aws_cloudformation_stack_set.resource_explorer.name
#   region         = each.value
#   account_id     = var.management_account_id
# }

# ----------------------------
# Organization Deployment
# ----------------------------
resource "aws_cloudformation_stack_set_instance" "organization" {
  for_each       = var.single_account_mode ? {} : local.region_map
  stack_set_name = aws_cloudformation_stack_set.resource_explorer.name
  region         = each.value
  deployment_targets {
    organizational_unit_ids = [local.target_ou_id]
  }
}
