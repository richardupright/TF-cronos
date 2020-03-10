# Defining variable here to use if after, but they are initialized on Terraform (in environnment variables)
variable "org_name" {}
variable "api_token" {}
variable "base_url" {}
variable domain {
    default     = "example.com"
}
variable enable_group_rule {
    default     = true
}

provider "okta" {
    org_name  = var.org_name
    base_url  = var.base_url
    api_token = var.api_token
}
//This includes the Okta extension for Terraform and provides the
//three variables from our okta.auto.tfvars file to configure it.
#
data okta_group all {
  name       = "Everyone"
}

###################### /////  USER SCHEMA \\\\\\ ###############################
resource "okta_user_schema" "dob_extension" {
  index      = "date_of_birth"
  title      = "Date of Birth"
  type       = "string"
  master     = "PROFILE_MASTER"
}
resource "okta_user_schema" "crn_extension" {
  index      = "customer_reference_number"
  title      = "Customer Reference Number"
  required   = false
  type       = "string"
  master     = "PROFILE_MASTER"
  depends_on = [okta_user_schema.dob_extension]
}
################################################################################

###################### /////  USER BASE SCHEMA \\\\\\ ##########################
resource "okta_user_base_schema" "firstName" {
  index       = "firstName"
  title       = "First name"
  type        = "string"
  master      = "PROFILE_MASTER"
  permissions = "READ_WRITE"
  required    = true
}
################################################################################

###################### /////  ADDING USER \\\\\\ ###############################
resource "okta_user" "example" {
  count 	    = 4 //creates four new users (0,1,2,3)
  email 	    = "TerraformUser${count.index}@terraform.be"
  login 	    = "TerraformUser${count.index}@terraform.be"
  first_name  = "terraUser ${count.index}"
  last_name   = "form"
  admin_roles = ["SUPER_ADMIN"]
}
//can't specify custom attribute (the crn defined just aboved can not be defined here)
################################################################################


###################### /////  ADDING GROUP \\\\\\ ##############################
resource "okta_group" "awesomeGroup" {
  name        = "awesome"
  description = "My Awesome Group"
}
################################################################################

###################### /////  GROUP ROLES \\\\\\ ###############################
// resource "okta_group_roles" "awesomeGroupRoles" {
//   group_id    = "${okta_group.awesomeGroup.id}" //deprecated style (0.11)
//   group_id    = "okta_group.awesomeGroup.id" //0.12 style
//   admin_roles = ["SUPER_ADMIN"]
// }
################################################################################

###################### /////  GROUP RULES \\\\\\ ###############################
//group membership rules cannot be created for groups with administrators roles
resource "okta_group_rule" "addingUserRule" {
  count             = var.enable_group_rule ? 1 : 0 // Do not create if group rule feature is not available
  name              = "addRichard"
  status            = "ACTIVE"
  group_assignments = ["${okta_group.awesomeGroup.id}"]
  expression_type   = "urn:okta:expression:1.0"
  expression_value  = "String.startsWith(user.firstName,\"Richard\")"
//expression_value  = "String.substringAfter(user.login, \"@\") == \"${var.domain}\""
}
################################################################################

###################### /////  ENABLE FACTORS \\\\\\ ############################
resource "okta_factor" "google_otp" {
  provider_id = "google_otp"
}
resource "okta_factor" "okta_push" {
  provider_id = "okta_push"
}
resource "okta_factor" "okta_otp" {
  provider_id = "okta_otp"
}
// resource "okta_factor" "okta_call" {
//   provider_id = "okta_call"
// }
// resource "okta_factor" "okta_question" {
//   provider_id = "okta_question"
// }
// resource "okta_factor" "okta_sms" {
//   provider_id = "okta_sms"
// }
// resource "okta_factor" "fido_u2f" {
//   provider_id = "fido_u2f"
// }
// resource "okta_factor" "fido_webauthn"{
//   provider_id = "fido_webauthn"
// }
// resource "okta_factor" "rsa_token" {
//   provider_id = "rsa_token"
// }
// resource "okta_factor" "symantec_vip" {
//   provider_id = "symantec_vip"
// }
//  Some providers may require to be manually activated from okta
// (those needing extra parameters to be activatedd, like rsa)
################################################################################

###################### /////  MFA POLICY \\\\\\ ################################
resource "okta_policy_mfa" "testmfa" {
  name        = "addingMFAfromTerraform"
  status      = "ACTIVE"
  description = "my awesome mfa polciy"

  okta_otp    = {
    enroll    = "REQUIRED"
  }
  okta_push   = {
    enroll    = "OPTIONAL"
  }
  google_otp  = {
    enroll    = "OPTIONAL"
  }
  depends_on  = [
    okta_factor.okta_otp,
    okta_factor.google_otp,
    okta_factor.okta_push,
  ]

  groups_included = ["${okta_group.awesomeGroup.id}"]
}

