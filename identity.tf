# Defining variable here to use if after, but they are initialized on Terraform (in environnment variables)
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
  //users = ["okta_user.example[1].id"]
}
#

//resource okta_group_roles roles {
//  group_id    = "${okta_group.awesomeGroup.id}" //deprecated style (0.11)
//  group_id    = "okta_group.awesomeGroup.id" //0.12 style
  //admin_roles = ["SUPER_ADMIN"]
//}

variable domain {
  default = "example.com"
}

variable enable_group_rule {
  default = true
}
#
//group membership rules cannot be created for groups with administrators roles
resource "okta_group_rule" "addingUserRule" {
// Do not create if group rule feature is not available
  count             = "${var.enable_group_rule ? 1 : 0}"
  name              = "addRichard"
  status            = "ACTIVE"
  group_assignments = ["${okta_group.awesomeGroup.id}"]
  expression_type   = "urn:okta:expression:1.0"
  expression_value  = "String.startsWith(user.firstName,\"Richard\")"
//expression_value  = "String.substringAfter(user.login, \"@\") == \"${var.domain}\""
}
#

// resource "okta_factor" "okta" {
//   provider = "OKTA"
// }
// resource "okta_factor" "yubico" {
//   provider = "YUBICO"
// }
// resource "okta_factor" "fido" {
//   provider = "FIDO"
// }
// resource "okta_factor" "google" {
//   provider = "GOOGLE"
// }
resource "okta_factor" "rsa" {
  provider_id = "okta.RsaTokenFactor"
  active = true
}
resource "okta_factor" "symantec" {
  provider_id = "okta.SymantecVipFactor"
  active = true
}

resource "okta_policy_mfa" "testmfa" {
  name        = "addingMFAfromTerraform"
  status      = "ACTIVE"
  description = "my awesome mfa polciy"

  okta_otp = {
    enroll = "REQUIRED"
  }
  okta_push = {
    enroll = "OPTIONAL"
  }
  google_otp = {
    enroll = "OPTIONAL"
  }

  groups_included = ["${okta_group.awesomeGroup.id}"]
}

resource "okta_policy_rule_mfa" "mfarulepolicy"{
  policyid =  "${okta_policy_mfa.testmfa.id}"
  name = "rule for mfa policy"
  status = "ACTIVE" //or "INACTIVE".
  enroll = "LOGIN" //It can be "CHALLENGE", "LOGIN", or "NEVER".
  network_connection = "ANYWHERE" // "ZONE", "ON_NETWORK", or "OFF_NETWORK".
}
