data "aws_organizations_organization" "org" {}

data "aws_regions" "available" {}

locals {
  enabled_regions = var.regions != [] ? toset(var.regions) : toset([
    for r in data.aws_regions.available.names : r
    if r != "us-gov-east-1" && r != "us-gov-west-1" && r != "cn-north-1" && r != "cn-northwest-1"
  ])

  root_ou_id   = data.aws_organizations_organization.org.roots[0].id
  target_ou_id = length(var.organization_ou_id) > 0 ? var.organization_ou_id : local.root_ou_id

  region_map = { for r in local.enabled_regions : r => r }
}

# ----------------------------
# StackSet for OU-wide (excluding management account)
# ----------------------------
resource "aws_cloudformation_stack_set" "org_wide" {
  count            = var.single_account_mode ? 0 : 1
  name             = "${var.stackset_name}-org-wide"
  description      = "Deploy Resource Explorer org-wide (excludes management account)"
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

resource "aws_cloudformation_stack_set_instance" "org_instances" {
  count          = var.single_account_mode ? 0 : 1
  for_each       = var.single_account_mode ? {} : local.region_map
  stack_set_name = aws_cloudformation_stack_set.org_wide[0].name
  region         = each.value

  deployment_targets {
    organizational_unit_ids = [local.target_ou_id]
  }
}

