<img src="https://bbdsoftware.com/wp-content/uploads/MServ-Black.png" 
   width="500" 
   height="120" />

# Terraform Module Template Repository

Template Repository for Terraform modules managed by BBD MServ.

## Usage

```hcl
module "example_usage" {
  source        = "../"
  example_input = "Insert your usage example input here."
}
```
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |







## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_example_input"></a> [example\_input](#input\_example\_input) | An example Terraform input. | `string` | `"example input"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_example_output"></a> [example\_output](#output\_example\_output) | An example Terraform output test. |

## Copyright

Copyright 2023 - BBD Software
