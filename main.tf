data "aws_organizations_organization" "org" {}

data "aws_regions" "available" {}

locals {
  enabled_regions = (
    can(length(var.regions)) && length(var.regions) > 0
    ) ? toset(var.regions) : toset([
      for r in data.aws_regions.available.names : r
      if !contains(["us-gov-east-1", "us-gov-west-1", "cn-north-1", "cn-northwest-1"], r)
  ])


  root_ou_id   = data.aws_organizations_organization.org.roots[0].id
  target_ou_id = length(var.organization_ou_id) > 0 ? var.organization_ou_id : local.root_ou_id
  region_map   = { for r in local.enabled_regions : r => r }
}

# ----------------------------
# StackSet for deploying additional indexes to the enabled regions not supported by quick setup
# ----------------------------
resource "aws_cloudformation_stack_set" "org_wide" {
  name             = "${var.stackset_name}-org-wide"
  description      = "Deploy Resource Explorer indexes and views org-wide "
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
    region_concurrency_type      = "PARALLEL"
    max_concurrent_percentage    = 100
    failure_tolerance_percentage = 25
  }

  tags = {
    Owner     = "BBD MServ"
    Terraform = "true"
  }

}

resource "aws_cloudformation_stack_set_instance" "org_instances" {
  for_each       = local.region_map
  stack_set_name = aws_cloudformation_stack_set.org_wide.name
  region         = each.value

  deployment_targets {
    organizational_unit_ids = [local.target_ou_id]
  }

  depends_on = [aws_cloudformation_stack_set.org_wide]
}

