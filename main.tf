/*
* # Terraform Module Template Repository 
*
* Template Repository for Terraform modules managed by BBD MServ.
*/

locals {
  example = var.example_input
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.rg_location
}

resource "azurerm_virtual_wan" "vwan" {
  name                = var.vwan_name
  resource_group_name = var.rg_name
  location            = var.rg_location

  #optional attributes
  disable_vpn_encryption            = var.disable_vpn_encryption         
  allow_branch_to_branch_traffic    = var.allow_branch_to_branch_traffic 
  office365_local_breakout_category = var.office365_local_breakout_category 
  type                              = var.vwan_type                      
  tags                              = var.vwan_tags 
}
