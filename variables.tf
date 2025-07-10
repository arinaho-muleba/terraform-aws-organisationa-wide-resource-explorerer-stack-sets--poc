variable "stackset_name" {
  description = "Name of the StackSet"
  type        = string
}

variable "aggregator_region" {
  description = "Region that will create the Aggregator Index"
  type        = string
}

variable "regions" {
  type        = list(string)
  description = "Optional list of AWS regions to deploy to. If not set, all enabled commercial regions are used."
  default     = null
}

variable "single_account_mode" {
  type        = bool
  default     = false
  description = "If true, deploy only to the management account. Otherwise, deploy to the root OU."
}

variable "management_account_id" {
  type        = string
  default     = ""
  description = "The account ID of the management account. Required if single_account_mode = true."
}

variable "organization_ou_id" {
  description = "AWS Organization OU ID to deploy the StackSet to (e.g. r-xxxx or ou-xxxx-xxxxxxx)"
  default     = ""
  type        = string
}


