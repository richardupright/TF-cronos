###################### /////  SIGN ON POLICY \\\\\\ ############################
resource "okta_policy_signon" "mySOpolicy" {
  name            = "super sign on policy"
  status          = "ACTIVE"
  description     = "description of my policy"
  groups_included = ["${okta_group.awesomeGroup.id}"]
}

resource "okta_policy_rule_signon" "test" {
  policyid           = okta_policy_signon.mySOpolicy.id
  name               = "super sign on rule"
  status             = "ACTIVE"
  access             = "ALLOW"
  session_idle       = 240
  session_lifetime   = 240
  session_persistent = false
  users_excluded     = ["${okta_user.example[1].id}"]
}
################################################################################
