#
variable "org_name" {}
variable "api_token" {}
variable "base_url" {}

provider "okta" {
    org_name = var.org_name
    base_url = var.base_url
    api_token = var.api_token
}
//This includes the Okta extension for Terraform and provides the
//three variables from our okta.auto.tfvars file to configure it.
#

#
resource "okta_user_schema" "dob_extension" {
  index  = "date_of_birth"
  title  = "Date of Birth"
  type   = "string"
  master = "PROFILE_MASTER"
}
#

#
resource "okta_user_schema" "crn_extension" {
  index  = "customer_reference_number"
  title  = "Customer Reference Number"
  required = false
  type   = "string"
  master = "PROFILE_MASTER"
  depends_on = [okta_user_schema.dob_extension]
}
#

#
//creates four new users (0,1,2,3)
resource "okta_user" "example" {
  count 	  = 4
  email 	  = "TerraformUser${count.index}@terraform.be"
  login 	  = "TerraformUser${count.index}@terraform.be"
  first_name  = "terraUser ${count.index}"
  last_name   = "form"
  admin_roles = ["SUPER_ADMIN"]
}
//can't specify custom attributes, so for example, the crn defined just aboved can not be defined here
#

#
resource "okta_group" "awesomeGroup" {
  name        = "awesome"
  description = "My Awesome Group"
 // users = ["${mickeymouse@uprightsecurity.be"]
}
#

variable domain {
  default = "example.com"
}

variable enable_group_rule {
  default = false
}
#
resource "okta_group_rule" "addingUserRule" {
// Do not create if group rule feature is not available
 // count             = "${var.enable_group_rule ? 1 : 0}"
  group_membership_rules = true
  name              = "addRichard"
  status            = "ACTIVE"
  group_assignments = ["${okta_group.awesomeGroup.id}"]
  expression_type   = "urn:okta:expression:1.0"
  expression_value  = "String.startsWith(user.firstName,\"Richard\")"
//expression_value  = "String.substringAfter(user.login, \"@\") == \"${var.domain}\""
}
#
