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

// resource "okta_factor" "oktaCall" {
//   provider_id = "okta_call"
// }
resource "okta_factor" "okta_push" {
  provider_id = "okta_push"
}
resource "okta_factor" "okta_otp" {
  provider_id = "okta_otp"
}
// resource "okta_factor" "oktaQuestion" {
//   provider_id = "okta_question"
// }
// resource "okta_factor" "oktaSMS" {
//   provider_id = "okta_sms"
// }
// resource "okta_factor" "fidoU2F" {
//   provider_id = "fido_u2f"
// }
// resource "okta_factor" "fidoWEB"{
//   provider_id = "fido_webauthn"
// }
resource "okta_factor" "google_otp" {
  provider_id = "google_otp"
}
// resource "okta_factor" "rsa_token" {
//   provider_id = "rsa_token"
// }
// resource "okta_factor" "symantec_vip" {
//   provider_id = "symantec_vip"
// }

/*  Some providers of factors may require to be manually activated from okta
(those needing extra parameters to be activatedd) */

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
  depends_on = [
    "okta_factor.okta_otp",
    "okta_factor.google_otp",
    "okta_factor.okta_push",
  ]

  groups_included = ["${okta_group.awesomeGroup.id}"]
}

resource "okta_policy_rule_mfa" "mfarulepolicy"{
  policyid =  "${okta_policy_mfa.testmfa.id}"
  name = "rule for mfa policy"
  status = "ACTIVE" //or "INACTIVE".
  enroll = "LOGIN" //It can be "CHALLENGE", "LOGIN", or "NEVER".
  network_connection = "ANYWHERE" // "ZONE", "ON_NETWORK", or "OFF_NETWORK".
}

resource "okta_policy_password" "tfpwdpolicy" {
  name                   = "tfpwdpolicy"
  status                 = "ACTIVE"
  description            = "waow this is the worst policy ever !"
  groups_included = ["${okta_group.awesomeGroup.id}"]
  password_min_length = 1 //default is 8
  password_min_lowercase = 1 //min nbr of lowercase
  password_min_uppercase = 0
  password_min_number = 0 //nbr of 'numbers'
  password_min_symbol = 0
  password_exclude_username = false
  password_exclude_first_name = false
  password_exclude_last_name = false
  password_dictionary_lookup = false //check pwd against common pwd dictionnary
  password_max_age_days = 0 // 0 = no limit
  password_expire_warn_days = 0 // 0 = no warning.
  password_min_age_minutes = 0 // 0 = no limit.
  password_history_count = 0 // 0 = none.
  password_max_lockout_attempts = 0 // 0 = no limit.
  password_auto_unlock_minutes = 0 //0 = no limit.
  password_show_lockout_failures = false
  question_min_length = 0
  email_recovery = "ACTIVE"
  recovery_email_token = 3600 // Lifetime in minutes of the recovery email token.
  sms_recovery = "ACTIVE"
  question_recovery = "ACTIVE"
}