resource "okta_policy_rule_mfa" "mfarulepolicy"{
  policyid           = "${okta_policy_mfa.testmfa.id}"
  name               = "rule for mfa policy"
  status             = "ACTIVE" //or "INACTIVE".
  enroll             = "LOGIN" //It can be "CHALLENGE", "LOGIN", or "NEVER".
  network_connection = "ANYWHERE" // "ZONE", "ON_NETWORK", or "OFF_NETWORK".
}
################################################################################

###################### /////  PASSWORD POLICY \\\\\\ ###########################
resource "okta_policy_password" "tfpwdpolicy" {
  name                            = "tfpwdpolicy"
  status                          = "ACTIVE"
  description                     = "waow this is the worst policy ever !"
  groups_included                 = ["${okta_group.awesomeGroup.id}"]
  password_min_length             = 4 //default is 8, min 4
  password_min_lowercase          = 1 //min nbr of lowercase
  password_min_uppercase          = 0
  password_min_number             = 0 //nbr of 'numbers'
  password_min_symbol             = 0
  password_exclude_username       = false
  password_exclude_first_name     = false
  password_exclude_last_name      = false
  password_dictionary_lookup      = false //check pwd against common pwd dictionnary
  password_max_age_days           = 0 // 0 = no limit
  password_expire_warn_days       = 0 // 0 = no warning.
  password_min_age_minutes        = 0 // 0 = no limit.
  password_history_count          = 0 // 0 = none.
  password_max_lockout_attempts   = 0 // 0 = no limit.
  password_auto_unlock_minutes    = 0 // 0 = no limit.
  password_show_lockout_failures  = false
  question_min_length             = 1 //min 1
  email_recovery                  = "ACTIVE"
  recovery_email_token            = 3600 // Lifetime in minutes of the recovery email token.
  sms_recovery                    = "ACTIVE"
  question_recovery               = "ACTIVE"
}

resource "okta_policy_rule_password" "tfpwdpolicyrule" {
  policyid            = "${okta_policy_password.tfpwdpolicy.id}"
  name                = "great rule"
  status              = "ACTIVE"
  password_change     = "ALLOW" //default is allow
  password_reset      = "ALLOW"
  password_unlock     = "DENY" // default is DENY
  network_connection  = "ANYWHERE" // "ZONE", "ON_NETWORK", or "OFF_NETWORK".
}
################################################################################

###################### /////  SIGN ON POLICY \\\\\\ ############################
resource "okta_policy_signon" "mySOpolicy" {
  name            = "super sign on policy"
  status          = "ACTIVE"
  description     = "description of my policy"
  groups_included = ["${okta_group.awesomeGroup.id}"]
}

resource "okta_policy_rule_signon" "test" {
  policyid           = "${okta_policy_signon.mySOpolicy.id}"
  name               = "super sign on rule"
  status             = "ACTIVE"
  access             = "ALLOW"
  session_idle       = 240
  session_lifetime   = 240
  session_persistent = false
  users_excluded     = ["${okta_user.example[1].id}"]
}
################################################################################

###################### /////  TEMPLATE EMAIL \\\\\\ ############################
// **** To update the default email template, need to uprage Okta ****
// resource "okta_template_email" "test" {
//   type = "email.forgotPassword"
//
//   translations {
//     language = "en"
//     subject  = "You forgot your password again ?"
//     template = "Hi $${user.firstName},<br/><br/>click here $${resetPasswordLink}"
//   }
//
//   translations {
//     language = "fr"
//     subject  = "Tu as oublié ton mot de passe hein ? "
//     template = "Alors $${user.firstName},<br/><br/>Clique ici $${resetPasswordLink}"
//   }
// }
################################################################################

###################### /////  ADD OAUTH APP \\\\\\ #############################
resource "okta_app_oauth" "f1" {
  label                      = "F1DEMO"
  type                       = "native" //web
  grant_types                = ["authorization_code", "refresh_token", "implicit"]
  redirect_uris              = ["http://localhost:8080/authorization-code/callback","http://localhost:8080/login/oauth2/code/okta"]
  response_types             = ["code", "token", "id_token"]
  login_uri                  = "http://localhost:8080/custom-login"
  issuer_mode                 = "ORG_URL" //CUSTOM_URL
}
################################################################################

###################### /////  NETWORK ZONE \\\\\\ ##############################
resource "okta_network_zone" "myZone" {
  name     = "Area 51"
  type     = "IP"
  gateways = ["18.188.148.92-18.188.148.92"]
  //proxies  = ["2.2.3.4/24", "3.3.4.5-3.3.4.15"]
}
//Dynamic zone require : Geolocation for Network Zones or IP Trust for Network Zones to be enabled
// this is an EA feature, need to go through okta support (open a case)
// resource "okta_network_zone" "dynamic_network_zone_example" {
//   name              = "Dynamic zone for US and BE"
//   type              = "DYNAMIC"
//   dynamic_locations = ["US", "BE"]
// }
################################################################################

###################### /////  AUTH SERVER \\\\\\ ###############################
resource "okta_auth_server" "myServer" {
  audiences   = ["api://default"]
  description = "A perfect custom authorization server"
  name        = "custom"
  issuer_mode = "ORG_URL" //custom_url require the definition of a custom domain
  status      = "ACTIVE"
}
################################################################################
