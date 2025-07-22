output "stackset_name" {
  description = "Name of the deployed CloudFormation StackSet"
  value       = aws_cloudformation_stack_set.org_wide.name
}

output "enabled_regions" {
  description = "Regions where StackSet instances were deployed"
  value       = local.enabled_regions
}

output "target_organizational_unit_id" {
  description = "The OU ID where the StackSet was deployed"
  value       = local.target_ou_id
}

output "stack_set_instances" {
  description = "Map of regions to deployed StackSet instances"
  value = {
    for region, instance in aws_cloudformation_stack_set_instance.org_instances :
    region => instance.id
  }
}
