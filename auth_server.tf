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
  group_whitelist      = ["${data.okta_group.all.id}"]
  grant_type_whitelist = ["password"] //accepted grant types : "authorization_code", "implicit"
  access_token_lifetime_minutes = 5 //values between 5 - 1440
  refresh_token_lifetime_minutes = 15
  refresh_token_window_minutes = 10 //window in which a refresh token can be used,  must be between accessTokenLifetimeMinutes-refreshTokenLifetimeMinutes, values between 10 - 2628000 (5years)
}
################################################################################
