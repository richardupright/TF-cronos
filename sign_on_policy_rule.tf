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
  //authtype            = "ANY" //or "RADIUS"
  access              = "ALLOW" //allow or deny based on the rule conditions
  //mfa_required        = false //default is false
  //mfa_prompt        = "ALWAYS", "DEVICE" or "SESSION"
  //mfa_remember_device = false //default is false
  //mfa_lifetime        = 5
  //network_connection  = "ANYWHERE" //"ZONE", "ON_NETWORK", or "OFF_NETWORK".

}
################################################################################
