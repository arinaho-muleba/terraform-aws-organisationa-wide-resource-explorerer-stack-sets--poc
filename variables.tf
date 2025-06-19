variable "example_input" {
  description = "An example Terraform input."
  type        = string
  default     = "example input"
}

variable "rg_name" {
  type        = string
  description = "Resource group name"
  validation {
    condition     = length(var.rg_name) > 0
    error_message = "The resource group name must not be empty."
  }
}

variable "rg_location" {
  type        = string
  description = "Resource group location"
  
  validation {
    condition     = length(var.rg_location) > 0
    error_message = "The azure region must not be empty."
  }
}

variable "vwan_name" {
    type = string
    description = "The name of the virtual WAN."  
}

variable "disable_vpn_encryption" {
  description = "Boolean flag to specify whether VPN encryption is disabled."
  type        = bool
  default     = false
}

variable "allow_branch_to_branch_traffic" {
  description = "Boolean flag to specify whether branch to branch traffic is allowed."
  type        = bool
  default     = true
}

variable "office365_local_breakout_category" {
  description = "Specifies the Office365 local breakout category."
  type        = string
  default     = "None"

   validation {
    condition     = contains(["Optimize", "OptimizeAndAllow", "All", "None"], var.office365_local_breakout_category)
    error_message = "The office365_local_breakout_category must be one of: Optimize, OptimizeAndAllow, All, None."
  }
}

variable "vwan_type" {
  description = "Specifies the Virtual WAN type."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard"], var.vwan_type)
    error_message = "The vwan_type must be either 'Basic' or 'Standard'."
  }
}

variable "vwan_tags" {
  description = "A mapping of tags to assign to the Virtual WAN."
  type        = map(string)
  default     = {}
}