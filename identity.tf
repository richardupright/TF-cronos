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

data okta_group all {
  name  = "Everyone"
}

###################### /////  ADDING USER \\\\\\ ###############################
//https://www.terraform.io/docs/providers/okta/r/user.html
resource "okta_user" "example" {
  count 	    = 4 //creates four new users (0,1,2,3)
  email 	    = "TerraformUser${count.index}@terraform.be"
  login 	    = "TerraformUser${count.index}@terraform.be"
  first_name  = "terraUser ${count.index}"
  last_name   = "form"
}
//can't specify custom attribute

resource "okta_user" "addingJESUS" {
  email 	    = "jesus@terraform.be"
  login 	    = "jesus@terraform.be"
  first_name  = "Jesus"
  last_name   = "Christ"
  admin_roles = ["SUPER_ADMIN"]
  zip_code = "1234"
  title = "employe of Terraform"
  primary_phone = "+320485963258"
}
################################################################################


###################### /////  ADDING GROUP \\\\\\ ##############################
//https://www.terraform.io/docs/providers/okta/r/group.html
resource "okta_group" "awesomeGroup" {
  name        = "awesome"
  description = "My Awesome Group"
}
resource "okta_group" "uselessGroup" {
  name        = "useless"
  description = "Group for admin"
}
################################################################################

###################### /////  GROUP ROLES \\\\\\ ###############################
//https://www.terraform.io/docs/providers/okta/r/group_roles.html
resource "okta_group_roles" "awesomeGroupRoles" {
  group_id    = okta_group.uselessGroup.id
  admin_roles = ["SUPER_ADMIN"]
  //values are : "SUPER_ADMIN", "ORG_ADMIN", "APP_ADMIN", "USER_ADMIN", "HELP_DESK_ADMIN",
  //"READ_ONLY_ADMIN", "MOBILE_ADMIN", "API_ACCESS_MANAGEMENT_ADMIN", "REPORT_ADMIN".
}
################################################################################

###################### /////  GROUP RULES \\\\\\ ###############################
//https://www.terraform.io/docs/providers/okta/r/group_rule.html
//group membership rules cannot be created for groups with administrators roles
resource "okta_group_rule" "addingUserRule" {
  count             = var.enable_group_rule ? 1 : 0 // Do not create if group rule feature is not available
  name              = "addRichard"
  status            = "ACTIVE"
  group_assignments = [okta_group.awesomeGroup.id]
  expression_type   = "urn:okta:expression:1.0" //expression type to use to invoke the rule
  expression_value  = "String.startsWith(user.firstName,\"Richard\")"
  // = "String.substringAfter(user.login, \"@\") == \"${var.domain}\""
}
################################################################################

###################### /////  ENABLE FACTORS \\\\\\ ############################
//https://www.terraform.io/docs/providers/okta/r/factor.html
resource "okta_factor" "google_otp" {
  provider_id = "google_otp"
}
resource "okta_factor" "okta_otp" {
  provider_id = "okta_otp"
}
resource "okta_factor" "okta_push" {
  provider_id = "okta_push"
  depends_on  = [okta_factor.okta_otp ]
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
// resource "okta_factor" "yubikey_token"{
//   provider_id = "yubikey_token"
// }
//  Some providers may require to be manually activated from okta
// rsa and symantec : unsported operation ?
// fido_u2f, fido_webauthn, yubikey_token : need to be enabled by okta support
################################################################################

###################### /////  MFA POLICY \\\\\\ ################################
//https://www.terraform.io/docs/providers/okta/r/policy_mfa.html
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

  groups_included = [okta_group.awesomeGroup.id]
}

resource "okta_policy_rule_mfa" "mfarulepolicy"{
  policyid           = okta_policy_mfa.testmfa.id
  name               = "rule for mfa policy"
  status             = "ACTIVE" //or "INACTIVE".
  enroll             = "LOGIN" //It can be "CHALLENGE", "LOGIN", or "NEVER".
  network_connection = "ANYWHERE" // "ZONE", "ON_NETWORK", or "OFF_NETWORK".
}
################################################################################

