provider "okta" {
    org_name  = var.org_name
    base_url  = var.base_url
    api_token = var.api_token
}
//This includes the Okta extension for Terraform and provides the
//three variables from our okta.auto.tfvars file to configure it.

data okta_group all {
  name       = "Everyone"
}
