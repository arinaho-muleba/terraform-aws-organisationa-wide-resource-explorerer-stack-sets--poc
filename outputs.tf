output "org_stackset_name" {
  description = "Name of the CloudFormation StackSet deployed to the organization (OU)"
  value       = try(aws_cloudformation_stack_set.org_wide[0].name, null)
}

# output "management_stackset_name" {
#   description = "Name of the CloudFormation StackSet deployed to the management account"
#   value       = try(aws_cloudformation_stack_set.mgmt_account[0].name, null)
# }
