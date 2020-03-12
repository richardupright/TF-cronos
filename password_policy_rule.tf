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