###################### /////  NETWORK ZONE \\\\\\ ##############################
//https://www.terraform.io/docs/providers/okta/r/network_zone.html
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

###################### /////  PASSWORD POLICY \\\\\\ ###########################
//https://www.terraform.io/docs/providers/okta/r/policy_password.html
resource "okta_policy_password" "tfpwdpolicy" {
  name                            = "tfpwdpolicy"
  status                          = "ACTIVE"
  description                     = "waow this is the worst policy ever !"
  groups_included                 = [okta_group.awesomeGroup.id]
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

//https://www.terraform.io/docs/providers/okta/r/policy_rule_password.html
resource "okta_policy_rule_password" "tfpwdpolicyrule" {
  policyid            = okta_policy_password.tfpwdpolicy.id
  name                = "great rule"
  status              = "ACTIVE"
  password_change     = "ALLOW" //default is allow
  password_reset      = "ALLOW"
  password_unlock     = "DENY" // default is DENY
  network_connection  = "ANYWHERE" // "ZONE", "ON_NETWORK", or "OFF_NETWORK".
}
################################################################################

###################### /////  USER SCHEMA \\\\\\ ###############################
//https://www.terraform.io/docs/providers/okta/r/user_schema.html
resource "okta_user_schema" "dob_extension" {
  index      = "date_of_birth"
  title      = "Date of Birth"
  type       = "string" //boolean, number, integer, array, object
  master     = "PROFILE_MASTER"  //or "OKTA"
  description = "The date of birth for that user"
}
resource "okta_user_schema" "crn_extension" {
  index      = "customer_reference_number"
  title      = "Customer Reference Number"
  required   = false
  type       = "string"
  master     = "PROFILE_MASTER"
  max_length = 10 //only for string
  min_length = 1
  depends_on = [okta_user_schema.dob_extension]
}
################################################################################

###################### /////  USER BASE SCHEMA \\\\\\ ##########################
//https://www.terraform.io/docs/providers/okta/r/user_base_schema.html
resource "okta_user_base_schema" "firstName" {
  index       = "firstName"
  title       = "First name"
  type        = "string"
  master      = "PROFILE_MASTER"
  permissions = "READ_WRITE"
  required    = true
}
################################################################################
###################### /////  TEMPLATE EMAIL \\\\\\ ############################
//https://www.terraform.io/docs/providers/okta/r/template_email.html
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

###################### /////  SIGN ON POLICY \\\\\\ ############################
//https://www.terraform.io/docs/providers/okta/r/policy_signon.html
resource "okta_policy_signon" "mySOpolicy" {
  name            = "super sign on policy"
  status          = "ACTIVE"
  description     = "description of my policy"
  groups_included = [okta_group.awesomeGroup.id]
}

//https://www.terraform.io/docs/providers/okta/r/policy_rule_signon.html
resource "okta_policy_rule_signon" "test" {
  priority            = 1
  policyid            = okta_policy_signon.mySOpolicy.id
  name                = "super sign on rule"
  status              = "INACTIVE"
  session_idle        = 240 //maxx minutes a session can be idle.
  session_lifetime    = 240 //Max minutes a session is active: Disable = 0.
  session_persistent  = false
  users_excluded      = [okta_user.example[1].id]
  authtype            = "ANY" //or "RADIUS"
  access              = "ALLOW" //allow or deny based on the rule conditions
  mfa_required        = false //default is false
  //mfa_prompt        = "ALWAYS", "DEVICE" or "SESSION"
  mfa_remember_device = false //default is false
  mfa_lifetime        = 5
  network_connection  = "ANYWHERE" //"ZONE", "ON_NETWORK", or "OFF_NETWORK".

}
################################################################################

// ###################### /////  ADD OAUTH APP \\\\\\ #############################
// //https://www.terraform.io/docs/providers/okta/r/app_oauth.html
// resource "okta_app_oauth" "f1" {
//   label                      = "F1DEMO"
//   type                       = "native" //web
//   grant_types                = ["authorization_code", "refresh_token", "implicit"]
//   redirect_uris              = ["http://localhost:8080/authorization-code/callback","http://localhost:8080/login/oauth2/code/okta"]
//   response_types             = ["code", "token", "id_token"]
//   login_uri                  = "http://localhost:8080/custom-login"
//   issuer_mode                 = "ORG_URL" //CUSTOM_URL
//   //client_id = ... to use a custom id
//   //tos_uri, logo_uri, policy_uri to specify URI for the client
// }
//
// //https://www.terraform.io/docs/providers/okta/d/user.html
// data "okta_user" "richard" {
//   search {
//     name  = "profile.firstName"
//     value = "Richard"
//   }
//   search {
//     name  = "profile.lastName"
//     value = "Dedecker"
//   }
// }
// // data "okta_user" "richard" {
// //   user_id = "00u304rjw6FmijP884x6"
// // }
//
// //https://www.terraform.io/docs/providers/okta/r/app_user.html
// resource "okta_app_user" "example" {
//   app_id   = okta_app_oauth.f1.id
//   user_id  = data.okta_user.richard.id
//   username = data.okta_user.richard.email
// }
################################################################################


###################### /////  AUTH SERVER \\\\\\ ###############################
//https://www.terraform.io/docs/providers/okta/r/auth_server.html
resource "okta_auth_server" "myServer" {
  audiences   = ["api://default"]
  description = "A perfect custom authorization server"
  name        = "custom"
  issuer_mode = "ORG_URL" //custom_url require the definition of a custom domain
  status      = "ACTIVE"
}

//https://www.terraform.io/docs/providers/okta/r/auth_server_scope.html
resource "okta_auth_server_scope" "test" {
  consent        = "REQUIRED" //indicates wether a consent dialog is needed for the scope (other value is IMPLICIT)
  description    = "test_updated"
  name           = "testsomething"
  auth_server_id = okta_auth_server.myServer.id
}

//https://www.terraform.io/docs/providers/okta/r/auth_server_claim.html
resource "okta_auth_server_claim" "test" {
  name           = "claimssss"
  status         = "ACTIVE"
  claim_type     = "RESOURCE" //for access token, or IDENTITY for id token
  value_type     = "EXPRESSION" //or GROUPS
  value          = "cool_updated"
  auth_server_id = okta_auth_server.myServer.id
  //always_include_in_token = false //default is true
  //scopes = [] list of scopes the claim is tied to
}

//https://www.terraform.io/docs/providers/okta/r/auth_server_policy.html
resource "okta_auth_server_policy" "test" {
  status           = "ACTIVE"
  name             = "policyformyauthserver"
  description      = "test "
  priority         = 1
  client_whitelist = ["ALL_CLIENTS"]
  auth_server_id   = okta_auth_server.myServer.id
}

//https://www.terraform.io/docs/providers/okta/r/auth_server_policy_rule.html
resource "okta_auth_server_policy_rule" "test" {
  auth_server_id       = okta_auth_server.myServer.id
  policy_id            = okta_auth_server_policy.test.id
  status               = "ACTIVE"
  name                 = "testing"
  priority             = 1
  group_whitelist      = [data.okta_group.all.id]
  grant_type_whitelist = ["password"] //accepted grant types : "authorization_code", "implicit"
  access_token_lifetime_minutes = 5 //values between 5 - 1440
  refresh_token_lifetime_minutes = 15
  refresh_token_window_minutes = 10 //window in which a refresh token can be used,  must be between accessTokenLifetimeMinutes-refreshTokenLifetimeMinutes, values between 10 - 2628000 (5years)
}
################################################################################
