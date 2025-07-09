output "stackset_name" {
  description = "Name of the deployed CloudFormation StackSet"
  value       = aws_cloudformation_stack_set.resource_explorer.name
}
